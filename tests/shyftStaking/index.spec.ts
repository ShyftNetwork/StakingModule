import checkStaking from './checkStaking';
import checkUnstaking from './checkUnstaking';
import checkRewardProvision from './checkRewardProvision';

import {deployments, getNamedAccounts} from 'hardhat';
import {getContracts, getSigners} from '../helpers/utils';

describe('Shyft Staking', function () {
  beforeEach(async function () {
    // Deploy fixtures
    await deployments.fixture();

    // Get accounts
    const {
      deployer,
      proxyOwner,
      normalStaker1,
      normalStaker2,
      normalStaker3,
      prePurchaser1,
      prePurchaser2,
      prePurchaser3,
      rewardProvider,
    } = await getNamedAccounts();

    this.deployer = deployer;
    this.proxyOwner = proxyOwner;
    this.normalStaker1 = normalStaker1;
    this.normalStaker2 = normalStaker2;
    this.normalStaker3 = normalStaker3;
    this.prePurchaser1 = prePurchaser1;
    this.prePurchaser2 = prePurchaser2;
    this.prePurchaser3 = prePurchaser3;
    this.rewardProvider = rewardProvider;

    // Get signers
    const {
      deployerSigner,
      proxyOwnerSigner,
      normalStaker1Signer,
      normalStaker2Signer,
      normalStaker3Signer,
      prePurchaser1Signer,
      prePurchaser2Signer,
      prePurchaser3Signer,
      rewardProviderSigner,
    } = await getSigners();

    this.deployerSigner = deployerSigner;
    this.proxyOwnerSigner = proxyOwnerSigner;
    this.normalStaker1Signer = normalStaker1Signer;
    this.normalStaker2Signer = normalStaker2Signer;
    this.normalStaker3Signer = normalStaker3Signer;
    this.prePurchaser1Signer = prePurchaser1Signer;
    this.prePurchaser2Signer = prePurchaser2Signer;
    this.prePurchaser3Signer = prePurchaser3Signer;
    this.rewardProviderSigner = rewardProviderSigner;

    // Get contracts
    const {
      stakingContract,
      priceFeederContract,
      rewardsDistributionContract,
      shyftDaoContract,
    } = await getContracts();
    this.stakingContract = stakingContract;
    this.priceFeederContract = priceFeederContract;
    this.rewardsDistributionContract = rewardsDistributionContract;
    this.shyftDaoContract = shyftDaoContract;
  });

  describe(
    'When providing rewards',
    checkRewardProvision.bind(this)
  );
  describe(
    'When checking staking functionalities',
    checkStaking.bind(this)
  );
  describe(
    'When checking unstaking functionalities',
    checkUnstaking.bind(this)
  );
});
