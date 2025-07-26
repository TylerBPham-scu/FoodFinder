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
@app.route('/cards', methods=['GET'])
def get_cards():
    try:
        restaurant_json = fs.get_restaurants()
        return jsonify(restaurant_json), 200
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



@app.route('/favicon.ico')
def favicon():
    return '', 204







if __name__ == '__main__':
    app.run(debug=True)
