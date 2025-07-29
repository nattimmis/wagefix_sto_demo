# Auto-dividend emitter based on token balances

from kafka import KafkaProducer
import json

producer = KafkaProducer(bootstrap_servers='localhost:9092',
                         value_serializer=lambda m: json.dumps(m).encode('utf-8'))

# Simulate dividend payout
producer.send("sto-dividend-paid", {
    "user": "0x123abc...",
    "amount": 50
})

print("✅ Dividend sent to topic.")
