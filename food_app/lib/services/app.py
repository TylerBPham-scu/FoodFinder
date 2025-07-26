from flask import Flask, request, jsonify
from flask_cors import CORS
#from lib.services.Firestore_services import FirestoreClient
from Firestore_services import FirestoreClient
import json

app = Flask(__name__)
CORS(app)

fs = FirestoreClient()


@app.route('/')
def home():
    return "Flask backend is running!"


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

    # Log the swipe or store in database here
    print(f"User '{user}' swiped {direction} on '{name}'")

    return jsonify({"status": "received"}), 200


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')

    if not username:
        return jsonify({'error': 'Username is required'}), 400

    try:
        users = fs.get_users()  # You must implement this method
        for user in users:
            if user['name'].lower() == username.lower():
                return jsonify(user), 200

        return jsonify({'error': 'User not found'}), 404
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/favicon.ico')
def favicon():
    return '', 204


if __name__ == '__main__':
    app.run(debug=True)
