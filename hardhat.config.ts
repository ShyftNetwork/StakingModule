import * as dotenv from 'dotenv';
dotenv.config({path: __dirname + '/.env'});

import {HardhatUserConfig} from 'hardhat/types';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-web3';

import 'hardhat-deploy';
import 'hardhat-gas-reporter';
import 'hardhat-contract-sizer';
import '@typechain/hardhat';
import 'solidity-coverage';

import {node_url, accounts} from './utils/network';

let PVT_priceFeederDeployer:string = process.env.PVT_PRICEFEEDERDEPLOYER || "";
let PVT_rewardsDistributionDeployer:string = process.env.PVT_REWARDSDISTRIBUTIONDEPLOYER || "";
let PVT_shyftDaoDistributionDeployer:string = process.env.PVT_SHYFTDAODISTRIBUTIONDEPLOYER || "";
let PVT_shyftStakingDeployer:string = process.env.PVT_SHYFTSTAKINGDEPLOYER || "";
let PVT_shyftStakingOwner:string = process.env.PVT_SHYFTSTAKINGOWNER || "";
let PVT_fundingAddress:string = process.env.PVT_FUNDINGADDRESS || "";


console.log("found :: PVT_priceFeederDeployer :: " + PVT_priceFeederDeployer);
console.log("found :: PVT_rewardsDistributionDeployer :: " + PVT_rewardsDistributionDeployer);
console.log("found :: PVT_shyftDaoDistributionDeployer :: " + PVT_shyftDaoDistributionDeployer);
console.log("found :: PVT_shyftStakingDeployer :: " + PVT_shyftStakingDeployer);
console.log("found :: PVT_shyftStakingOwner :: " + PVT_shyftStakingOwner);
console.log("found :: PVT_fundingAddress :: " + PVT_fundingAddress);

const config: HardhatUserConfig = {
  defaultNetwork: 'ganache',
  networks: {
    hardhat: {
      // forking: {
      //   url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      //   blockNumber: 10000000,
      // },
      allowUnlimitedContractSize: true,
    },
    ganache: {
      url: node_url('localhost'),
      live: false,
      saveDeployments: true,
      tags: ['local'],
      accounts: [PVT_priceFeederDeployer, PVT_rewardsDistributionDeployer, PVT_shyftDaoDistributionDeployer, PVT_shyftStakingDeployer, PVT_shyftStakingOwner, PVT_fundingAddress]//accounts('localhost'),
    },
    kovan: {
      url: node_url('kovan'),
      live: true,
      chainId: 42,
      saveDeployments: true,
      gas: 200000000000,
      tags: ['staging'],
      accounts: accounts('kovan'),
    },
    rinkeby: {
      url: node_url('rinkeby'),
      live: true,
      saveDeployments: true,
      tags: ['staging'],
      accounts: accounts('rinkeby'),
    },
    mumbai: {
      url: node_url('mumbai'),
      live: true,
      saveDeployments: true,
      tags: ['staging'],
      accounts: accounts('mumbai'),
      gas: 2100000,
      gasPrice: 8000000000,
    },
    mainnet: {
      url: node_url('mainnet'),
      live: true,
      saveDeployments: true,
      gasPrice: 170000000000, // 170 GWEI
      tags: ['production'],
      accounts: accounts('mainnet'),
    },
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: 97,
      gasPrice: 20000000000,
      accounts: accounts('mainnet'),
    },
    bscMainnet: {
      url: 'https://bsc-dataseed.binance.org/',
      chainId: 56,
      gasPrice: 20000000000,
      accounts: accounts('mainnet'),
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      chainId: 43113,
      accounts: accounts('mainnet'),
    },
    moonbase: {
      url: 'https://rpc.testnet.moonbeam.network',
      chainId: 1287,
      accounts: accounts('mainnet'),
    },
    avalanche: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      chainId: 43114,
      live: true,
      saveDeployments: true,
      gasPrice: 150000000000, // 150 GWEI
      tags: ['production'],
      accounts: accounts('mainnet'),
    },
    fork: {
      url: node_url('fork'),
    },
  },
  namedAccounts: {
    deployer: 0,
    proxyOwner: 1,
    normalStaker1: 2,
    normalStaker2: 3,
    normalStaker3: 4,
    prePurchaser1: 5,
    prePurchaser2: 6,
    prePurchaser3: 7,
    rewardProvider: 8,
    priceFeederDeployer: 0,
    rewardsDistributionDeployer: 1,
    shyftDaoDistributionDeployer: 2,
    shyftStakingDeployer: 3,
    shyftStakingOwner: 4,
    fundingAddress: 5,
  },
  paths: {
    artifacts: './artifacts',
    cache: './cache',
    sources: './contracts',
    tests: './tests',
    deploy: './deploy',
  },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 120,
    enabled: process.env.REPORT_GAS ? true : false,
    coinmarketcap: process.env.CMC_API_KEY,
    excludeContracts: ['./contracts/mocks/', './contracts/libs/'],
  },
  typechain: {
    outDir: 'types/contracts',
    target: 'ethers-v5',
  },
  mocha: {
    timeout: 0,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || '',
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};

export default config;
