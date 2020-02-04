import websockets
import json
from config import *

async def init(websocket):
    json_init = json.dumps({
        "type": "connection_init",
        "payload": {
            "headers": {
                "content-type": "application/json",
                "x-hasura-admin-secret": HASURA_ADMIN_SECRET
            }
        }
    })
    await websocket.send(json_init)


async def send_query(websocket, query):
    json_query = json.dumps({
        "id": "1",
        "type": "start",
        "payload": {
            "query": query
        }
    })
    
    await websocket.send(json_query)


async def receive_data(websocket):
    response_json = {"type": None}
    while response_json["type"] != "data":
        print("Data received...", response_json)
        response = await websocket.recv()
        response_json = json.loads(response)

    return response_json["payload"]["data"]


async def subscribe_block(uri, save_state):
    async with websockets.connect(uri, subprotocols=["graphql-ws"]) as websocket:
        height_query = """
            subscription {
              block_aggregate {
                aggregate {
                  max {
                    height
                  }
                }
              }
            }
        """
        await init(websocket)
        await send_query(websocket, height_query)

        while True:
            data = await receive_data(websocket)
            block = data["block_aggregate"]["aggregate"]["max"]["height"]
            save_state(block)
