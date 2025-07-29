from web3 import Web3
from kafka import KafkaConsumer
import json
import os

w3 = Web3(Web3.HTTPProvider(os.getenv("WEB3_PROVIDER")))
contract_address = Web3.to_checksum_address(os.getenv("CONTRACT_ADDRESS"))
abi = json.load(open("contracts/WageFixSTO.abi.json"))
contract = w3.eth.contract(address=contract_address, abi=abi)
wallet = os.getenv("WALLET_ADDRESS")
key = os.getenv("PRIVATE_KEY")

consumer = KafkaConsumer(
    'wage-earned',
    bootstrap_servers='localhost:9092',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

for message in consumer:
    data = message.value
    user = Web3.to_checksum_address(data['user'])
    tokens = int(data['amount'])
    tx = contract.functions.issueTokens(user, tokens).build_transaction({
        'from': wallet,
        'nonce': w3.eth.get_transaction_count(wallet),
        'gas': 2000000,
        'gasPrice': w3.to_wei('10', 'gwei')
    })
    signed_tx = w3.eth.account.sign_transaction(tx, private_key=key)
    tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
    print("Issued tokens tx:", tx_hash.hex())
