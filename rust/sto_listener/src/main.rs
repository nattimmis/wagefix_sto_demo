use dotenv::dotenv;
use std::env;
use web3::contract::{Contract, Options};
use web3::transports::Http;
use web3::types::{Address, U256};
use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::Message;
use serde::Deserialize;

#[derive(Deserialize)]
struct WageEvent {
    user: String,
    amount: u64,
}

#[tokio::main]
async fn main() -> web3::Result<()> {
    dotenv().ok();
    let kafka_broker = env::var("KAFKA_BROKER").unwrap_or("localhost:9092".into());
    let consumer: StreamConsumer = ClientConfig::new()
        .set("group.id", "sto_rust_agent")
        .set("bootstrap.servers", &kafka_broker)
        .create()
        .expect("Failed to create Kafka consumer");

    consumer.subscribe(&["wage-earned"]).expect("Failed to subscribe");

    let web3 = web3::Web3::new(Http::new(&env::var("WEB3_PROVIDER").unwrap())?);
    let abi = include_bytes!("contracts/WageFixSTO.abi.json");
    let contract_addr: Address = env::var("CONTRACT_ADDRESS").unwrap().parse().unwrap();
    let sender: Address = env::var("WALLET_ADDRESS").unwrap().parse().unwrap();
    let contract = Contract::from_json(web3.eth(), contract_addr, abi).unwrap();

    println!("🚀 Listening for wage events...");

    while let Ok(msg) = consumer.recv().await {
        if let Some(payload) = msg.payload() {
            if let Ok(event) = serde_json::from_slice::<WageEvent>(payload) {
                println!("⛏️  Wage event: {} earns {}", event.user, event.amount);
                let to: Address = event.user.parse().unwrap();
                let tokens = U256::from(event.amount);

                match contract
                    .call("issueTokens", (to, tokens), sender, Options::default())
                    .await
                {
                    Ok(_) => println!("✅ Issued {} tokens to {}", event.amount, event.user),
                    Err(e) => eprintln!("❌ Issue failed: {:?}", e),
                }
            }
        }
    }
    Ok(())
}
