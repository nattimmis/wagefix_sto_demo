#!/bin/bash
echo "🩺 Healing Rust STO Listener..."

MAIN_RS="~/Desktop/hyperlog/wagefix-sto-demo/rust/sto_listener/src/main.rs"
MAIN_RS_REAL="$HOME/Desktop/hyperlog/wagefix-sto-demo/rust/sto_listener/src/main.rs"

# 1. Fix incorrect ABI path
ABI_SRC="$HOME/Desktop/hyperlog/wagefix-sto-demo/contracts/WageFixSTO.abi.json"
ABI_DST="$HOME/Desktop/hyperlog/wagefix-sto-demo/rust/sto_listener/src/contracts/WageFixSTO.abi.json"

mkdir -p "$(dirname "$ABI_DST")"
cp "$ABI_SRC" "$ABI_DST" && echo "✅ ABI file moved to expected Rust path"

# 2. Patch main.rs using sed
sed -i 's|include_bytes!.*|include_bytes!("contracts/WageFixSTO.abi.json");|' "$MAIN_RS_REAL"

# 3. Fix Kafka recv loop (match Result not Option)
sed -i 's|while let Some(Ok(msg)) = consumer.recv().await {|while let Ok(msg) = consumer.recv().await {|' "$MAIN_RS_REAL"

# 4. Remove unused H160 if present
sed -i 's|, H160||' "$MAIN_RS_REAL"

echo "✅ Rust source healed. Now rebuilding..."

# 5. Rebuild the project
cd "$HOME/Desktop/hyperlog/wagefix-sto-demo/rust/sto_listener" && cargo build && echo "✅ Build complete. You can now run: cargo run"
