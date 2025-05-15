-include .env

build:; forge build

deploy-seplock:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) 