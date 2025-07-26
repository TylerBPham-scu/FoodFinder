import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import pandas as pd
import json

''' Class for Firestore functions to pull data

To Use:

from restaurant_data_pull import FirestoreClient
fs = FirestoreClient()
'''
class FirestoreClient:
    def __init__(self):
        self.cred = credentials.Certificate('C:\\Users\\tyler\\OneDrive\\Desktop\\Food_app\\food_app\\lib\\services\\foodapptesting_key.json')
        self.app = firebase_admin.initialize_app(self.cred)
        self.db = firestore.client()

    def get_restaurants(self):
        docs = self.db.collection('restaurants').get()
        data = [doc.to_dict() for doc in docs]
        return data
    