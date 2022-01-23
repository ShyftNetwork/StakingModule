// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import {IShyftStaking} from '../interfaces/IShyftStaking.sol';

/**
 * @title RewardsDistribution test contract
 * @dev WARNING Only for testing purposes.
 */
contract RewardsDistribution {
    IShyftStaking public shyftStaking;

    uint256 constant REWARD_AMOUNT = 10 ether;

    receive() external payable {}

    function setShyftStaking(address shyftStaking_) external {
        shyftStaking = IShyftStaking(shyftStaking_);
    }

    function provideRewards() external {
        shyftStaking.notifyRewardAmount{value: REWARD_AMOUNT}();
    }
}
