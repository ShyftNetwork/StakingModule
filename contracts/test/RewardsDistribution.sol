// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";

import {IShyftStaking} from '../interfaces/IShyftStaking.sol';

/**
 * @title RewardsDistribution test contract
 * @dev WARNING Only for testing purposes.
 */
contract RewardsDistribution is Ownable {
    IShyftStaking public shyftStaking;

    uint256 constant REWARD_AMOUNT = 5000000 ether;

    receive() external payable {}

    function setShyftStaking(address shyftStaking_) external onlyOwner {
        shyftStaking = IShyftStaking(shyftStaking_);
    }

    function provideRewards() external onlyOwner {
        shyftStaking.notifyRewardAmount{value: REWARD_AMOUNT}();
    }

    function getBalance() external view returns(uint256 balance) {
        balance = address(this).balance;
    }
}
