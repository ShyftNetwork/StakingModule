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
import {ethers} from "hardhat";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/src/signers";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const {deployments, getNamedAccounts} = hre;
  const {deploy, get, catchUnknownSigner} = deployments;

  const {priceFeederDeployer, rewardsDistributionDeployer, shyftDaoDistributionDeployer, shyftStakingDeployer, shyftStakingOwner} = await getNamedAccounts();

  console.log("priceFeederDeployer :: " + priceFeederDeployer);
  console.log("rewardsDistributionDeployer :: " + rewardsDistributionDeployer);
  console.log("shyftDaoDistributionDeployer :: " + shyftDaoDistributionDeployer);
  console.log("shyftStakingDeployer :: " + shyftStakingDeployer);
  console.log("shyftStakingOwner :: " + shyftStakingOwner);

  const signers = await ethers.getSigners();
  const fundingAddressSigner = signers[5];


  async function sendFunding(_fromSigner:any, _toAddress:string, _amount:BigNumber) {

    const tx = {
      to: _toAddress,
      value: _amount
    }

    await _fromSigner.sendTransaction(tx);
    console.log("sent " + ethers.utils.formatEther(_amount) + " to: " + _toAddress);
  }

  let fundDeployerAmount = ethers.utils.parseEther("1");

  await sendFunding(fundingAddressSigner, priceFeederDeployer, fundDeployerAmount);
  await sendFunding(fundingAddressSigner, rewardsDistributionDeployer, fundDeployerAmount);
  await sendFunding(fundingAddressSigner, shyftDaoDistributionDeployer, fundDeployerAmount);
  await sendFunding(fundingAddressSigner, shyftStakingDeployer, fundDeployerAmount);
  await sendFunding(fundingAddressSigner, shyftStakingOwner, fundDeployerAmount);

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
