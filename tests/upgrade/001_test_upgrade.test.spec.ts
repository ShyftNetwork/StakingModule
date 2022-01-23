import {ethers, deployments, getNamedAccounts} from 'hardhat';
import {expect} from 'chai';

describe('ShyftStaking upgrade test', () => {
  beforeEach(async () => {
    await deployments.fixture();
  });

  it('Shyft Staking should be upgraded', async function () {
    const shyftStakingContract = await ethers.getContract('ShyftStaking');

    // Check new method don't exist
    expect(() => shyftStakingContract.testFunction()).to.throw(
      'shyftStakingContract.testFunction is not a function'
    );

    // Given
    const {proxyOwner} = await getNamedAccounts();
    const {deploy} = deployments;

    // When
    await deploy('ShyftStaking', {
      contract: 'StakingV2',
      from: proxyOwner,
      proxy: {
        owner: proxyOwner,
        proxyContract: 'OpenZeppelinTransparentProxy',
      },
      log: true,
    });

    const stakingV2 = await ethers.getContract('ShyftStaking');

    const test1 = await stakingV2.test1();
    const testFunctionReturned = await stakingV2.testFunction();

    // Then
    // Check new Test variables and functions exist
    expect(test1.toNumber()).to.equal(0);
    expect(testFunctionReturned.toNumber()).to.equal(1);
  });
});
