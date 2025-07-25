from flask import Flask, request, jsonify
from flask_cors import CORS
from restaurant_data_pull import FirestoreClient
import json

fs = FirestoreClient()
restaurant_json = fs.get_restaurants()
print(restaurant_json[0])

app = Flask(__name__)
CORS(app)


@app.route('/')
def home():
    return "Flask backend is running!"

@app.route('/cards', methods=['GET'])
def get_cards():
    return jsonify(restaurant_json)

@app.route('/swipe', methods=['POST'])
def swipe():
    data = request.json
    print(f"User swiped {data['direction']} on {data.get('name', 'unknown card')}")
    return jsonify({"status": "received"})

@app.route('/favicon.ico')
def favicon():
    return '', 204

if __name__ == '__main__':
    app.run(debug=True)

if __name__ == '__main__':
    app.run(debug=True)