import { Contract, ContractFactory } from 'ethers'
import { ethers, upgrades } from 'hardhat'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import {
  REWARDS_AMOUNT,
  REWARDS_DURATION,
  LOWEST_VOTING_BOUND_PRICE,
  PREPURCHASERS_AFTER_PERIOD,
  CURRENT_PRICE,
  DAO_MULTIPLIER,
} from '../utils/constants'
import {
  deployPriceFeeder,
  deployRewardsDistribution,
  deployShyftDao,
} from './../utils/contracts'
import { getCurrentTimestamp } from '../tests/helpers/time'

async function getImplementationAddress(proxyAddress: string) {
  const implHex = await ethers.provider.getStorageAt(
    proxyAddress,
    '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc'
  )
  return ethers.utils.hexStripZeros(implHex)
}

// const waitSeconds = (seconds: number): Promise<unknown> => {
//   console.log(`\tWaiting ${seconds} seconds...`)
//   return new Promise((resolve) => setTimeout(resolve, seconds * 1000))
// }

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const signers = await ethers.getSigners()
  const deployerSigner = signers[0]

  console.log('-----> Start ----->')

  // PriceFeeder
  const priceFeeder = await deployPriceFeeder()
  await priceFeeder.updatePrices(CURRENT_PRICE, CURRENT_PRICE)
  console.log('PriceFeeder: ', priceFeeder.address)

  // RewardsDistribution
  const rewardsDistribution = await deployRewardsDistribution()
  //   const tx = {
  //     to: rewardsDistribution.address,
  //     value: ethers.utils.parseEther('8000'),
  //   }
  //   await deployerSigner.sendTransaction(tx)
  console.log('RewardsDistribution: ', rewardsDistribution.address)

  // ShyftDAO
  const shyftDao = await deployShyftDao()
  await shyftDao.updateDaoMultiplier(DAO_MULTIPLIER)
  console.log('ShyftDAO: ', shyftDao.address)

  // ShyftStaking
  const currentTimestamp = (await getCurrentTimestamp()).toNumber()
  const timestampForRelease = currentTimestamp + PREPURCHASERS_AFTER_PERIOD
  const priceFeederAddress = priceFeeder.address
  const rewardsDistributionAddress = rewardsDistribution.address
  const shyftDaoAddress = shyftDao.address
  const params = [
    rewardsDistributionAddress,
    shyftDaoAddress,
    priceFeederAddress,
    timestampForRelease,
    REWARDS_DURATION,
    REWARDS_AMOUNT,
    LOWEST_VOTING_BOUND_PRICE,
  ]

  const ShyftStakingFactory: ContractFactory = await ethers.getContractFactory(
    'ShyftStaking'
  )
  const shyftStaking: Contract = await upgrades.deployProxy(
    ShyftStakingFactory,
    params,
    {
      initializer: 'initialize',
    }
  )
  await shyftStaking.deployed()
  console.log('ShyftStaking: ', shyftStaking.address)

  // ShyftStaking Implementation
  const shyftStakingImplementation = await getImplementationAddress(
    shyftStaking.address
  )
  console.log('ShyftStaking Implementation:', shyftStakingImplementation)

  //   await waitSeconds(5)

  //   await hre.run('verify:verify', {
  //     address: shyftStakingImplementation,
  //     contract: 'contracts/ShyftStaking.sol:ShyftStaking',
  //     constructorArguments: [],
  //   })

  // RewardsDistribution set
  await rewardsDistribution.setShyftStaking(shyftStaking.address)
}

const id = 'ShyftStakingUpgrade'

export default func
func.tags = [id]
func.id = id
