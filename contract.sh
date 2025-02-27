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
echo "Create ERC20 contract..."
rm contracts/Lock.sol

cat <<'EOF' > contracts/GMonad.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GMonad {
    function sayGmonad() public pure returns (string memory) {
        return "gmonad";
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
yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet

sleep 3s

# Nhập số lượng contract cần deploy
read -p "Nhập số lượng contract cần deploy: " COUNT

# Kiểm tra nếu COUNT không phải là số
if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
  echo "Vui lòng nhập một số hợp lệ!"
  exit 1
fi

for ((i=1; i<=COUNT; i++))
do
  echo "🚀 Deploying contract $i..."

  # Deploy contract và lấy địa chỉ
  CONTRACT_ADDRESS=$(yes | npx hardhat ignition deploy ./ignition/modules/GMonad.ts --network monadTestnet --reset | grep -oE '0x[a-fA-F0-9]{40}')

  # Kiểm tra nếu lấy được địa chỉ
  if [[ -z "$CONTRACT_ADDRESS" ]]; then
    echo "❌ Lỗi: Không thể lấy địa chỉ contract!"
    exit 1
  fi

  echo "✅ Contract $i deployed at: $CONTRACT_ADDRESS"

  # Verify contract
  echo "🔍 Verifying contract $i..."
  npx hardhat verify $CONTRACT_ADDRESS --network monadTestnet

  echo "✅ Contract $i verified!"
  echo "-----------------------------------"

  # Tạo thời gian chờ ngẫu nhiên từ 5-9 giây
  RANDOM_WAIT=$((RANDOM % 5 + 5))
  echo "⏳ Chờ $RANDOM_WAIT giây trước khi deploy tiếp..."
  sleep $RANDOM_WAIT
done

echo "🎉 Hoàn thành deploy và verify $COUNT contract!"









