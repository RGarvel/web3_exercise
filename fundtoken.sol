// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken{
    // 1. 通证的名字
    // 2. 通证的简称
    // 3. 通证的发行数量
    // 4. owner的地址
    // 5. balance (mapping address => uint256)
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balance;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    // mint: 获取通证
    function mint(uint256 amountToMint) public {
        balance[msg.sender] += amountToMint;
        totalSupply += amountToMint;
    }

    // transfer: transfer 通证
    function transfer(address payee, uint256 amountToTransfer) public {
        require(balance[msg.sender] >= amountToTransfer, "no enough balance");
        balance[msg.sender] -= amountToTransfer;
        balance[payee] += amountToTransfer;
    }
    // balanceOf: 查看通证
    function balanceOf(address account) public view returns (uint256) {
        return balance[account];
    }
}