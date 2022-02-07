import {deployments, ethers, getNamedAccounts} from 'hardhat';
import {Contract} from 'ethers';
import {ContractReceipt, ContractTransaction} from 'ethers';
import {BigNumber} from 'ethers';

export const getSigners = async () => {
  const signers = await ethers.getSigners();

  return {
    deployerSigner: signers[0],
    proxyOwnerSigner: signers[1],
    normalStaker1Signer: signers[2],
    normalStaker2Signer: signers[3],
    normalStaker3Signer: signers[4],
    prePurchaser1Signer: signers[5],
    prePurchaser2Signer: signers[6],
    prePurchaser3Signer: signers[7],
    rewardProviderSigner: signers[8],
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

// Rounding with precision of 10
export const formatAndRoundBigNumber = async (inputNumber: BigNumber): Promise<Number> => {
  const number = Number(ethers.utils.formatEther(inputNumber));
  return Math.round(number * 10000000000) / 10000000000;
}

// Rounding with precision of 10
export const roundNumber = async (inputNumber: Number): Promise<Number> => {
  const number = Number(inputNumber);
  return Math.round(number * 10000000000) / 10000000000;
}
