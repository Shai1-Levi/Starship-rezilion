import requests
import os
from flask import Flask, request
import json
import pymongo
import hvac
from flask_cors import CORS, cross_origin


app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'




mongo_data = {}

api_data = {305: 3.55,
            28 : 3.5,
            27 : 4.5,
            29 : 5.5,
            148: 2.90}


def getMongoCursor():
    myclient = pymongo.MongoClient(host=os.environ["HOST"], port=int(os.environ["PORT"]),
                                   username=os.environ["MONGO_INITDB_ROOT_USERNAME"],
                                   password=os.environ["MONGO_INITDB_ROOT_PASSWORD"], 
                                   authSource="admin")
    
    mydb = myclient[os.environ["DB_NAME"]]
    db_cursor = mydb[os.environ["COLLECTION_NAME"]]
    return db_cursor


@app.route('/', methods=['GET'])
@cross_origin()
def hello():
    return str({"hello":"world"}),200


def create_secret(client):
    client.secrets.kv.v2.create_or_update_secret(path='secret-api-key', secret=dict(apikey='d35af1556ed30e0098eaf8c9bf829057b7cca565'))
    print('Secret written successfully.')

def read_secret(client):
    read_response = client.secrets.kv.read_secret_version(path='secret-api-key')
    api_key = read_response['data']['data']['apikey']
    return api_key


def get_product_price_from_stores(api_key, product_id, store_list_id, url):
    stores_and_prices = []
    for store in store_list_id:
        params = {"api_key": api_key,
                  "store_id": store,
                  "product_id": product_id,
                  "action": "GetPriceByProductID"}

        # API - SUPER GET
        # response_stores = requests.post(url, params)
        # stores_data = response_stores.json()
        # price = stores_data[0]["store_product_price"]  # store_product_last_price
        price = api_data[int(store)]
        stores_and_prices.append((store, price))
    return stores_and_prices

@app.route("/myRoute/<productName>", methods=['GET'])
@cross_origin()
def get_cheapest_store_by_product_name(productName):
    # store_list_id=[305] #, 29, 148]
    store_list_id = os.environ["STORE_LIST"][1:-1].split(", ")

    db_cursor = getMongoCursor()
    
    client = hvac.Client( url='http://vault:8200', token='superget-api-key')
    create_secret(client)
    api_key = read_secret(client)
     
    superget_url = "https://api.superget.co.il"

    # get product ID
    params = {"api_key": api_key,
              "product_name": [productName],
              "limit": 10,
              "action": "GetProductsByName"}

    # API - SUPER GET
    # response_product = requests.post(superget_url, params)
    # obj = response_product.json()
    # product_id = obj[0]["product_id"]
    product_id = 5365

    # MONGODB - section
    # read document
    exists = db_cursor.find({"product_id": product_id}) 
    mongo_retived = {}
    mongo_retived['vault'] = api_key
    for ele in exists:
        mongo_retived[ele['store_id']] = ele['product_lowest_price']
    if len(mongo_retived) > 1:
        with open("ans1.txt", 'w') as f:
            json.dump(mongo_retived, f)
        return mongo_retived

            
    # get product price from stores
    stores_and_prices = get_product_price_from_stores(api_key, product_id, store_list_id, superget_url)
    stores_and_prices_sorted = sorted(stores_and_prices, key=lambda p: p[1])  # first is the min

    data = {'product_id': product_id,
            'store_id': stores_and_prices_sorted[0][0],
            'product_lowest_price': stores_and_prices_sorted[0][1]}

    # # MONGODB - section
    # insert document
    db_cursor.insert_one(data)

    print({"store_id":stores_and_prices_sorted[0][0],
            "price": stores_and_prices_sorted[0][1],
            "vault": api_key})

    
    return str({"store_id":stores_and_prices_sorted[0][0],
                "price": stores_and_prices_sorted[0][1],
                "vault": api_key}), 200


# # Press the green button in the gutter to run the script.
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
