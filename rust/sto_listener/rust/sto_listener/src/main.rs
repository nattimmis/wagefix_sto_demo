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
