## Deploy a smart contract on Monad using Hardhat
### 1. Clone the repository
```Bash
git clone https://github.com/ToanBm/monad-testnet.git && cd monad-testnet
```
### 2. Run the deploy script
```bash
chmod +x contract.sh && ./contract.sh
```
### 3. Verify contract
```bash
npx hardhat verify <> --network monadTestnet
```
- Check your contract on Explorer! [Here](https://monad-testnet.socialscan.io/)
### 4. Deploy next Contract
```bash
yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet --reset
```
#### Verify
```bash
CONTRACT_ADDRESS=$(yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet --reset | grep -oE '0x[a-fA-F0-9]{40}')
```
```bash
npx hardhat verify $CONTRACT_ADDRESS --network monadTestnet
```

## Done!

## Build a basic dApp with Scaffold-Eth-Monad
### 1. Clone the repository
```Bash
git clone https://github.com/ToanBm/monad-testnet.git && cd monad-testnet
```
### 2. Run the deploy script
```bash
chmod +x dapp.sh && ./dapp.sh
```

- Check your contract on Explorer! [Here](https://monad-testnet.socialscan.io/)

## Done!

