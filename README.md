# Shyft-Staking

## Table of Contents

<details>
<summary><strong>Expand</strong></summary>

- [Install](#install)
- [Usage](#usage)

</details>


## Install

1. Install dependencies:

```bash
$ yarn
```

## Usage
Remember to configure your env vars, the mnemonics are really important for deployment. You can check the corresponding accounts addresses with the command `ỳarn accounts...`

```bash
# Lint
yarn lint
# Prettier
yarn format
# Compile contracts, export ABIs, and generate TypeScript interfaces
yarn compile
# Run tests
yarn dev
yarn test (all unit tests)
# Verify accounts to use 
yarn accounts:rinkeby
yarn accounts:mainnet
# Deploy to rinkeby network (Remember to set env vars with mnemonics)
yarn deploy:rinkeby
# Verify contracts in etherscan
yarn verify:rinkeby --api-key <etherscan api key>
```