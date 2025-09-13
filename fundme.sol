//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


//1.创建一个收款函数
//2.记录投资人并查看
//3.在锁定期内，达到目标值，生产商可以提款
//4.在锁定期内，未达目标值，投资人可以在锁定期后退款

contract FundMe {
    mapping(address => uint256) public fundersToAccount;

    uint256 MINIMUM_VALUE = 100 * 10**18; //USD

    uint256 constant TARGET = 1000 * 10**18;

    AggregatorV3Interface internal dataFeed;

    address owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    address erc20Addr;

    bool public getFundSuccess = false;

    constructor(uint256 _lockTime) {
        // sepolia testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "YOU SHOULD FUND MORE ETH!!");
        require(block.timestamp < deploymentTimestamp + lockTime, "The lock period has ended");
        fundersToAccount[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethPrice * ethAmount) / (10**8);
    }

    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    function getFund() external windowClosed onlyOwner{
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached");
        // // transfer: transfer ETH and revert if tx failed
        // payable(msg.sender).transfer(address(this).balance);
        // // send: transfer ETH and return false if failed
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");
        // call: transfer ETH with data reutrn value of function and bool
        bool success;
        (success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transfer tx failed");
        getFundSuccess = true;
    }

    function refund() external windowClosed{
        require(convertEthToUsd(address(this).balance) < TARGET, "Target has reached");
        require(fundersToAccount[msg.sender] != 0, "You are not funder");
        bool success;
        (success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transfer tx failed");
        fundersToAccount[msg.sender] = 0;

    }

    function setFunderToAmount(address funder, uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr, "You do not have permission");
        fundersToAccount[funder] = amountToUpdate;
    }

    function setERC20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }

    modifier windowClosed() {
        require(block.timestamp >= deploymentTimestamp + lockTime, "The lock period has not ended");
        _;

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;


    }

}