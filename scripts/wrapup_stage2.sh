#!/bin/bash
set -e

echo "🚀 Phase 15: Launch backend + mock oracle (background)"
cd ~/Desktop/hyperlog/wagefix-sto-demo/backend
uvicorn main:app --port 8000 --host 0.0.0.0 &
python3 mock_price_oracle.py &

echo "🌐 Phase 16: Start ngrok and capture public HTTPS URL"
ngrok http 8000 > ngrok.log &
sleep 5
PUBLIC_URL=$(curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "🔗 ngrok URL: $PUBLIC_URL"

echo "🛠 Phase 17: Update React Native backend URL"
cd ~/Desktop/hyperlog/wagefix-sto-demo/mobile/app/api
cat <<EOF > config.js
export const BACKEND_URL = "$PUBLIC_URL";
EOF

echo "✅ Mobile app now points to live backend"

echo "🪙 Phase 18: Auto-mint token after passing KYC"
cd ~/Desktop/hyperlog/wagefix-sto-demo/backend
cat <<EOF > auto_mint.py
import requests
kyc = requests.get("http://localhost:8000/zkkyc_pass").json()
if kyc["passport_valid"] and not kyc["pep_check"]:
    mint = requests.post("http://localhost:8000/mint", json={
        "address": kyc["wallet"],
        "token_id": "SPIRIT-2025-001"
    })
    print("Minted:", mint.json())
EOF
python3 auto_mint.py

echo "🧾 Phase 19: Append investor to registry CSV"
echo "wallet,token_id,timestamp" > registry.csv
echo "0x123...abc,SPIRIT-2025-001,$(date)" >> registry.csv
mv registry.csv ~/Desktop/hyperlog/wagefix-sto-demo/legal/

echo "📦 Phase 20: Final push to GitHub"
cd ~/Desktop/hyperlog/wagefix-sto-demo
git add .
git commit -m "feat: Launch backend + mint + investor registry + mobile backend sync"
git push origin main
