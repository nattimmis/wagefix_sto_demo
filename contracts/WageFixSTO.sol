// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WageFixSTO is ERC20Burnable, Ownable {
    mapping(address => bool) public isWhitelisted;

    constructor() ERC20("WageFix Equity Token", "WFET") {
        _mint(msg.sender, 0);
    }

    function whitelistInvestor(address investor) external onlyOwner {
        isWhitelisted[investor] = true;
    }

    function removeInvestor(address investor) external onlyOwner {
        isWhitelisted[investor] = false;
    }

    function issueTokens(address to, uint256 amount) external onlyOwner {
        require(isWhitelisted[to], "Not KYC-approved");
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(isWhitelisted[to], "Recipient not KYC-approved");
        return super.transfer(to, amount);
    }

    function redeemTokens(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
