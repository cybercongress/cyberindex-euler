import requests
import asyncio
from time import sleep
import psycopg2

from config import *
from bandwidth import save_price
from relevance import save_relevance
from subscription import subscribe_block

def get_connection():
    connection = psycopg2.connect(
        host=DATABASE_HOST,
        port=DATABASE_PORT,
        dbname=DATABASE_NAME,
        user=DATABASE_USER,
        password=DATABASE_PASSWORD
    )
    return connection


def save_state(connection, cursor):
    def f(block):
        save_price(cursor, block)
        save_relevance(cursor, block)
        connection.commit()
    return f
        

if __name__ == "__main__":
    connection = get_connection()
    cursor = connection.cursor()
    state_saver = save_state(connection, cursor)

    subscription_url = 'ws://{}/v1/graphql'.format(HASURA_URL)
    coroutine = subscribe_block(
        subscription_url, 
        state_saver
    )
    asyncio.get_event_loop().run_until_complete(coroutine)