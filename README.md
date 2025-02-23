## Deploy a smart contract on Monad using Hardhat
1. Create a sample Hardhat project
```
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts
npm install dotenv
```
```
npx hardhat init
```
Select your preferences when prompted by the CLI or use the recommended preferences below.
```
✔ What do you want to do? · Create a TypeScript project (with Viem)
✔ Hardhat project root: · /path/to/my-hardhat-project
✔ Do you want to add a .gitignore? (Y/n) · y
✔ Do you want to install this sample project's dependencies with npm (hardhat @nomicfoundation/hardhat-toolbox-viem)? (Y/n) · y
```
2. Setting up configuration variables

3. Update your hardhat.config.ts file to include the monadTestnet configuration
```
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    monadTestnet: {
      url: "https://testnet-rpc.monad.xyz",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 10143,
    },
  },
};

export default config;
```
Creat .env
```
PRIVATE_KEY=your_private_key_here
```
4. Write a smart contract
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GMonad {
    function sayGmonad() public pure returns (string memory) {
        return "gmonad";
    }
}
```
5. Compile the smart contract
```
npx hardhat compile
```
6. Deploy the smart contract
Create a file named GMonad.ts in the ignition/modules directory, with the following code:
```
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const GMonadModule = buildModule("GMonadModule", (m) => {
    const gmonad = m.contract("GMonad");

    return { gmonad };
});

module.exports = GMonadModule;
```
Deploying the smart contract
```
npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet
```











