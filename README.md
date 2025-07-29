# 💼 WageFix STO Demo

A demo for streaming wage events into security tokens using Kafka, ERC1400-inspired smart contracts, and frontend viewing.

## Components

- Smart contract: `contracts/WageFixSTO.sol`
- Kafka listener: `kafka/wage_to_sto_producer.py`
- Hardhat deploy script: `scripts/deploy.js`
- Frontend: `frontend/index.html`
- Test suite: `test/sto.test.js`

## Flow Diagram

Wage → Kafka `wage-earned` → `wage_to_sto_producer.py` → issueTokens() → Wallet → Dividends/Burn via Kafka

## Next Steps

1. `npm install --save-dev hardhat`
2. Compile & deploy with `npx hardhat run scripts/deploy.js --network localhost`
3. Setup `.env` based on `.env.example`
