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

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      // forking: {
      //   url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      //   blockNumber: 11589707,
      // },
      allowUnlimitedContractSize: true,
    },
    ganache: {
      url: node_url('localhost'),
      live: false,
      saveDeployments: true,
      tags: ['local'],
      accounts: accounts('localhost'),
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
