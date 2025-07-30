import axios from 'axios'

export const triggerMint = async (wallet, tokenId) => {
  const res = await axios.post('http://localhost:8000/mint', {
    address: wallet,
    token_id: tokenId
  });
  return res.data.tx_hash;
};
