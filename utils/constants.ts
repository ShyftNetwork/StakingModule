import {BigNumber} from 'ethers';
import {ethers} from 'hardhat';

export const REWARDS_AMOUNT = ethers.utils.parseEther('1337');
export const REWARDS_DURATION = 60 * 60 * 24 * 28;
export const PREPURCHASERS_AFTER_PERIOD = 0;
export const UNBONDING_PERIOD = 60 * 60 * 24 * 28;
export const NORMAL_REWARD_RATE_PER_SECOND = 0.00001653439153439;
export const LOWEST_VOTING_BOUND_PRICE = ethers.utils.parseEther('0.1');
export const CURRENT_PRICE = ethers.utils.parseEther('0.025');
export const LOW_AVERAGE_PRICE = ethers.utils.parseEther('0.02');
export const MID_AVERAGE_PRICE = ethers.utils.parseEther('0.0225');
export const HIGH_AVERAGE_PRICE = ethers.utils.parseEther('0.025');
export const DAO_MULTIPLIER = ethers.utils.parseEther('0.5');
