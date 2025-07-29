#!/bin/bash
# Issue tokens from CLI via curl/web3 or script call

echo "Issuing 100 tokens to $1"

# Replace this with actual Python or Rust call
python3 kafka/wage_to_sto_producer.py --manual --user "$1" --amount 100
