import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';
import {expect} from 'chai';

import {CURRENT_PRICE, DAO_MULTIPLIER} from '../utils/constants';

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const signers = await ethers.getSigners();
  const rewardsDistributionDeployerSigner = signers[1];
  const shyftDaoDistributionDeployerSigner = signers[2];
  const shyftStakingDeployerSigner = signers[3];
  const fundingAddressSigner = signers[5];

  // console.log("signers :: " + JSON.stringify(signers, null, 4));

  const {deployments, getNamedAccounts} = hre;
  const {priceFeederDeployer, rewardsDistributionDeployer, shyftDaoDistributionDeployer, shyftStakingDeployer, shyftStakingOwner, fundingAddress} = await getNamedAccounts();

  console.log("priceFeederDeployer :: " + priceFeederDeployer);
  console.log("rewardsDistributionDeployer :: " + rewardsDistributionDeployer);
  console.log("shyftDaoDistributionDeployer :: " + shyftDaoDistributionDeployer);
  console.log("shyftStakingDeployer :: " + shyftStakingDeployer);
  console.log("shyftStakingOwner :: " + shyftStakingOwner);
  console.log("fundingAddress :: " + fundingAddress);

  const shyftStakingContract = (await ethers.getContract('ShyftStaking')).connect(shyftStakingDeployerSigner);
  const priceFeederContract = await ethers.getContract('PriceFeeder');
  const shyftDaoContract = (await ethers.getContract('ShyftDao')).connect(shyftDaoDistributionDeployerSigner);
  const rewardsDistributionContract = (await ethers.getContract('RewardsDistribution')).connect(rewardsDistributionDeployerSigner);

  console.log("------------------------------------------------------------------------------------");
  console.log("shyftStakingContract Deploy Address :: " + shyftStakingContract.address);
  console.log("priceFeederContract Deploy Address :: " + priceFeederContract.address);
  console.log("shyftDaoContract Deploy Address :: " + shyftDaoContract.address);
  console.log("rewardsDistributionContract Deploy Address :: " + rewardsDistributionContract.address);
  console.log("------------------------------------------------------------------------------------");

  await priceFeederContract.updatePrices(CURRENT_PRICE, CURRENT_PRICE);
  const currentPrice = await priceFeederContract.getCurrentPrice()
  const marketAveragePrice = await priceFeederContract.getMarketAveragePrice();

  expect(currentPrice.toString()).to.be.equal(CURRENT_PRICE.toString());
  expect(marketAveragePrice.toString()).to.be.equal(CURRENT_PRICE.toString());

  const daoOwner = await shyftDaoContract.owner();

  await shyftDaoContract.updateDaoMultiplier(DAO_MULTIPLIER);
  const daoMultiplier = await shyftDaoContract.getDaoMultiplier();

  expect(daoMultiplier.toString()).to.be.equal(DAO_MULTIPLIER.toString());

  let newRewardAmount = ethers.utils.parseEther("5000000");

  const tx = {
    to: rewardsDistributionContract.address,
    value: newRewardAmount
  }

  await fundingAddressSigner.sendTransaction(tx);

  await rewardsDistributionContract.setShyftStaking(shyftStakingContract.address);

  let rewardRateFound_prev = await shyftStakingContract.rewardRate();
  let rewardsAmountFound_prev = await shyftStakingContract.rewardsAmount();
  let rewardsDurationFound_prev = await shyftStakingContract.rewardsDuration();

  console.log("prev :: rewardRateFound :: " + rewardRateFound_prev);
  console.log("prev :: rewardsAmountFound :: " + ethers.utils.formatEther(rewardsAmountFound_prev.toString()));
  console.log("prev :: rewardsDurationFound :: " + rewardsDurationFound_prev);


  console.log("shyftStakingContract provider :: " + JSON.stringify(shyftStakingContract.provider));
  console.log("shyftStakingContract signer :: " + JSON.stringify(shyftStakingContract.signer));
  console.log("shyftStakingContract owner :: " + (await shyftStakingContract.owner()));

  await shyftStakingContract.setRewardsAmount(newRewardAmount);
  await rewardsDistributionContract.provideRewards();

  let rewardRateFound_after = await shyftStakingContract.rewardRate();
  let rewardsAmountFound_after = await shyftStakingContract.rewardsAmount();
  let rewardsDurationFound_after = await shyftStakingContract.rewardsDuration();

  console.log("after :: rewardRateFound :: " + rewardRateFound_after);
  console.log("after :: rewardsAmountFound :: " + ethers.utils.formatEther(rewardsAmountFound_after.toString()));
  console.log("after :: rewardsDurationFound :: " + rewardsDurationFound_after);

  console.log("periodFinish :: " + (await shyftStakingContract.periodFinish()));

  return true;
};

const id = 'Setup';

export default func;
func.tags = [id];
func.id = id;
