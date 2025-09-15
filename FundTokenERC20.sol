// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

//FundMe
// 1. 让FundMe的参与者基于mapping领取通证
// 2. 让FundMe的参与者transfer通证(ERC20已经实现）
// 3. 在使用完成后，burn通证
contract FundTokenERC20 is ERC20 {
    FundMe fundMe;
    constructor(address fundMeAddr) ERC20("FundTokenERC20", "FT"){
        fundMe = FundMe(fundMeAddr);
    }

    function mint (uint256 amountToMint) public {
        require(fundMe.fundersToAmount(msg.sender) >= amountToMint, "You can not mint this many tokens");
        require(fundMe.getFundSuccess(), "FundMe has not completed yet"); // getter
        _mint(msg.sender , amountToMint);
        fundMe.setFundersToAmount(msg.sender, fundMe.fundersToAmount(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public {
        // complete claim
        require(balanceOf(msg.sender) >= amountToClaim, "You do not have enough ERC20 tokens to claim");
        require(fundMe.getFundSuccess(), "FundMe has not completed yet"); // getter

        /* to add */
        //burn amountToClaim Tokens
        _burn(msg.sender, amountToClaim);
    }
}
