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



"""
@app.route('/swipe', methods=['POST'])
def swipe():
    data = request.get_json()
    if not data or 'direction' not in data:
        return jsonify({'error': 'Invalid swipe data'}), 400

    direction = data['direction']
    name = data.get('name', 'unknown')
    user = data.get('user', 'anonymous')

    print(f"User '{user}' swiped {direction} on '{name}'")

    if direction.lower() == 'right':
        try:
            success = fs.add_liked_restaurant(user, name)
            if not success:
                return jsonify({'error': 'User not found'}), 404
        except Exception as e:
            print(f"Error updating liked restaurants: {e}")
            return jsonify({'error': 'Failed to update liked restaurants'}), 500

    return jsonify({"status": "received"}), 200
"""
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
        # Old style where() without FieldFilter
        query = users_ref.where('username', '==', username).limit(1).stream()
        if any(query):
            return jsonify({'error': 'User already exists'}), 400

        # Add new user
        new_user = {
            'username': username,
            'password': password,
            'liked': []
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



"""
@app.route('/liked_restaurants', methods=['POST'])
def liked_restaurants():
    data = request.get_json()
    username = data.get('username')

    if not username:
        return jsonify({'error': 'Username is required'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()

        user_doc = None
        for doc in query:
            user_doc = doc
            break

        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_data = user_doc.to_dict()
        liked_names = user_data.get('liked', [])

        if not liked_names:
            return jsonify([]), 200

        matched_restaurants = []

        for name in liked_names:
            restaurants_ref = fs.db.collection('restaurants')
            query = restaurants_ref.where('name', '==', name).stream()
            for rest_doc in query:
                matched_restaurants.append(rest_doc.to_dict())

        return jsonify(matched_restaurants), 200

    except Exception as e:
        print(f"Error fetching liked restaurants: {e}")
        return jsonify({'error': 'Internal server error'}), 500
"""
@app.route('/liked_restaurants', methods=['POST'])
def liked_restaurants():
    data = request.get_json()
    username = data.get('username')

    if not username:
        return jsonify({'error': 'Username is required'}), 400

    try:
        users_ref = fs.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()

        user_doc = None
        for doc in query:
            user_doc = doc
            break

        if user_doc is None:
            return jsonify({'error': 'User not found'}), 404

        user_data = user_doc.to_dict()
        liked_names = user_data.get('liked', [])
        
        # Defensive: likedTimestamps may be list or dict
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




@app.route('/favicon.ico')
def favicon():
    return '', 204







if __name__ == '__main__':
    app.run(debug=True)
