
#!/bin/bash

echo "🚀 Starting full Mobius STO scaffold..."

# 1. Set up Rust STO Kafka Listener
echo "📦 Setting up Rust STO Listener..."
mkdir -p rust/sto_listener/src
cat > rust/sto_listener/Cargo.toml <<EOF
[package]
name = "sto_listener"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
web3 = "0.19.0"
rdkafka = { version = "0.29", features = ["tokio"] }
serde_json = "1.0"
ethereum-types = "0.14"
ethabi = "18.0"
EOF

cat > rust/sto_listener/src/main.rs <<EOF
use web3::types::U256;
use rdkafka::consumer::StreamConsumer;
use rdkafka::message::BorrowedMessage;
use rdkafka::ClientConfig;
use tokio_stream::StreamExt;

#[tokio::main]
async fn main() {
    let consumer: StreamConsumer = ClientConfig::new()
        .set("group.id", "sto-group")
        .set("bootstrap.servers", "localhost:9092")
        .create()
        .expect("Consumer creation failed");

    consumer.subscribe(&["sto-events"]).unwrap();

    while let Some(msg_result) = consumer.recv().await {
        match msg_result {
            Ok(msg) => {
                println!("📨 Received message: {:?}", msg);
                // Here we would parse and mint the token
            },
            Err(e) => println!("⚠️ Kafka error: {}", e),
        }
    }
}
EOF

# 2. Set up Python Oracle Stub
echo "🐍 Creating Python Oracle stub..."
mkdir -p python/oracle
cat > python/oracle/oracle_stub.py <<EOF
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
EOF

# 3. Generate React Frontend Stub
echo "🌐 Bootstrapping React frontend..."
mkdir -p react-frontend
cd react-frontend
npx create-react-app . --template cra-template
cd ..

echo "✅ All components scaffolded. You can now:"
echo "1. Run Rust with: cd rust/sto_listener && cargo run"
echo "2. Run Python Oracle with: python3 python/oracle/oracle_stub.py"
echo "3. Run React Frontend with: cd react-frontend && npm start"
