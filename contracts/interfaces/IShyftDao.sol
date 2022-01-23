// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/**
 * @title ShyftDao test interface
 * @dev WARNING Only for testing purposes.
 */
interface IShyftDao {
    function getDaoMultiplier() external view returns (uint256);
}
