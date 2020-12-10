import asyncio
import psycopg2

from config import *
from relevance import save_relevance, update_top1000
from subscription import subscribe_block
from datetime import datetime

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
        save_relevance(cursor, block)
        connection.commit()
    return f

def update_views(connection, cursor):
    def f():
        update_top1000(cursor)
        connection.commit()
    return f
        

if __name__ == "__main__":
    print('try to start crawling')
    connection = get_connection()
    if connection:
        print(datetime.now(), 'connection to postgres OK')
    cursor = connection.cursor()
    state_saver = save_state(connection, cursor)
    view_updater = update_views(connection, cursor)

    subscription_url = 'ws://{}/v1/graphql'.format(HASURA_URL)
    coroutine = subscribe_block(
        subscription_url, 
        state_saver,
        view_updater
    )
    asyncio.get_event_loop().run_until_complete(coroutine)
    connection.close()