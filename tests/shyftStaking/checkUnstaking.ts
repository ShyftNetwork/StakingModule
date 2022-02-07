import hre from "hardhat";
import {expect} from 'chai';
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';
import {increaseTime} from '../helpers/time';
import {PREPURCHASERS_AFTER_PERIOD, REWARDS_DURATION, UNBONDING_PERIOD} from '../../utils/constants';
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

        // Provide rewards with dao multiplier, so 5 SHFT, as daoMultiplier = 0.5
        await this.rewardsDistributionContract.provideRewards();
      });
      it('should revert if trying to unbond before prepurchasers period ends', async function () {
        await expectRevert(
          this.stakingContract
          .connect(this.normalStaker1Signer)
          .unbondAll(),
          'Cannot do this action yet'
        );
      });
      it('should revert if prepurchaser tries to unbond after period but without staking', async function () {
        await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

        await expectRevert(
          this.stakingContract
          .connect(this.prePurchaser1Signer)
          .unbond(stakingAmount),
          'Cannot unbond more than staked'
        );
      });
      it('should succeed if trying to unbond after prepurchasers period using unbondAll()', async function () {
        await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

        await this.stakingContract
          .connect(this.normalStaker1Signer)
          .unbondAll();
      });
      it('should succeed if trying to unbond after prepurchasers period using unbond()', async function () {
        const amountToUnbond = ethers.utils.parseEther("3");
        await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

        await this.stakingContract
          .connect(this.normalStaker1Signer)
          .unbond(amountToUnbond);
      });
      it('should get reward as well when using unbondAll()', async function () {
        await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);
        // Just to update block for correct earned().
        await this.shyftDaoContract.updateDaoMultiplier(ethers.utils.parseEther("0.5"));

        const earnedBefore = await formatAndRoundBigNumber(await this.stakingContract.earned(this.normalStaker1));
        const totalRewardsStaker1 = await formatAndRoundBigNumber(totalRewards.div(4));

        await this.stakingContract
          .connect(this.normalStaker1Signer)
          .unbondAll();

        const earnedAfter = await this.stakingContract.earned(this.normalStaker1);

        expect(earnedBefore.toString()).to.be.equal(totalRewardsStaker1.toString());
        expect(earnedAfter.toString()).to.be.equal('0');
      });
      describe('And one normal staker and prepurchaser have unbonded', () => {
        beforeEach(async function() {
          await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

          await this.stakingContract
            .connect(this.prePurchaser1Signer)
            .stakePrePurchaser({ value: stakingAmount });
          await this.stakingContract
            .connect(this.normalStaker1Signer)
            .unbondAll();
          await this.stakingContract
            .connect(this.prePurchaser1Signer)
            .unbondAll();
        });
        it('should revert if trying to unstake before unbonding period ends', async function () {
          const amountToUnstake = ethers.utils.parseEther("3");

          await expectRevert(
            this.stakingContract
            .connect(this.normalStaker1Signer)
            .unstake(1, amountToUnstake),
            'Cannot unstake before unbonding period ends'
          );
        });
        it('should revert if trying to unstake not owned unbonding id', async function () {
          await increaseTime(this.deployerSigner.provider, UNBONDING_PERIOD);

          const amountToUnstake = ethers.utils.parseEther("3");

          await expectRevert(
            this.stakingContract
            .connect(this.prePurchaser1Signer)
            .unstake(1, amountToUnstake),
            'Only owner of unbonding id can unstake'
          );
        });
        it('should revert if trying to unstake more than unbonding id contains', async function () {
          await increaseTime(this.deployerSigner.provider, UNBONDING_PERIOD);

          const amountToUnstake = ethers.utils.parseEther("6");

          await expectRevert(
            this.stakingContract
            .connect(this.normalStaker1Signer)
            .unstake(1, amountToUnstake),
            'Cannot unstake more than remaining amount in unbonding id'
          );
        });
        it('should be able to unstake after unbonding period has finished', async function () {
          const partialAmountToUnstake = ethers.utils.parseEther("3");
          const totalAmountToUnstake = ethers.utils.parseEther("5");

          await increaseTime(this.deployerSigner.provider, UNBONDING_PERIOD);

          await this.stakingContract
            .connect(this.normalStaker1Signer)
            .unstake(1, partialAmountToUnstake);

          await this.stakingContract
            .connect(this.prePurchaser1Signer)
            .unstake(2, totalAmountToUnstake);
        });
      });
    });
  });
}
