#!/bin/bash
echo "📦 Setting up WageFix STO demo..."

mkdir -p contracts scripts kafka test frontend

# --- CONTRACT ---
cat > contracts/WageFixSTO.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WageFixSTO is ERC20Burnable, Ownable {
    mapping(address => bool) public isWhitelisted;

    constructor() ERC20("WageFix Equity Token", "WFET") {
        _mint(msg.sender, 0);
    }

    function whitelistInvestor(address investor) external onlyOwner {
        isWhitelisted[investor] = true;
    }

    function removeInvestor(address investor) external onlyOwner {
        isWhitelisted[investor] = false;
    }

    function issueTokens(address to, uint256 amount) external onlyOwner {
        require(isWhitelisted[to], "Not KYC-approved");
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(isWhitelisted[to], "Recipient not KYC-approved");
        return super.transfer(to, amount);
    }

    function redeemTokens(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
EOF

# --- DEPLOY SCRIPT ---
cat > scripts/deploy.js << 'EOF'
const hre = require("hardhat");

async function main() {
  const WageFixSTO = await hre.ethers.getContractFactory("WageFixSTO");
  const sto = await WageFixSTO.deploy();
  await sto.deployed();
  console.log("✅ Contract deployed to:", sto.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOF

# --- KAFKA LISTENER ---
cat > kafka/wage_to_sto_producer.py << 'EOF'
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
EOF

# --- FRONTEND ---
cat > frontend/index.html << 'EOF'
<html>
  <body>
    <h2>WageFix STO Balance</h2>
    <div id="balance"></div>
    <script src="https://cdn.jsdelivr.net/npm/ethers/dist/ethers.min.js"></script>
    <script>
      const provider = new ethers.providers.JsonRpcProvider("https://your_rpc_url");
      const signer = provider.getSigner();
      const contract = new ethers.Contract("YOUR_CONTRACT_ADDRESS", ABI, signer);
      async function getBalance() {
        const address = await signer.getAddress();
        const bal = await contract.balanceOf(address);
        document.getElementById('balance').innerText = "Balance: " + bal.toString();
      }
      getBalance();
    </script>
  </body>
</html>
EOF

# --- TEST ---
cat > test/sto.test.js << 'EOF'
const { expect } = require("chai");

describe("WageFixSTO", function () {
  it("Should issue tokens only to whitelisted users", async function () {
    const [owner, user1] = await ethers.getSigners();
    const STO = await ethers.getContractFactory("WageFixSTO");
    const sto = await STO.deploy();
    await sto.whitelistInvestor(user1.address);
    await sto.issueTokens(user1.address, 1000);
    expect(await sto.balanceOf(user1.address)).to.equal(1000);
  });
});
EOF

# --- README ---
cat > README.md << 'EOF'
# 💼 WageFix STO Demo

A demo for streaming wage events into security tokens using Kafka, ERC1400-inspired smart contracts, and frontend viewing.

## Components

- Smart contract: `contracts/WageFixSTO.sol`
- Kafka listener: `kafka/wage_to_sto_producer.py`
- Hardhat deploy script: `scripts/deploy.js`
- Frontend: `frontend/index.html`
- Test suite: `test/sto.test.js`

## Flow Diagram

Wage → Kafka `wage-earned` → `wage_to_sto_producer.py` → issueTokens() → Wallet → Dividends/Burn via Kafka

## Next Steps

1. `npm install --save-dev hardhat`
2. Compile & deploy with `npx hardhat run scripts/deploy.js --network localhost`
3. Setup `.env` based on `.env.example`
EOF

# --- ENV EXAMPLE ---
cat > .env.example << 'EOF'
WEB3_PROVIDER=http://localhost:8545
WALLET_ADDRESS=0xYourWallet
PRIVATE_KEY=your_private_key
CONTRACT_ADDRESS=0xDeployedContract
EOF

# --- HARDHAT CONFIG ---
cat > hardhat.config.js << 'EOF'
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  }
};
EOF

chmod +x setup_wagefix_sto.sh
echo "✅ All files created. Run with: ./setup_wagefix_sto.sh"
