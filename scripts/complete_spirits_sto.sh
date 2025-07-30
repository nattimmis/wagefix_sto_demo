#!/bin/bash
set -e

echo "🚀 Phase 1: Deploy ERC-3643 Smart Contract to Base Sepolia"

cd ~/Desktop/hyperlog/wagefix-sto-demo/chain

export PRIVATE_KEY="your_private_key_here"
export RPC_URL="https://sepolia.base.org"

npx hardhat compile
npx hardhat run --network baseSepolia scripts/deploy_token.js

echo "✅ Contract deployed to Base Sepolia"

echo "📦 Phase 2: Pin metadata to IPFS using Pinata API"

cd ~/Desktop/hyperlog/wagefix-sto-demo/legal

PINATA_API_KEY="your_api_key_here"
PINATA_SECRET_API_KEY="your_secret_here"

curl -X POST https://api.pinata.cloud/pinning/pinFileToIPFS \
  -H "pinata_api_key: $PINATA_API_KEY" \
  -H "pinata_secret_api_key: $PINATA_SECRET_API_KEY" \
  -F file=@spirits_token_metadata.json > ipfs_result.json

echo "✅ IPFS hash pinned and saved to ipfs_result.json"

echo "🆔 Phase 3: Attach mock ISIN to metadata"

ISIN="CH0001234567"
echo "{\"isin\": \"$ISIN\"}" >> spirits_token_metadata.json
echo "✅ ISIN field added"

echo "🔗 Phase 4: Connect backend mint_token logic"

cd ~/Desktop/hyperlog/wagefix-sto-demo/backend

cat <<EOF > mint_token.py
from web3 import Web3
import json, os

w3 = Web3(Web3.HTTPProvider(os.getenv("RPC_URL")))
acct = w3.eth.account.from_key(os.getenv("PRIVATE_KEY"))

with open("contract_abi.json") as f:
    abi = json.load(f)

contract_address = "0xYourContractAddressHere"
contract = w3.eth.contract(address=contract_address, abi=abi)

def mint(to_address, token_id):
    tx = contract.functions.mint(to_address, token_id).build_transaction({
        'from': acct.address,
        'nonce': w3.eth.get_transaction_count(acct.address),
        'gas': 200000,
        'gasPrice': w3.to_wei('2', 'gwei')
    })
    signed = acct.sign_transaction(tx)
    tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
    return tx_hash.hex()
EOF

echo "✅ Backend mint_token.py function written"

echo "🎉 All 4 tasks complete. You’re now ready to mint real tokens!"
