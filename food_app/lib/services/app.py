from flask import Flask, request, jsonify
from flask_cors import CORS
#from lib.services.Firestore_services import FirestoreClient
from Firestore_services import FirestoreClient
import json
import tempfile

app = Flask(__name__)
CORS(app)

fs = FirestoreClient()


@app.route('/')
def home():
    return "Flask backend is running!"

# change this for the ml logic as we want to change get restuants to ml logic
"""
@app.route('/cards', methods=['GET'])
def get_cards():
    try:
        restaurant_json = fs.get_restaurants()
        return jsonify(restaurant_json), 200
    except Exception as e:
        print(f"Error fetching cards: {e}")
        return jsonify({"error": "Failed to fetch cards"}), 500


"""


@app.route('/update_profile', methods=['POST'])
def update_profile():
    data = request.get_json()
    username = data.get('username')
    updated_data = data.get('updatedData', {})

    if not username or not updated_data:
        return jsonify({'error': 'Invalid request'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()
        user_doc = next(query, None)

        if not user_doc:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)

        # Do not allow changes to 'liked' or 'likedTimestamps'
        updated_data.pop('liked', None)
        updated_data.pop('likedTimestamps', None)
        updated_data.pop('preferences',None)

        user_ref.update(updated_data)
        return jsonify({'status': 'Profile updated'}), 200

    except Exception as e:
        print(f"Profile update error: {e}")
        return jsonify({'error': 'Internal server error'}), 500




@app.route('/cards', methods=['GET'])
def get_cards():
    try:
        username = request.args.get('username')  # Get 'username' from query params
        print(username)
        # For example, fetch all restaurants from your database or data source
        restaurant_json = fs.get_restaurants()

        # Default empty preferences if user not found or no username provided
        preferences = []
        print(preferences)
        if username:
            print("worked")
            users_ref = fs.db.collection('users')
            query = users_ref.where('username', '==', username).limit(1).stream()

            user_doc = next(query, None)
            if user_doc:
                user_data = user_doc.to_dict()
                preferences = user_data.get('preferences', [])
                preferences = [pref.lower() for pref in preferences if isinstance(pref, str)]

        if preferences:
            print("testing 2")
            print(preferences)
            filtered_restaurants = []
            for r in restaurant_json:
                cuisines = r.get('cuisines', [])
                if not isinstance(cuisines, list):
                    cuisines = []

                cuisines_lower = [c.lower() for c in cuisines if isinstance(c, str)]

                if any(pref == c for pref in preferences for c in cuisines_lower):
                    filtered_restaurants.append(r)

            print(filtered_restaurants)
            return jsonify(filtered_restaurants), 200

        # If no preferences or no username, return all restaurants
        return jsonify(restaurant_json), 200

    except Exception as e:
        print(f"Error fetching cards: {e}")
        return jsonify({"error": "Failed to fetch cards"}), 500

    except Exception as e:
        print(f"Error fetching cards: {e}")
        return jsonify({"error": "Failed to fetch cards"}), 500


@app.route('/swipe', methods=['POST'])
def swipe():
    data = request.get_json()
    if not data or 'direction' not in data:
        return jsonify({'error': 'Invalid swipe data'}), 400

    direction = data['direction']
    name = data.get('name', 'unknown')
    user = data.get('user', 'anonymous')
    timestamp = data.get('timestamp')  # Expecting ISO8601 string or epoch timestamp

    print(f"User '{user}' swiped {direction} on '{name}' at {timestamp}")

    if direction.lower() == 'right':
        try:
            # Here, you can store the timestamp as well
            success = fs.add_liked_restaurant(user, name, timestamp)
            if not success:
                return jsonify({'error': 'User not found'}), 404
        except Exception as e:
            print(f"Error updating liked restaurants: {e}")
            return jsonify({'error': 'Failed to update liked restaurants'}), 500

    return jsonify({"status": "received"}), 200

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    print("Received login data:", data)  # << Add this line

    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password required'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()

        for doc in query:
            user = doc.to_dict()
            if user.get('password') == password:
                # Success: return user data expected by Flutter
                return jsonify({
                    'id': doc.id,
                    'name': user['username'],
                    'avatarUrl': user.get('avatarUrl', '')  # Optional
                }), 200

        return jsonify({'error': 'Invalid username or password'}), 401
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password required'}), 400

    try:
        users_ref = fs.db.collection('users')

        # Check if user already exists
        query = users_ref.where('username', '==', username).limit(1).stream()
        if any(query):
            return jsonify({'error': 'User already exists'}), 400

        # Add new user with expanded friend structure
        new_user = {
            'username': username,
            'password': password,
            'liked': [],
            'likedTimestamps': {},
            'avatarUrl': '',
            'friends': {},
            'friend_requests_sent': [],
            'friend_requests_received': [],
            'session_id':{},
            'phone':'',
            'email':'',
        }

        users_ref.add(new_user)
        return jsonify({'message': 'User registered successfully'}), 201

    except Exception as e:
        print(f"Register error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/update_location', methods=['POST'])
def update_location():
    data = request.get_json()
    username = data.get('username')
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    cuisine_preferences = data.get('preferences', [])  # updated key to 'preferences'

    if not username or latitude is None or longitude is None:
        return jsonify({'error': 'Missing username or location data'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()

        user_doc = next(query, None)
        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        # Update location AND preferences
        user_ref.update({
            'location': {
                'latitude': latitude,
                'longitude': longitude,
            },
            'preferences': cuisine_preferences  # store preferences here
        })

        return jsonify({'status': 'Location and preferences updated'}), 200

    except Exception as e:
        print(f"Error updating location: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/liked_restaurants', methods=['GET', 'POST'])
def liked_restaurants():
    if request.method == 'GET':
        username = request.args.get('username')
    else:
        data = request.get_json()
        username = data.get('username')

    if not username:
        return jsonify({'error': 'Username is required'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()
        user_doc = next(query, None)

        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_data = user_doc.to_dict()
        liked_names = user_data.get('liked', [])
        
        liked_timestamps_raw = user_data.get('likedTimestamps', {})
        if isinstance(liked_timestamps_raw, list):
            liked_timestamps = {}
            for item in liked_timestamps_raw:
                if isinstance(item, dict):
                    liked_timestamps.update(item)
        else:
            liked_timestamps = liked_timestamps_raw

        if not liked_names:
            return jsonify([]), 200

        matched_restaurants = []
        restaurants_ref = fs.db.collection('restaurants')

        for i in range(0, len(liked_names), 10):
            chunk = liked_names[i:i+10]
            query = restaurants_ref.where('name', 'in', chunk).stream()
            for rest_doc in query:
                rest_data = rest_doc.to_dict()
                name = rest_data.get('name')
                rest_data['likedTimestamp'] = liked_timestamps.get(name)
                matched_restaurants.append(rest_data)

        return jsonify(matched_restaurants), 200

    except Exception as e:
        print(f"Error fetching liked restaurants: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/remove_liked_restaurant', methods=['POST'])
def remove_liked_restaurant():
    data = request.get_json()
    username = data.get('username')
    restaurant = data.get('restaurant')

    if not username or not restaurant:
        return jsonify({'error': 'Missing username or restaurant name'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()

        user_doc = None
        for doc in query:
            user_doc = doc
            break

        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        user_data = user_doc.to_dict()

        liked = user_data.get('liked', [])  # list of dicts or strings

        entry_to_remove = None
        for item in liked:
            if isinstance(item, dict) and item.get('name') == restaurant:
                entry_to_remove = item
                break
            elif isinstance(item, str) and item == restaurant:
                entry_to_remove = item
                break

        if entry_to_remove:
            liked.remove(entry_to_remove)
            user_ref.update({'liked': liked})
            return jsonify({'status': 'Removed from liked'}), 200
        else:
            return jsonify({'error': 'Restaurant not in liked list'}), 400

    except Exception as e:
        print(f"Error removing liked restaurant: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/send_friend_request', methods=['POST'])
def send_friend_request():
    data = request.get_json()
    print("Request data:", data)  # <-- Add this to debug

    username = data.get('username')
    target_username = data.get('target_username')
    
    if not username or not target_username:
        print("what")
        return jsonify({'error': 'Missing usernames'}), 400

    try:
        users_ref = fs.db.collection('users')
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)
        target_doc = next(users_ref.where('username', '==', target_username).limit(1).stream(), None)

        if user_doc is None or target_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        target_ref = users_ref.document(target_doc.id)

        user_data = user_doc.to_dict()
        target_data = target_doc.to_dict()

        sent = set(user_data.get('friend_requests_sent', []))
        received = set(target_data.get('friend_requests_received', []))

        # Already sent or already friends
        if target_username in sent or username in target_data.get('friends', {}):
            print("hey ho")
            return jsonify({'message': 'Already sent or already friends'}), 200

        sent.add(target_username)
        received.add(username)

        user_ref.update({'friend_requests_sent': list(sent)})
        target_ref.update({'friend_requests_received': list(received)})

        return jsonify({'message': 'Friend request sent'}), 200

    except Exception as e:
        print(f"Send friend request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500
    

@app.route('/get_friend_requests', methods=['GET'])
def get_friend_requests():
    username = request.args.get('username')
    if not username:
        print("error: no username")
        return jsonify({'error': 'Username required'}), 400

    try:
        users_ref = fs.db.collection('users')
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)

        if user_doc is None:
            print("error: no doc")
            return jsonify({'error': 'User not found'}), 404

        user_data = user_doc.to_dict()
        return jsonify({
            'incomingRequests': user_data.get('friend_requests_received', []),
            'sentRequests': user_data.get('friend_requests_sent', [])
        }), 200

    except Exception as e:
        print(f"Get friend requests error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/get_friends', methods=['GET'])
def get_friends():
    username = request.args.get('username')
    if not username:
        return jsonify({'error': 'Username is required'}), 400

    try:
        users_ref = fs.db.collection('users')
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)
        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_data = user_doc.to_dict()
        friends = user_data.get('friends', {})
        return jsonify(friends), 200

    except Exception as e:
        print(f"Get friends error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/accept_friend_request', methods=['POST'])
def accept_friend_request():
    data = request.get_json()
    username = data.get('username')
    from_user = data.get('from_user')

    if not username or not from_user:
        return jsonify({'error': 'Missing usernames'}), 400

    try:
        users_ref = fs.db.collection('users')
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)
        from_doc = next(users_ref.where('username', '==', from_user).limit(1).stream(), None)

        if user_doc is None or from_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        from_ref = users_ref.document(from_doc.id)

        user_data = user_doc.to_dict()
        from_data = from_doc.to_dict()

        # Remove from requests
        incoming = set(user_data.get('friend_requests_received', []))
        incoming.discard(from_user)
        sent = set(from_data.get('friend_requests_sent', []))
        sent.discard(username)

        # Add to friends
        user_friends = user_data.get('friends', {})
        from_friends = from_data.get('friends', {})
        user_friends[from_user] = True
        from_friends[username] = True

        user_ref.update({
            'friend_requests_received': list(incoming),
            'friends': user_friends
        })

        from_ref.update({
            'friend_requests_sent': list(sent),
            'friends': from_friends
        })

        return jsonify({'message': 'Friend request accepted'}), 200

    except Exception as e:
        print(f"Accept friend error: {e}")
        return jsonify({'error': 'Internal server error'}), 500



@app.route('/reject_friend_request', methods=['POST'])
def reject_friend_request():
    data = request.get_json()
    username = data.get('username')
    from_user = data.get('from_user')

    if not username or not from_user:
        return jsonify({'error': 'Missing usernames'}), 400

    try:
        users_ref = fs.db.collection('users')
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)
        from_doc = next(users_ref.where('username', '==', from_user).limit(1).stream(), None)

        if user_doc is None or from_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        from_ref = users_ref.document(from_doc.id)

        user_data = user_doc.to_dict()
        from_data = from_doc.to_dict()

        # Remove the request
        incoming = set(user_data.get('incomingRequests', []))
        incoming.discard(from_user)
        sent = set(from_data.get('sentRequests', []))
        sent.discard(username)

        user_ref.update({'incomingRequests': list(incoming)})
        from_ref.update({'sentRequests': list(sent)})

        return jsonify({'message': 'Friend request rejected'}), 200

    except Exception as e:
        print(f"Reject friend request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500





@app.route('/remove_friend', methods=['POST'])
def remove_friend():
    data = request.get_json()
    username = data.get('username')
    friend_username = data.get('friend_username')

    if not username or not friend_username:
        return jsonify({'error': 'Missing username or friend_username'}), 400

    try:
        users_ref = fs.db.collection('users')

        # Get user documents
        user_doc = next(users_ref.where('username', '==', username).limit(1).stream(), None)
        friend_doc = next(users_ref.where('username', '==', friend_username).limit(1).stream(), None)

        if user_doc is None or friend_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_ref = users_ref.document(user_doc.id)
        friend_ref = users_ref.document(friend_doc.id)

        user_data = user_doc.to_dict()
        friend_data = friend_doc.to_dict()

        # Update both users' friends lists
        user_friends = user_data.get('friends', {})
        friend_friends = friend_data.get('friends', {})

        if friend_username not in user_friends:
            return jsonify({'error': 'Friend not in list'}), 400

        user_friends.pop(friend_username, None)
        friend_friends.pop(username, None)

        user_ref.update({'friends': user_friends})
        friend_ref.update({'friends': friend_friends})

        return jsonify({'message': f'{friend_username} removed from friends for both users'}), 200

    except Exception as e:
        print(f"Error removing friend: {e}")
        return jsonify({'error': 'Internal server error'}), 500






@app.route('/favicon.ico')
def favicon():
    return '', 204







if __name__ == '__main__':
    app.run(debug=True)
