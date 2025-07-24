from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)



@app.route('/')
def home():
    return "Flask backend is running!"

@app.route('/cards', methods=['GET'])
def get_cards():
    return jsonify([
        {
            "name": "Spaghetti Carbonara",
            "imageUrl": "https://via.placeholder.com/400x400/FF5733/FFFFFF?text=Carbonara",
            "description": "Classic Italian pasta dish with eggs, cheese, and pork.",
            "restaurantAddress": "123 Pasta Lane, Rome",
            "addressLink": "https://www.google.com/maps/search/?api=1&query=123+Pasta+Lane,+Rome",
        },
        {
            "name": "Sushi Platter",
            "imageUrl": "https://via.placeholder.com/400x400/3366FF/FFFFFF?text=Sushi",
            "description": "Fresh sushi and sashimi.",
            "restaurantAddress": "456 Sushi Blvd, Tokyo",
            "addressLink": "https://www.google.com/maps/search/?api=1&query=456+Sushi+Blvd,+Tokyo",
        }
    ])

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