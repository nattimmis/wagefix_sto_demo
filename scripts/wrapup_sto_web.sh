#!/bin/bash
set -e

echo "📁 Create frontend folder"
mkdir -p ~/Desktop/hyperlog/wagefix-sto-demo/frontend

echo "🌍 Generate investor landing page HTML"
cat <<EOF > ~/Desktop/hyperlog/wagefix-sto-demo/frontend/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Spirits STO Demo</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; margin: 2em; background: #f6f6f6; }
    h1 { color: #222; }
    .card { background: white; padding: 2em; border-radius: 10px; box-shadow: 0 0 10px #ccc; max-width: 700px; margin: auto; }
    input, button { padding: 0.5em; margin: 0.5em 0; width: 100%; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🥃 Spirits-Backed Security Token</h1>
    <p>Token ID: <strong>SPIRIT-2025-001</strong></p>
    <p>Live Price (USD): <span id="price">Loading...</span></p>

    <h3>KYC Upload</h3>
    <input type="file" id="kycDoc">
    <button onclick="uploadKYC()">Submit KYC</button>

    <h3>Minted Token Status</h3>
    <button onclick="checkMint()">Check Status</button>
    <pre id="status"></pre>

    <h3>View Legal Document</h3>
    <a href="https://ipfs.io/ipfs/QmPLACEHOLDERCID" target="_blank">View Legal PDF</a>

    <h3>Wallet Demo</h3>
    <button onclick="alert('WalletConnect coming soon')">Connect Wallet</button>
  </div>

  <script>
    async function fetchPrice() {
      const res = await fetch("http://localhost:8000/price");
      const data = await res.json();
      document.getElementById("price").innerText = "\$" + data.price_usd;
    }
    async function checkMint() {
      const res = await fetch("http://localhost:8000/mint_status");
      const data = await res.json();
      document.getElementById("status").innerText = JSON.stringify(data, null, 2);
    }
    async function uploadKYC() {
      alert("Mock KYC submitted. Token auto-mint logic already run.");
    }
    fetchPrice();
  </script>
</body>
</html>
EOF

echo "🧾 Generate dummy legal document PDF"
echo "This document represents proof of tokenized asset rights." > legal.txt
enscript legal.txt -o - | ps2pdf - ~/Desktop/hyperlog/wagefix-sto-demo/legal/spirit_token_terms.pdf
rm legal.txt

echo "🚀 Serve frontend on port 7777"
cd ~/Desktop/hyperlog/wagefix-sto-demo/frontend
nohup python3 -m http.server 7777 > ../frontend.log 2>&1 &

echo "📦 Final GitHub commit"
cd ~/Desktop/hyperlog/wagefix-sto-demo
git add .
git commit -m "feat: Add investor landing page, serve via Python, legal PDF prep"
git push origin main
