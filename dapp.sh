#!/bin/bash
# Logo
curl -s https://raw.githubusercontent.com/ToanBm/user-info/main/logo.sh | bash
sleep 3

show() {
    echo -e "\033[1;35m$1\033[0m"
}

# Step 1: Clone the Scaffold-Eth-Monad repo
echo "Clone the Scaffold-Eth-Monad repo..."
git clone https://github.com/monad-developers/scaffold-eth-monad.git

echo "Open the project directory and install dependencies..."
cd scaffold-eth-monad && yarn install

# Step 2: Setup .env file for Hardhat
echo "Create .env file..."
cd packages/hardhat

read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY
cat <<EOF > .env
DEPLOYER_PRIVATE_KEY=$DEPLOYER_PRIVATE_KEY=
EOF

# Step 3: Deploying the smart contract
echo "Deploying the smart contract..."
yarn deploy --network monadTestnet

# Step 4: Setup .env file for Next.js app (optional):
cd ../../
cd packages/nextjs

read -p "Enter your EVM wallet private key (without 0x): " NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID
cat <<EOF > .env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=$NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID
EOF

# Step 5: On a second terminal, start your NextJS app:
yarn start


