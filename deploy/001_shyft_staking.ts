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
  const {deploy, get} = deployments;

  const {deployer, proxyOwner} = await getNamedAccounts();

  let contractName = 'PriceFeeder';

  await deploy(contractName, {
    contract: contractName,
    from: deployer,
    log: true,
  });

  contractName = 'RewardsDistribution';

  await deploy(contractName, {
    contract: contractName,
    from: deployer,
    log: true,
  });

  contractName = 'ShyftDao';

  await deploy(contractName, {
    contract: contractName,
    from: deployer,
    log: true,
  });

  contractName = 'ShyftStaking';

  const currentTimestamp = (await getCurrentTimestamp()).toNumber();
  const timestampForRelease = currentTimestamp + PREPURCHASERS_AFTER_PERIOD;
  const priceFeederAddress = (await get('PriceFeeder')).address;
  const rewardsDistributionAddress = (await get('RewardsDistribution')).address;
  const shyftDaoAddress = (await get('ShyftDao')).address;

  await deploy(contractName, {
    contract: contractName,
    from: deployer,
    proxy: {
      owner: proxyOwner,
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
  });
  return true;
};

const id = 'ShyftStaking';

export default func;
func.tags = [id];
func.id = id;
