#!/bin/bash
set -e

echo "🚀 Finalizing Spirits STO Demo..."

# Step 1: Generate README.md
cat <<EOF > ~/Desktop/hyperlog/wagefix-sto-demo/README.md
# 🍷 Spirits-backed Security Token (STO) — Mobius Style

A full-stack demo for a compliant Real-World Asset (RWA) tokenization flow built on:

- ✅ ERC-3643 Token (KYC-enabled)
- ✅ FastAPI Backend for KYC & IPFS
- ✅ React Native Mobile App (Investor onboarding)
- ✅ Chainlink-compatible valuation Oracle
- ✅ Legal docs hosted on IPFS
- ✅ Swiss/US dual legal entity structure

---

## 🧪 Demo Flow

1. Upload KYC (passport + selfie)
2. Simulated validator approval
3. RWA metadata is uploaded to IPFS
4. User mints token via mobile wallet screen
5. Legal documents and ISIN previewed via app

---

## 📂 Key Directories

- \`chain/\` — Solidity ERC-3643, IPFS, deployment scripts
- \`backend/\` — FastAPI server with file upload + metadata
- \`mobile/\` — React Native UI (Onboard, Wallet, Legal)

---

## ▶️ Quickstart (Local Testing)

\`\`\`bash
# Backend
cd backend && uvicorn main:app --reload

# Tunnel API
ngrok http 8000

# React Native App
cd mobile && yarn start
\`\`\`

---

## 🔐 Compliance & Custody

- KYC: Integrated hooks (zkKYC ready)
- Custody: Plug & play Taurus/Sygnum
- Oracles: Chainlink-ready structure
- Token Classification: FINMA-compliant mapping

---

## 🤖 LLM-Audited Reporting (GPT Hook)

Smart contract events are piped to GPT to generate:
- Monthly audit summaries
- Investor sentiment dashboards
- Deal exposure reports
EOF

echo "✅ README.md generated"

# Step 2: Add legal folder and sample docs
mkdir -p ~/Desktop/hyperlog/wagefix-sto-demo/legal
touch ~/Desktop/hyperlog/wagefix-sto-demo/legal/spirits_token_terms.pdf
echo '{"asset": "Barrel-aged Whisky", "value": "CHF 2500"}' > ~/Desktop/hyperlog/wagefix-sto-demo/legal/spirits_token_metadata.json
echo "✅ Legal doc and metadata added"

# Step 3: Git commit and push
cd ~/Desktop/hyperlog/wagefix-sto-demo
git add .
git commit -m "feat: Finalize Spirits STO MVP for demo (README, legal, structure)"
git push origin main
echo "✅ GitHub updated"

echo "🎉 Spirits STO demo is now polished and published!"
