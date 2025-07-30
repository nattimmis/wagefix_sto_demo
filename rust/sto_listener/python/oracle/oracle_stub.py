import time
import json
from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers='localhost:9092', value_serializer=lambda v: json.dumps(v).encode('utf-8'))

while True:
    valuation = {
        "asset": "Whiskey Barrels",
        "price_usd": 125000,
        "timestamp": time.time()
    }
    producer.send("sto-events", valuation)
    print("📤 Sent valuation:", valuation)
    time.sleep(10)
