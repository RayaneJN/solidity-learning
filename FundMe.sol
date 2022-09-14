// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    
    mapping(address => uint256) public addressToAmountFunded;
    address[] funders;


    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // executed at the deployement of the contract
    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need more ETH");   // give the money back and stop the execution

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);

        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }

    function getPrice() internal view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        (,int256 answer,,,) = priceFeed.latestRoundData();

         return uint256(answer * 10**10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
             uint256 ethPrice = getPrice();
             uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10**18);

             return ethAmountInUsd;
    }
}
