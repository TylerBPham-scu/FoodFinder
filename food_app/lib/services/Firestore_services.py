import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json

''' Class for Firestore functions to pull data

To Use:

from restaurant_data_pull import FirestoreClient
fs = FirestoreClient()
'''
class FirestoreClient:
    def __init__(self):
        self.cred = credentials.Certificate('C:\\Users\\Michael\\Food_app\\food_app\\lib\\services\\foodapp.json')
        self.app = firebase_admin.initialize_app(self.cred)
        self.db = firestore.client()

    def get_restaurants(self):
        docs = self.db.collection('restaurants').get()
        data = [doc.to_dict() for doc in docs]
        return data
    
    def get_all_users(self):
        users_ref = self.db.collection('users')
        docs = users_ref.stream()
        return [doc.to_dict() for doc in docs]

    def user_exists(self, username):
        users_ref = self.db.collection('users')
        query = users_ref.where('username', '==', username).limit(1).stream()
        return any(query)
