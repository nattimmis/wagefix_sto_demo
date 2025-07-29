# Kafka dividend emitter (Python)
from kafka import KafkaProducer
import json
producer = KafkaProducer(bootstrap_servers='localhost:9092', value_serializer=lambda m: json.dumps(m).encode('utf-8'))
producer.send("sto-dividend-paid", {"user": "0xabc", "amount": 100})
