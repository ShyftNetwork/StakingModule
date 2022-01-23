/* eslint @typescript-eslint/no-var-requires: "off" */
const {time} = require('@openzeppelin/test-helpers');
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';

export const getTransactionTimestamp = async (
  txHash: string
): Promise<BigNumber> => {
  const blockNumber = (await ethers.provider.getTransaction(txHash))
    .blockNumber;

  if (blockNumber == null) return BigNumber.from(0);

  const timestamp = (await ethers.provider.getBlock(blockNumber)).timestamp;

  return BigNumber.from(timestamp);
};

export const getCurrentTimestamp = async (): Promise<BigNumber> => {
  const now = await time.latest();
  return now;
};

export const advanceTime = async (
  provider: any,
  seconds: number
): Promise<void> => {
  await provider.send('evm_increaseTime', [seconds]);
};

export const advanceBlock = async (provider: any): Promise<void> => {
  await provider.send('evm_mine', []);
};

export const advanceMultipleBlocks = async (
  provider: any,
  numOfBlocks: number
): Promise<void> => {
  for (let i = 0; i < numOfBlocks; i++) {
    await provider.send('evm_mine', []);
  }
};

export const increaseTime = async (
  provider: any,
  seconds: number
): Promise<void> => {
  await advanceBlock(provider);
  await advanceTime(provider, seconds);
};
