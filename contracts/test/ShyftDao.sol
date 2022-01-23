// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/**
 * @title ShyftDao test contract
 * @dev WARNING Only for testing purposes.
 */
contract ShyftDao {
    uint256 private daoMultiplier = 1 ether;

    function updateDaoMultiplier(uint256 daoMultilpier_) external {
        daoMultiplier = daoMultilpier_;
    }

    function getDaoMultiplier() external view returns (uint256) {
        return daoMultiplier;
    }
}
