// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../ShyftStaking.sol";

/**
 * @title StakingV2 contract
 * @dev WARNING Only for testing purposes, we added a couple of new methods and storage variables to check contract upgrade works fine
 */
contract StakingV2 is ShyftStaking {
    uint256 public test1;

    function testFunction() public pure returns (uint256) {
        return 1;
    }
}
