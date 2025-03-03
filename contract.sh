#!/bin/bash
# Logo
curl -s https://raw.githubusercontent.com/ToanBm/user-info/main/logo.sh | bash
sleep 3

show() {
    echo -e "\033[1;35m$1\033[0m"
}

# Step 1: Install hardhat
echo "Install Hardhat..."
npm init -y
echo "Install dotenv..."
npm install dotenv

# Step 2: Automatically choose "Create an empty hardhat.config.js"
echo "Choose >> Create a TypeScript project (with Viem)"
npm install --save-dev hardhat@2.22.19

npx hardhat init

# Step 3: Update hardhat.config.js with the proper configuration
echo "Creating new hardhat.config file..."
rm hardhat.config.ts

cat <<'EOF' > hardhat.config.ts
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
  sourcify: {
      enabled: true,
      apiUrl: "https://sourcify-api-monad.blockvision.org",
      browserUrl: "https://testnet.monadexplorer.com/"
    },
    // To avoid errors from Etherscan
    etherscan: {
        enabled: false,
    },
};

export default config;
EOF

# Step 4: Create MyToken.sol contract
echo "Enter token symbol:"
read TOKEN_SYMBOL

echo "Enter total supply:"
read TOTAL_SUPPLY

echo "Creating ERC20 contract with symbol $TOKEN_SYMBOL and supply $TOTAL_SUPPLY..."

rm contracts/Lock.sol

cat <<EOF > contracts/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "$TOKEN_SYMBOL") {
        _mint(msg.sender, $TOTAL_SUPPLY * 10 ** decimals());
    }
}
EOF

# Step 5: Compile contracts
echo "Compile your contracts..."
npx hardhat compile

# Step 6: Create .env file for storing private key
echo "Create .env file..."

read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY
cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF
 
# Step 7: Create deploy script
echo "Creating deploy script..."
rm ignition/modules/Lock.ts

cat <<'EOF' > ignition/modules/GMonad.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const GMonadModule = buildModule("GMonadModule", (m) => {
    const gmonad = m.contract("GMonad");

    return { gmonad };
});

module.exports = GMonadModule;
EOF

# Step 8: Deploying the smart contract
echo "Deploying the smart contract..."
# yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet --reset

sleep 3s

# 
echo "Do you want to deploy multi contract?"
read -p "Enter the number of contracts to deploy: " COUNT

# Validate input (must be a number)
if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
  echo "Please enter a valid number!"
  exit 1
fi

for ((i=1; i<=COUNT; i++))
do
  echo "🚀 Deploying contract $i..."

  # Deploy the contract and extract the contract address
  CONTRACT_ADDRESS=$(yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet --reset | grep -oE '0x[a-fA-F0-9]{40}')

  # Check if an address was retrieved
  if [[ -z "$CONTRACT_ADDRESS" ]]; then
    echo "❌ Unable to retrieve contract address!"
    exit 1
  fi

  echo "✅ Contract $i deployed at: $CONTRACT_ADDRESS"

  # Verify contract
  echo "🔍 Verifying contract $i..."
  npx hardhat verify $CONTRACT_ADDRESS --network monadTestnet

  echo "✅ Contract $i verified!"
  echo "-----------------------------------"

  # Generate a random wait time between 9-15 seconds
  RANDOM_WAIT=$((RANDOM % 7 + 9))
  echo "⏳ Waiting for $RANDOM_WAIT seconds before deploying the next contract..."
  sleep $RANDOM_WAIT
done

echo "🎉 Successfully deployed and verified $COUNT contracts!"









