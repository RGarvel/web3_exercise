// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// FundMe合约
// 1. 让FundMe的参与者，基于mapping来领取相应数量的通证
// 2. 让FundMe的参与者可以transfer通证
// 3. 在使用完成以后，需要烧毁相应通证

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./fundme.sol";

contract fundTokenERC20 is ERC20{
    FundMe fundMe;
    constructor(address fundMeAddr) ERC20("FundTokenOnERC20", "FT") {
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public {
        require(fundMe.fundersToAccount(msg.sender) >= amountToMint, "No enough Tokens");
        require(fundMe.getFundSuccess(), "The fund me is not completed yet"); //getter
        _mint(msg.sender, amountToMint);
        fundMe.setFunderToAmount(msg.sender, fundMe.fundersToAccount(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public {
        // complete claim
        require(balanceOf(msg.sender) >= amountToClaim, "You do not have enough balance to claim");
        /* to add */
        //burn amountToClaimTokens
        _burn(msg.sender, amountToClaim);
    }
}