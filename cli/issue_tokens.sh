#!/bin/bash
# CLI: issue fixed token quantity to address
echo "Issuing ${2:-100} tokens to ${1}"
python3 kafka/wage_to_sto_producer.py --manual --user "$1" --amount "${2:-100}"
