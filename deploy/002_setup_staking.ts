import {DeployFunction} from 'hardhat-deploy/types';
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';
import {expect} from 'chai';

import {CURRENT_PRICE, DAO_MULTIPLIER} from '../utils/constants';

const func: DeployFunction = async function () {
  const signers = await ethers.getSigners();
  const deployerSigner = signers[0];

  const shyftStakingContract = await ethers.getContract('ShyftStaking');
  const priceFeederContract = await ethers.getContract('PriceFeeder');
  const shyftDaoContract = await ethers.getContract('ShyftDao');
  const rewardsDistributionContract = await ethers.getContract('RewardsDistribution');

  await priceFeederContract.updatePrices(CURRENT_PRICE, CURRENT_PRICE);
  const currentPrice = await priceFeederContract.getCurrentPrice()
  const marketAveragePrice = await priceFeederContract.getMarketAveragePrice();

  expect(currentPrice.toString()).to.be.equal(CURRENT_PRICE.toString());
  expect(marketAveragePrice.toString()).to.be.equal(CURRENT_PRICE.toString());

  await shyftDaoContract.updateDaoMultiplier(DAO_MULTIPLIER);
  const daoMultiplier = await shyftDaoContract.getDaoMultiplier();

  expect(daoMultiplier.toString()).to.be.equal(DAO_MULTIPLIER.toString());

  const tx = {
    to: rewardsDistributionContract.address,
    value: ethers.utils.parseEther("8000")
  }
  await deployerSigner.sendTransaction(tx);

  await rewardsDistributionContract.setShyftStaking(shyftStakingContract.address);

  return true;
};

const id = 'Setup';

export default func;
func.tags = [id];
func.id = id;
