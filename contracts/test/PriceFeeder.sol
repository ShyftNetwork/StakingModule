// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PriceFeeder test contract
 * @dev WARNING Only for testing purposes.
 */
contract PriceFeeder is Ownable {
    uint256 private currentPrice;
    uint256 private marketAveragePrice;

    function updatePrices(uint256 currentPrice_, uint256 marketAveragePrice_) external onlyOwner {
        currentPrice = currentPrice_;
        marketAveragePrice = marketAveragePrice_;
    }

    function getCurrentPrice() external view returns (uint256) {
        return currentPrice;
    }

    function getMarketAveragePrice() external view returns (uint256) {
        return marketAveragePrice;
    }
}
