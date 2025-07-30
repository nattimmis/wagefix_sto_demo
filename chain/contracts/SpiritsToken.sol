// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SpiritsToken is ERC721URIStorage {
    uint256 public nextTokenId;
    address public admin;

    constructor() ERC721("Spirits RWA", "SPIRITS") {
        admin = msg.sender;
    }

    function mint(address to, string memory uri) external {
        require(msg.sender == admin, "Only admin can mint");
        _safeMint(to, nextTokenId);
        _setTokenURI(nextTokenId, uri);
        nextTokenId++;
    }
}
