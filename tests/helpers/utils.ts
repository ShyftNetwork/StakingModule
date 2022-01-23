import {deployments, ethers, getNamedAccounts} from 'hardhat';
import {Contract} from 'ethers';
import {ContractReceipt, ContractTransaction} from 'ethers';

export const getSigners = async () => {
  const signers = await ethers.getSigners();
  return {
    deployerSigner: signers[0],
  };
};

export const getContracts = async () => {
  const stakingContract = await ethers.getContract('ShyftStaking');
  const priceFeederContract = await ethers.getContract('PriceFeeder');
  const rewardsDistributionContract = await ethers.getContract('RewardsDistribution');
  const shyftDaoContract = await ethers.getContract('ShyftDao');

  return {
    stakingContract,
    priceFeederContract,
    rewardsDistributionContract,
    shyftDaoContract,
  };
};
