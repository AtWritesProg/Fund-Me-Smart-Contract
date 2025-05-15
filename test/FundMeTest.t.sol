//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test{

    FundMe fundMe;
    uint256 constant SEND_VALUE=10 ether;
    uint256 constant STARTING_BALANCE=10 ether;
    uint256 constant GAS_PRICE=1;

    address immutable USER=makeAddr("user");    //mock user address


    function setUp() external{
        DeployFundMe deployFundMe=new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);    //fake money assignment
        vm.deal(fundMe.getOwner(), 10 ether);
    }

    function testMinimumDollar() public view {
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwner() public view{
        console.log("msg.sender",msg.sender);
        console.log("i_owner",fundMe.getOwner());
        assertEq(fundMe.getOwner(),msg.sender);
    }
    function testPriceFeedVersion() public view{
        uint256 version=fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughEth() public{
        vm.expectRevert();
        fundMe.fund();
    }
    function testFundUpdateFundedData() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded=fundMe.getAddressToAmoundFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
    function testAddsFundersToArray() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder=fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    function testWithDrawWithSingleFunder() public funded{
        uint256 OwnerBalanceIntial=fundMe.getOwner().balance;
        uint256 fundMeBalanceIntial=address(fundMe).balance;

        // uint256 gasStart=gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasUsed=(gasStart-gasleft())*tx.gasprice;
        // console.log("Gas Used",gasUsed);

        uint256 fundMeBalanceAfter=address(fundMe).balance;
        uint256 OwnerBalanceAfter=fundMe.getOwner().balance;
        assertEq(fundMeBalanceAfter,0);
        assertEq(OwnerBalanceIntial+fundMeBalanceIntial,OwnerBalanceAfter);
    }
    function testWithdrawFromMultipleFunders() public funded{
        //Create 10 Fake Funders
        uint160 funderCount=10;
        uint160 startIndex=1;

        for(uint160 i=startIndex;i<funderCount;i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 OwnerBalanceIntial=fundMe.getOwner().balance;
        uint256 fundMeBalanceIntial=address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 fundMeBalanceAfter=address(fundMe).balance;
        uint256 OwnerBalanceAfter=fundMe.getOwner().balance;
        assertEq(fundMeBalanceAfter,0);
        assertEq(OwnerBalanceIntial+fundMeBalanceIntial,OwnerBalanceAfter);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded{
        //Create 10 Fake Funders
        uint160 funderCount=10;
        uint160 startIndex=1;

        for(uint160 i=startIndex;i<funderCount;i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 OwnerBalanceIntial=fundMe.getOwner().balance;
        uint256 fundMeBalanceIntial=address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 fundMeBalanceAfter=address(fundMe).balance;
        uint256 OwnerBalanceAfter=fundMe.getOwner().balance;
        assertEq(fundMeBalanceAfter,0);
        assertEq(OwnerBalanceIntial+fundMeBalanceIntial,OwnerBalanceAfter);
    }
}