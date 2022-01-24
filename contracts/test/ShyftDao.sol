// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ShyftDao test contract
 * @dev WARNING Only for testing purposes.
 */
contract ShyftDao is Ownable {
    uint256 private daoMultiplier = 1 ether;

    function updateDaoMultiplier(uint256 daoMultilpier_) external onlyOwner {
        daoMultiplier = daoMultilpier_;
    }

    function getDaoMultiplier() external view returns (uint256) {
        return daoMultiplier;
    }
}
