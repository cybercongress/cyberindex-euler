import requests


def get_bandwidth_price():
    result = requests.get("https://titan.cybernode.ai/api/current_bandwidth_price").json()
    return result["result"]["price"]


def save_bandwidth_price(cursor, block, price):
    cursor.execute("""
        INSERT INTO bandwidth_price (block, price) 
        VALUES (%s, %s)

        ON CONFLICT DO NOTHING;
    """, (block, price))


def save_price(cursor, block):
    price = get_bandwidth_price()
    print("Saving price {} at block {}".format(price, block))
    save_bandwidth_price(cursor, block, price)
