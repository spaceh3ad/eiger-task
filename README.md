### Overview

This repository provides `Swapper` smart contract written in Solidity that allows swapping ETHs to tokens. Trades are done through `Proxy` contract that provides upgradeability of logic. Proxy updates are being managed by `Multisig`.

- Proxy - allowing upgrading swapping logic or adding new features/updates
- Multisig - each update must be approved by privileged users - quorum of at least 3 approvals must be reached to update implementation contract
- Swapper - contains swap logic including providing quotes on tokens

## Requirements

This repository was build with Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone repository

```
git clone git@github.com:spaceh3ad/eiger-task.git
cd eiger-task
```

### Build

NOTE: [export abstract syntax tree](https://github.com/Cyfrin/aderyn/issues/191#issuecomment-1972631873)

```shell
forge build --ast
```

### Test & Coverage

```shell
forge test
forge coverage
```

### Security Analysis

1. [Slither](https://github.com/crytic/slither)

   ```shell
   slither .
   ```

   Report at [Slither.md](./security-scans/Slither.md)

2. [Aderyn](https://github.com/Cyfrin/aderyn)

   ```shell
   aderyn . --exclude lib
   ```

   Report at [Aderyn.md](./security-scans/Aderyn.md)

3. [Mythril](https://github.com/Consensys/mythril)

   ````shell
   myth analyze src/*.sol --solc-json mythril.solc.json
   ```

   Report at [Myth.md](./security-scans/Myth.md)

   ````

4. [Solidity Metrics](https://github.com/Consensys/solidity-metrics)

   Report is available at [solidity-metrics](./security-scans/solidity-metrics.html). Can be viewed in nice format at http://127.0.0.1:3000/

### Deployment

Copy [.env.example](./.env.example) and rename to .env. Also fill out the envs.

Deploy contracts to Goerli.

```code
forge script  script/Deploy.s.sol --ffi --rpc-url https://goerli.gateway.tenderly.co --broadcast
```

### Verify

You could verify contracts with:

```code
forge verify-contract CONTRACT_ADDRES src/Contract.sol:Contract -c 5 --num-of-optimizations 200 --watch
```

### Documentation

```code
forge doc --serve --port 4000 --open
```

### Smart Contracts

Contracts are deployed at Goerli network

- [Proxy](https://goerli.etherscan.io/address/0xe2a4feb6c839379e0de011777f0e6e5584b42c1d)
- [Swapper](https://goerli.etherscan.io/address/0x4d45a9328ce65deaa6bef2a20a5943fe844ede23)
- [Multisig](https://goerli.etherscan.io/address/0x76043b95600034e039f20e181a2da265d198cc0f)

To perform a swap user should call `swapEtherToToken` through Proxy contract.
