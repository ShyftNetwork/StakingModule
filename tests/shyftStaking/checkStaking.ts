import hre from "hardhat";
import {expect} from 'chai';
import {ethers} from 'hardhat';
import {BigNumber} from 'ethers';
import {increaseTime} from '../helpers/time';
import {PREPURCHASERS_AFTER_PERIOD, REWARDS_DURATION} from '../../utils/constants';
import {formatAndRoundBigNumber, roundNumber} from '../helpers/utils';
const {expectRevert} = require('@openzeppelin/test-helpers');

export default async function suite(): Promise<void> {
  describe('Succeeds', async () => {
    describe('On Basic Staking', () => {
      it('When a normal user is staking', async function () {
        await this.stakingContract
          .connect(this.normalStaker1Signer)
          .stake({ value: ethers.utils.parseEther("5") });

        const totalSupply = await this.stakingContract.totalSupply();

        expect(totalSupply.toString()).to.be.equal(ethers.utils.parseEther("5").toString());
      });
      it('should revert when passing 0 ether', async function () {
        await expectRevert(
          this.stakingContract
          .connect(this.normalStaker1Signer)
          .stake({ value: ethers.utils.parseEther("0") }),
          'Cannot stake 0'
        );
      });
      it('When passing prepurchasers', async function () {
        const prepurchasers = [this.prePurchaser1, this.prePurchaser2];
        const amounts = [ethers.utils.parseEther("5"), ethers.utils.parseEther("5")];

        await this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts);

        const totalSupply = await this.stakingContract.totalSupply();

        expect(totalSupply.toString()).to.be.equal(ethers.utils.parseEther("10").toString());
      });
      it('reverts when trying to provide wrong prepurchasers input', async function () {
        const prepurchasers = [this.prePurchaser3, this.prePurchaser2];
        const amounts = [ethers.utils.parseEther("5")];

        await expectRevert(
          this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts),
          'Wrong input'
        );
      });
      it('reverts when trying to provide 0 amount', async function () {
        const prepurchasers = [this.prePurchaser3];
        const amounts = [ethers.utils.parseEther("0")];

        await expectRevert(
          this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts),
          'Amount to be added must be greater than 0'
        );
      });
      it('reverts when trying to provide same prepurchaser again', async function () {
        const prepurchasers = [this.prePurchaser3];
        const amounts = [ethers.utils.parseEther("2")];

        await this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts);

        await expectRevert(
          this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts),
          'Cannot add prepurchaser again'
        );
      });
      it('reverts when trying to add prepurchasers after rewards have been provided', async function () {
        const prepurchasers = [this.prePurchaser3];
        const amounts = [ethers.utils.parseEther("5")];
        await this.rewardsDistributionContract.provideRewards();

        await expectRevert(
          this.stakingContract
          .connect(this.deployerSigner)
          .addPrePurchasers(prepurchasers, amounts),
          'Cannot add prepurchasers after rewards are provided'
        );
      });
    });
    describe('On Providing Rewards', () => {
      describe('When there are two normal stakers and two prepurchasers', () => {
        const stakingAmount = ethers.utils.parseEther("5");
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
        it('should revert when prepurchaser is trying to normally stake before prepurchasers mode goes off', async function () {
          await expectRevert(
            this.stakingContract
            .connect(this.prePurchaser1Signer)
            .stake({ value: ethers.utils.parseEther("2") }),
            'Prepurchasers can normally stake only if prepurchasers mode is not ON'
          );
        });
        it('should revert if prepurchaser is trying to call stakePrePurchaser() twice', async function () {
          await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);
          await this.stakingContract
            .connect(this.prePurchaser1Signer)
            .stakePrePurchaser({ value: stakingAmount });

          await expectRevert(
            this.stakingContract
            .connect(this.prePurchaser1Signer)
            .stakePrePurchaser({ value: stakingAmount }),
            'Cannot stake again'
          );
        });
        it('should revert if prepurchaser is trying to call stakePrePurchaser() with not the whole amount', async function () {
          await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

          await expectRevert(
            this.stakingContract
            .connect(this.prePurchaser1Signer)
            .stakePrePurchaser({ value: stakingAmount.sub(1) }),
            'Prepurchasers should stake the whole exact amount'
          );
        });
        it('should revert if staker is trying to call stakePrePurchaser()', async function () {
          await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

          await expectRevert(
            this.stakingContract
            .connect(this.normalStaker1Signer)
            .stakePrePurchaser({ value: stakingAmount }),
            'Only Prepurchasers can call this function'
          );
        });
        describe('And one prepurchaser is not staking before mode goes off', () => {
          let startingBalance: BigNumber;
          let endingBalance: BigNumber;
          beforeEach(async function () {
            startingBalance = await this.rewardsDistributionContract.getBalance();

            await increaseTime(this.deployerSigner.provider, PREPURCHASERS_AFTER_PERIOD);

            // One prepurchaser stakes
            await this.stakingContract
              .connect(this.prePurchaser1Signer)
              .stakePrePurchaser({ value: stakingAmount });

            // Finish prepurchasers mode
            await this.stakingContract
              .connect(this.deployerSigner)
              .finishPrePurchasersMode();

            endingBalance = await this.rewardsDistributionContract.getBalance();
          })
          it('His rewards should be returned back to rewardDistribution', async function () {
            const totalStakingAmount = ethers.utils.parseEther("20");
            const nonStakedAmount = ethers.utils.parseEther("5");
            const totalRewards = ethers.utils.parseEther("5");

            const returnedRewards = Number(ethers.utils.formatEther(
              nonStakedAmount.mul(totalRewards).div(totalStakingAmount)));

            const balanceReturned = await formatAndRoundBigNumber(endingBalance.sub(startingBalance));
            expect(balanceReturned).to.be.equal(returnedRewards);
          });
          it('Rewards should be provided correctly afterwards', async function () {
            await this.rewardsDistributionContract.provideRewards();

            const totalRewardsApplied = ethers.utils.parseEther("10").sub(endingBalance.sub(startingBalance));
            const rewardPerStaker = await formatAndRoundBigNumber(totalRewardsApplied.div(3));

            await increaseTime(this.deployerSigner.provider, REWARDS_DURATION);
            // Just to update block for correct earned().
            await this.shyftDaoContract.updateDaoMultiplier(ethers.utils.parseEther("0.5"));

            const earnedPrePurchaser1 = await formatAndRoundBigNumber(
              await this.stakingContract.earned(this.prePurchaser1)
            );
            const earnedNormalStaker1 = await formatAndRoundBigNumber(
              await this.stakingContract.earned(this.normalStaker1)
            );
            const earnedNormalStaker2 = await formatAndRoundBigNumber(
              await this.stakingContract.earned(this.normalStaker2)
            );

            expect(earnedPrePurchaser1).to.be.equal(rewardPerStaker);
            expect(earnedNormalStaker1).to.be.equal(rewardPerStaker);
            expect(earnedNormalStaker2).to.be.equal(rewardPerStaker);
          });
          it('should work when prepurchaser is trying to stake after prepurchaser mode goes off', async function () {
            await this.stakingContract
              .connect(this.prePurchaser1Signer)
              .stake({ value: ethers.utils.parseEther("2") });
          });
        })
      });
    });
  });
}
