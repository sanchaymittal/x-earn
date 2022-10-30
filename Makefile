-include .env

.PHONY: all test clean deploy-anvil

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install smartcontractkit/chainlink-brownie-contracts && forge install rari-capital/solmate && forge install foundry-rs/forge-std

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

slither :; slither ./src 

format :; prettier --write src/**/*.sol && prettier --write src/*.sol

# solhint should be installed globally
lint :; solhint src/**/*.sol && solhint src/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

# use the "@" to hide the command from your shell 
deploy-hub-goerli :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run()"  --rpc-url ${GOERLI_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

deploy-run :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run()"  --rpc-url ${TESTNET_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${POLYGON_API_KEY}  -vvvv

deploy-target-cronos :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${hub}" --rpc-url https://evm-t3.cronos.org --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv
deploy-target-polygon :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${hub}" --rpc-url https://rpc.ankr.com/polygon_mumbai  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${POLYGON_API_KEY}  -vvvv
deploy-target-gnosis :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${hub}" --rpc-url https://rpc.chiadochain.net  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast 

deploy-all :; make deploy-${network} contract=APIConsumer && make deploy-${network} contract=KeepersCounter && make deploy-${network} contract=PriceFeedConsumer && make deploy-${network} contract=VRFConsumerV2

