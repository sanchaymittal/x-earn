import { task } from "hardhat/config"
import { utils } from "ethers"
import { config as dotEnvConfig } from "dotenv"

import CellarAdapter from "../out/CellarAdapter.sol/CellarAdapter.json"
import ERC20 from "../out/ERC20.sol/ERC20.json"

dotEnvConfig()

import { ethers } from "ethers"

export default task("do-swap", "Execute a transfer")
    .addParam("contractAddress", "The address of the CellarAdaptor contract")
    .addParam("tokenAddress", "The address of the Token contract")
    .setAction(async ({ contractAddress, tokenAddress }) => {
        const provider = new ethers.providers.JsonRpcProvider(
            // process.env.TESTNET_RPC_URL
            process.env.GOERLI_RPC_URL
        )
        const wallet = new ethers.Wallet(
            String(process.env.PRIVATE_KEY),
            provider
        )
        const cellar = new ethers.Contract(
            contractAddress,
            CellarAdapter.abi,
            wallet
        )

        const token = new ethers.Contract(tokenAddress, ERC20.abi, wallet)

        const amount = 10000
        async function swap() {
            let unsignedTx = await cellar.populateTransaction._doSwap(amount)
            unsignedTx.gasLimit = ethers.BigNumber.from("2000000")
            let txResponse = await wallet.sendTransaction(unsignedTx)
            return await txResponse.wait()
        }

        const allowance = await token.allowance(wallet.address, contractAddress)
        if (allowance.lt(amount)) {
            const approveTx = await token.approve(
                contractAddress,
                ethers.constants.MaxUint256
            )
            console.log("approveTx: ", approveTx.hash)
            await approveTx.wait()
            console.log("approveTx mined")
        } else {
            console.log(`Sufficient allowance: ${allowance.toString()}`)
        }

        let transferred = await swap()
        console.log(
            transferred.status == 1 ? "Successful transfer" : "Failed transfer"
        )
        console.log(`Transaction hash: `, transferred.transactionHash)
    })
