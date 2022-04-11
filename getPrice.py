import requests
import os
from flask import Flask
import json
import pymongo

app = Flask(__name__)


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
def test_func():
    return "HELLO"



@app.route('/my_route/<product_name>', methods=['GET'])
def main_func(product_name):
    # store_list_id = [305, 28, 148]
    store_list_id = os.environ["STORE_LIST"][1:-1].split(", ")
    db_cursor = getMongoCursor()
    
    api_key = os.environ["API_KEY"]
    url = "https://api.superget.co.il"

   
   
    # get product ID
    params = {"api_key": api_key,
              "product_name": [product_name],
              "limit": 10,
              "action": "GetProductsByName"}

    # API - SUPER GET
    # response_product = requests.post(url, params)
    # obj = response_product.json()
    # product_id = obj[0]["product_id"]
    product_id = 5365

    # MONGODB - section
    # read document
    exists = db_cursor.find({"product_id": product_id}) # count_documents({}) #
    # data_lst = list(exists)
    mongo_retived = {}
    for ele in exists:
        mongo_retived[ele['store_id']] = ele['product_lowest_price']
    if mongo_retived != {}:
        # data_lst = dict(exists)
        # data_lst = [(ele[]) for ele in exists]
        with open("ans1.txt", 'w') as f:
            json.dump(mongo_retived, f)
        return mongo_retived

        
    # TEXT FILE - section
    # with open('ans.txt', 'r') as fobj:
    #     data_load = json.load(fobj)
    
    # if product_name in data_load.values():

    stores_and_prices = []
    # get product price from stores
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

    stores_and_prices_sorted = sorted(stores_and_prices, key=lambda p: p[1])  # first is the min

    data = {'product_id': product_id,
            'store_id': stores_and_prices_sorted[0][0],
            'product_lowest_price': stores_and_prices_sorted[0][1]}
    # {"product": {"store_id": "lowest_price"}}

    # # MONGODB - section
    # insert document
    db_cursor.insert_one(data)


    # with open("ans.txt", 'w') as f:
    #     json.dump(data, f)

    return dict({"store_id":stores_and_prices_sorted[0][0],
            "price": stores_and_prices_sorted[0][1]})


# # Press the green button in the gutter to run the script.
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=False)
    # store_list_id = {305, 28, 148}
    # product_name = "במבה אסם - 200 גרם"  # product id = 5365
    # api_key = "d35af1556ed30e0098eaf8c9bf829057b7cca565"
    # main_func()

    # MONGO - COMMANDS 
    # docker-compose exec mongodb /bin/sh
    # - ME_CONFIG_MONGODB_URL="mongodb://citizix:S3cret@127.0.0.1:27017/docker-mongo"

