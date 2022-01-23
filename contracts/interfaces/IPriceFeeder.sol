// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/**
 * @title PriceFeeder test interface
 * @dev WARNING Only for testing purposes.
 */
interface IPriceFeeder {
    function getCurrentPrice() external view returns (uint256);

    function getMarketAveragePrice() external view returns (uint256);
}
