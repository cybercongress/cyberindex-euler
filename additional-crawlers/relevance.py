import requests
from config import RPC_URL


def get_block_relevance():
    result = requests.get("{}/api/top?page=\"0\"&perPage=\"1000\"".format(RPC_URL)).json()
    return result["result"]["cids"]

def save_block_relevance(cursor, block, cids):
    cursor.executemany("""
        INSERT INTO relevance (object, height, rank) 
        VALUES (%s, %s, %s)

        ON CONFLICT DO NOTHING;
    """, [
        (cid["cid"], block, cid["rank"])
        for cid in cids
    ])

def save_relevance(cursor, block):
    cids = get_block_relevance()
    print("Saving relevance at block {}".format(block))
    save_block_relevance(cursor, block, cids)
