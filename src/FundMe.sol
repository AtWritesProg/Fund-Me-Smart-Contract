//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD=5*1e18;
    AggregatorV3Interface private s_priceFeed;


    address[] private s_funders;
    mapping(address funder=> uint256 amountFunded)private s_addressToAmountFunded;

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,"Didn't receive enough value");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender]= s_addressToAmountFunded[msg.sender] + msg.value;
    }
    

    address private immutable i_owner;
    constructor(address priceFeedAddress){
        s_priceFeed= AggregatorV3Interface(priceFeedAddress);
        i_owner= msg.sender;
    }

    function cheaperWithdraw() public onlyOwner{
        uint256 fundersCount=s_funders.length;
        for(uint256 funderIndex=0; funderIndex<fundersCount; funderIndex++){
            address funder=s_funders[funderIndex];
            s_addressToAmountFunded[funder]=0;
        }
        s_funders=new address[](0);
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "Call Failed");
    }
    function withdraw() public onlyOwner{
        for(uint256 funderIndex=0; funderIndex<s_funders.length; funderIndex++){
         address funder=s_funders[funderIndex];
         s_addressToAmountFunded[funder]= 0;
        //  payable(msg.sender).transfer(address(this).balance);
        }
        s_funders= new address[](0);

        //withdraw
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "Call Failed");
        
    }
    
    modifier onlyOwner() {
        if(msg.sender!=i_owner){
            revert FundMe__NotOwner();
        }
        _;
    }
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }

    function getAddressToAmoundFunded(address fundingAddress) external view returns(uint256){
        return s_addressToAmountFunded[fundingAddress];
    }
    function getFunder(uint256 index) external view returns(address){
        return s_funders[index];
    }
    function getOwner() external view returns(address){
        return i_owner;
    }
}




