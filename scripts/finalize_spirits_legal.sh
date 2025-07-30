#!/bin/bash
set -e

echo "📄 Phase 5: Generate legal declaration PDF"
mkdir -p ~/Desktop/hyperlog/wagefix-sto-demo/legal
cd ~/Desktop/hyperlog/wagefix-sto-demo/legal

cat <<EOF > legal_declaration.txt
This document certifies that 100 bottles of aged single-malt whiskey are stored at Bonded Warehouse #7 in Geneva.
These bottles are backed by a tokenized security on Base Sepolia blockchain. The issuer is compliant with FINMA and SEC.
EOF

enscript legal_declaration.txt -o - | ps2pdf - legal_declaration.pdf
echo "✅ PDF generated: legal_declaration.pdf"

echo "🔐 Phase 6: Hash PDF with SHA256"
PDF_HASH=$(sha256sum legal_declaration.pdf | awk '{print $1}')
echo $PDF_HASH > pdf_hash.txt
echo "✅ PDF hash saved: $PDF_HASH"

echo "📡 Phase 7: Pin PDF to IPFS"
PINATA_API_KEY="your_api_key_here"
PINATA_SECRET_API_KEY="your_secret_here"

curl -X POST https://api.pinata.cloud/pinning/pinFileToIPFS \
  -H "pinata_api_key: $PINATA_API_KEY" \
  -H "pinata_secret_api_key: $PINATA_SECRET_API_KEY" \
  -F file=@legal_declaration.pdf > pinned_pdf.json

PDF_IPFS_HASH=$(jq -r '.IpfsHash' pinned_pdf.json)
echo "✅ IPFS hash pinned: $PDF_IPFS_HASH"

echo "📝 Phase 8: Add legalHash + legalLink to metadata"
jq --arg hash "$PDF_HASH" --arg link "ipfs://$PDF_IPFS_HASH" \
  '. + {legalHash: $hash, legalLink: $link}' \
  spirits_token_metadata.json > updated_metadata.json

mv updated_metadata.json spirits_token_metadata.json
echo "✅ Metadata updated with legal PDF hash and IPFS link"
