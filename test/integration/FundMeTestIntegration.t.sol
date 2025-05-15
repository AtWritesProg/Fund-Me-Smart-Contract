//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interacton.s.sol";

contract FundMeTestIntergration is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 10 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    address immutable USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundME = new DeployFundMe();
        fundMe = deployFundME.run();
        vm.deal(USER, STARTING_BALANCE); //fake money assignment
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 balance = address(fundMe).balance;
        assertEq(balance, 0);
    }
}
