import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1 import FieldFilter


class FirestoreClient:
    def __init__(self):
        self.cred = credentials.Certificate('C:\\Users\\Michael\\Food_app\\food_app\\lib\\services\\foodapp.json')
        self.app = firebase_admin.initialize_app(self.cred)
        self.db = firestore.client()

    def get_restaurants(self):
        docs = self.db.collection('restaurants').get()
        data = [doc.to_dict() for doc in docs]
        return data

    def get_users(self):
        users_ref = self.db.collection('users')
        docs = users_ref.stream()
        return [doc.to_dict() for doc in docs]

    def user_exists(self, username):
        users_ref = self.db.collection('users')
        query = users_ref.where(filter=FieldFilter('username', '==', username)).limit(1).stream()
        return any(query)

    def add_liked_restaurant(self, username, restaurant_name):
        users_ref = self.db.collection('users')
        query = users_ref.where(filter=FieldFilter('username', '==', username)).limit(1).stream()

        for doc in query:
            user_ref = users_ref.document(doc.id)
            user_data = doc.to_dict()
            liked = user_data.get('liked', [])
            if restaurant_name not in liked:
                liked.append(restaurant_name)
                user_ref.update({'liked': liked})
            return True  # Successfully updated

        return False  # User not found
