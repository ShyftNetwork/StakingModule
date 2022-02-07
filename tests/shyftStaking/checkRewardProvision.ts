import hre from "hardhat";
import {expect} from 'chai';
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';
import {increaseTime} from '../helpers/time';
import {
  PREPURCHASERS_AFTER_PERIOD,
  REWARDS_DURATION,
  NORMAL_REWARD_RATE_PER_SECOND,
  HIGH_AVERAGE_PRICE,
  LOW_AVERAGE_PRICE,
  CURRENT_PRICE,
} from '../../utils/constants';
import {formatAndRoundBigNumber, roundNumber} from '../helpers/utils';
const {expectRevert} = require('@openzeppelin/test-helpers');

export default async function suite(): Promise<void> {
  describe('Works', async () => {
    describe('When there are two normal stakers and two prepurchasers', () => {
      const stakingAmount = ethers.utils.parseEther("5");
      const totalRewards = ethers.utils.parseEther("5");
      beforeEach(async function () {
        // Normal staker 1
        await this.stakingContract
          .connect(this.normalStaker1Signer)
          .stake({ value: stakingAmount });
        // Normal staker 2
        await this.stakingContract
          .connect(this.normalStaker2Signer)
          .stake({ value: stakingAmount });

        // Prepurchasers
        const prepurchasers = [this.prePurchaser1, this.prePurchaser2];
        const amounts = [stakingAmount, stakingAmount];

        await this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts);
      });
      it('should be equal if marketAveragePrice <= lowestBoundPrice', async function () {
        await this.priceFeederContract.updatePrices(CURRENT_PRICE, LOW_AVERAGE_PRICE);
        await this.rewardsDistributionContract.provideRewards();

        const rewardRate = ethers.utils.formatEther(await this.stakingContract.rewardRate());

        expect(roundNumber(NORMAL_REWARD_RATE_PER_SECOND).toString()).to.be.equal(roundNumber(Number(rewardRate)).toString());
      });
      it('should be equal if daoMultiplier is 1 and currentPrice >= marketAveragePrice >= lowestBoundPrice', async function () {
        await this.shyftDaoContract.updateDaoMultiplier(ethers.utils.parseEther("1"));
        await this.rewardsDistributionContract.provideRewards();

        const rewardRate = ethers.utils.formatEther(await this.stakingContract.rewardRate());

        expect(roundNumber(NORMAL_REWARD_RATE_PER_SECOND).toString()).to.be.equal(roundNumber(Number(rewardRate)).toString());
      });
      it('should be half when dao multiplier is 0.5 and currentPrice >= marketAveragePrice >= lowestBoundPrice', async function () {
        await this.rewardsDistributionContract.provideRewards();

        const doubleRewardRate = ethers.utils.formatEther((await this.stakingContract.rewardRate()).mul(2));

        expect(NORMAL_REWARD_RATE_PER_SECOND.toString()).to.be.equal(doubleRewardRate.toString());
      });
      it('should be zero if market average price is huge, but still users should have correct rewards', async function () {
        await this.rewardsDistributionContract.provideRewards();
        await increaseTime(this.deployerSigner.provider, REWARDS_DURATION);

        await this.priceFeederContract.updatePrices(CURRENT_PRICE, HIGH_AVERAGE_PRICE);
        await this.rewardsDistributionContract.provideRewards();

        const rewardRate = ethers.utils.formatEther((await this.stakingContract.rewardRate()));

        const earnedNormalStaker1 = await formatAndRoundBigNumber(
          await this.stakingContract.earned(this.normalStaker1)
        );
        const expectedRewardPerUser = await formatAndRoundBigNumber(totalRewards.div(4));

        expect(rewardRate.toString()).to.be.equal('0.0');
        expect(earnedNormalStaker1.toString()).to.be.equal(expectedRewardPerUser.toString());
      });
    });
  });
}
