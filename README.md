## Requirements

This repository was build with Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone repository

```
git clone git@github.com:spaceh3ad/singularity-dao-task.git
cd singularity-dao-task
```

### Build

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

2. [Aderyn](https://github.com/Cyfrin/aderyn)

   ```shell
   aderyn .
   ```

   It generates [report.md](./report.md) at project root.

3. [Mythril](https://github.com/Consensys/mythril)

   ```shell
   ❯ myth analyze src/*.sol
   ```

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
