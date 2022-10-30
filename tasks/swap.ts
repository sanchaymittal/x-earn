import { task } from "hardhat/config"
import { config as dotEnvConfig } from "dotenv"

import CellarAdapter from "../out/CellarAdapter.sol/CellarAdapter.json"

dotEnvConfig()

import { ethers } from "ethers"

export default task("do-swap", "Execute a transfer")
    .addParam("contractAddress", "The address of the CellarAdaptor contract")
    .addParam("amount", "The amount to send")
    .setAction(async ({ contractAddress, amount }) => {
        const provider = new ethers.providers.JsonRpcProvider(
            process.env.TESTNET_RPC_URL
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

        async function swap() {
            let unsignedTx = await cellar.populateTransaction._doSwap(amount)
            unsignedTx.gasLimit = ethers.BigNumber.from("2000000")
            let txResponse = await wallet.sendTransaction(unsignedTx)
            return await txResponse.wait()
        }

        let transferred = await swap()
        console.log(
            transferred.status == 1 ? "Successful transfer" : "Failed transfer"
        )
        console.log(`Transaction hash: `, transferred.transactionHash)
    })
