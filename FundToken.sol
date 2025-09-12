// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    // 1. 通证的名字
    // 2. 通证的简称
    // 3. 通证的发行数量
    // 4. owner地址
    // 5. balance (记录各address的balance数量，是一个mapping：address => uint256
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balcances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    // mint: 获取通证
    function mint(uint256 amountToMint) public {
        balcances[msg.sender] += amountToMint;
        totalSupply += amountToMint;
    }
    // transfer: taransfer通证
    function transfer(address payee, uint256 amount) public {
        require(balcances[msg.sender] >= amount, "You do not have enough balance");
        balcances[msg.sender] -= amount;
        balcances[payee] += amount;
    }
    // balanceOf: 查看某个抵制的通证
    function balanceOf(address account) public view returns(uint256) {
        return balcances[account];
    }
}