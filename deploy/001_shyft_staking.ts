import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import '@nomiclabs/hardhat-ethers';
import {BigNumber} from 'ethers';
import {
  REWARDS_AMOUNT,
  REWARDS_DURATION,
  LOWEST_VOTING_BOUND_PRICE,
  PREPURCHASERS_AFTER_PERIOD,
} from '../utils/constants';
import {getCurrentTimestamp} from '../tests/helpers/time';

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const {deployments, getNamedAccounts} = hre;
  const {deploy, get, catchUnknownSigner} = deployments;

  const {priceFeederDeployer, rewardsDistributionDeployer, shyftDaoDistributionDeployer, shyftStakingDeployer, shyftStakingOwner} = await getNamedAccounts();

  console.log("priceFeederDeployer :: " + priceFeederDeployer);
  console.log("rewardsDistributionDeployer :: " + rewardsDistributionDeployer);
  console.log("shyftDaoDistributionDeployer :: " + shyftDaoDistributionDeployer);
  console.log("shyftStakingDeployer :: " + shyftStakingDeployer);
  console.log("shyftStakingOwner :: " + shyftStakingOwner);

  let contractName = 'PriceFeeder';

  await deploy(contractName, {
    contract: contractName,
    from: priceFeederDeployer,
    log: true,
  });

  contractName = 'RewardsDistribution';

  await deploy(contractName, {
    contract: contractName,
    from: rewardsDistributionDeployer,
    log: true,
  });

  contractName = 'ShyftDao';

  await deploy(contractName, {
    contract: contractName,
    from: shyftDaoDistributionDeployer,
    log: true,
  });

  contractName = 'ShyftStaking';

  const currentTimestamp = (await getCurrentTimestamp()).toNumber();
  const timestampForRelease = currentTimestamp + PREPURCHASERS_AFTER_PERIOD;
  const priceFeederAddress = (await get('PriceFeeder')).address;
  const rewardsDistributionAddress = (await get('RewardsDistribution')).address;
  const shyftDaoAddress = (await get('ShyftDao')).address;

  await catchUnknownSigner(
      deploy(contractName, {
        contract: contractName,
        from: shyftStakingDeployer,
        proxy: {
          owner: shyftStakingOwner,
          methodName: 'initialize',
          proxyContract: 'OpenZeppelinTransparentProxy',
        },
        args: [
          rewardsDistributionAddress,
          shyftDaoAddress,
          priceFeederAddress,
          timestampForRelease,
          REWARDS_DURATION,
          REWARDS_AMOUNT,
          LOWEST_VOTING_BOUND_PRICE,
        ],
        log: true,
      })
  );
  return true;
};

const id = 'ShyftStaking';

export default func;
func.tags = [id];
func.id = id;
