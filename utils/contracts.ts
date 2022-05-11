import { Contract } from 'ethers'
import {
  PriceFeeder,
  RewardsDistribution,
  ShyftDao,
} from './../types/contracts'

const hre = require('hardhat')

export const deployContract = async <ContractType extends Contract>(
  contractName: string,
  args: any[],
  libraries?: {}
) => {
  const signers = await hre.ethers.getSigners()
  const contract = (await (
    await hre.ethers.getContractFactory(contractName, signers[0], {
      libraries: {
        ...libraries,
      },
    })
  ).deploy(...args)) as ContractType

  return contract
}

export const deployPriceFeeder = async () => {
  return await deployContract<PriceFeeder>('PriceFeeder', [])
}

export const deployRewardsDistribution = async () => {
  return await deployContract<RewardsDistribution>('RewardsDistribution', [])
}

export const deployShyftDao = async () => {
  return await deployContract<ShyftDao>('ShyftDao', [])
}
