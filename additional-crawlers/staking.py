import requests
from config import LCD_URL


def get_block_staking():
    statuses = ['bonded', 'unbonded', 'unbonding']
    final_result = []
    for status in statuses:
        result = requests.get(f"{LCD_URL}/staking/validators?status={status}").json()['result']
        validators = [{"operator_address": x['operator_address'], "tokens": x['tokens']} for x in result]
        final_result.extend(validators)
    return final_result

def save_block_staking(cursor, block, vals):
    cursor.executemany("""
        INSERT INTO staking (operator_address, height, tokens) 
        VALUES (%s, %s, %s)

        ON CONFLICT DO NOTHING;
    """, [
        (val["operator_address"], block, val["tokens"])
        for val in vals
    ])

def save_staking(cursor, block):
    vals = get_block_staking()
    print("Saving stajing at block {}".format(block))
    save_block_staking(cursor, block, vals)
