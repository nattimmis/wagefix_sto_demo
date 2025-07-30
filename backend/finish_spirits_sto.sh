from pathlib import Path

script = """#!/bin/bash

echo "🧠 [1/4] Setting up Ngrok tunnel for FastAPI backend..."
read -p "Enter your local IP address (e.g. 192.168.1.24): " IP
read -p "Enter your Ngrok authtoken (leave blank to skip): " TOKEN

# Install ngrok if not present
if ! command -v ngrok &> /dev/null; then
  echo "📦 Installing ngrok..."
  curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc > /dev/null
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
  sudo apt update && sudo apt install ngrok
fi

# Authenticate if token provided
if [[ ! -z "$TOKEN" ]]; then
  ngrok config add-authtoken "$TOKEN"
fi

# Launch tunnel
echo "🚀 Launching ngrok..."
pkill ngrok
nohup ngrok http 8000 > backend/ngrok.log 2>&1 &

sleep 3
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-z0-9]*\\.ngrok-free\\.app')

echo "✅ Ngrok tunnel: $NGROK_URL"

echo "🔗 Updating React Native OnboardScreen.js with new API URL..."
sed -i "s|http://.*:8000|$NGROK_URL|g" mobile/app/screens/OnboardScreen.js

echo "🪙 [2/4] Creating WalletScreen.js..."
cat <<EOF > mobile/app/screens/WalletScreen.js
import React from 'react';
import { View, Button, Text } from 'react-native';

export default function WalletScreen() {
  const mint = async () => {
    const res = await fetch('$NGROK_URL/ipfs_metadata');
    const json = await res.json();
    alert('Minted RWA Token: ' + JSON.stringify(json));
  };

  return (
    <View style={{ padding: 20 }}>
      <Button title="Simulate Mint RWA Token" onPress={mint} />
      <Text>Connect Wallet: [Placeholder]</Text>
    </View>
  );
}
EOF

echo "📄 [3/4] Creating LegalPreviewScreen.js..."
cat <<EOF > mobile/app/screens/LegalPreviewScreen.js
import React from 'react';
import { View, Button, Linking } from 'react-native';

export default function LegalPreviewScreen() {
  return (
    <View style={{ padding: 20 }}>
      <Button title="Open Legal Terms (IPFS)" onPress={() => {
        Linking.openURL("https://ipfs.io/ipfs/bafy.../spirits_token_terms.pdf")
      }} />
    </View>
  );
}
EOF

echo "✅ [4/4] Committing all changes to Git..."
cd ~/Desktop/hyperlog/wagefix-sto-demo
git add .
git commit -m "feat: Add wallet + legal preview screens, auto inject ngrok API URL, simulate mint"
git push origin main

echo "🎉 All 4 phases completed. Test OnboardScreen + WalletScreen on device using new ngrok backend!"
"""

# Save this master script to disk
scripts_dir = Path.home() / "Desktop" / "hyperlog" / "wagefix-sto-demo" / "scripts"
scripts_dir.mkdir(parents=True, exist_ok=True)
script_path = scripts_dir / "finish_spirits_sto.sh"
script_path.write_text(script)
script_path.chmod(0o755)

import pandas as pd
import ace_tools as tools
tools.display_dataframe_to_user(
    name="Spirits STO Master Finisher Script",
    dataframe=pd.DataFrame([[str(script_path)]], columns=["Run this script"])
)
