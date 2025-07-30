#!/bin/bash
set -e

echo "🔐 Phase 9: Generate backend .env"
cd ~/Desktop/hyperlog/wagefix-sto-demo/backend

cat <<EOF > .env
PRIVATE_KEY=your_private_key_here
RPC_URL=https://sepolia.base.org
CONTRACT_ADDRESS=0xYourDeployedContract
PINATA_API_KEY=your_api_key_here
PINATA_SECRET_API_KEY=your_secret_here
EOF
echo "✅ .env file created"

echo "🌍 Phase 10: Load .env into mint_token.py"
cat <<EOF > load_env.py
from dotenv import load_dotenv
import os

load_dotenv()

print("Private Key:", os.getenv("PRIVATE_KEY")[:6] + "...")  # Masked
EOF
echo "✅ .env loader ready"

echo "📈 Phase 11: Simulate Chainlink price feed API"
cd ~/Desktop/hyperlog/wagefix-sto-demo/backend
cat <<EOF > mock_price_oracle.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/price")
def get_price():
    return {"asset": "SPIRITS", "price_usd": 183.25}
EOF
echo "✅ Mock Chainlink oracle ready on /price"

echo "💳 Phase 12: Link wallet trigger to mint"
cd ~/Desktop/hyperlog/wagefix-sto-demo/mobile/app/screens
cat <<EOF > MintTrigger.js
import axios from 'axios'

export const triggerMint = async (wallet, tokenId) => {
  const res = await axios.post('http://localhost:8000/mint', {
    address: wallet,
    token_id: tokenId
  });
  return res.data.tx_hash;
};
EOF
echo "✅ Wallet trigger added"

echo "🧪 Phase 13: Simulate zkKYC response JSON"
cd ~/Desktop/hyperlog/wagefix-sto-demo/legal
cat <<EOF > zkkyc_pass.json
{
  "wallet": "0x123...abc",
  "passport_valid": true,
  "face_match": true,
  "country": "CH",
  "pep_check": false
}
EOF
echo "✅ zkKYC simulated"

echo "📦 Phase 14: Push all final files to GitHub"
cd ~/Desktop/hyperlog/wagefix-sto-demo
git add .
git commit -m "feat: Finalize STO - wallet trigger, zkKYC mock, .env config, oracle"
git push origin main
echo "✅ GitHub updated"
