import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "dotenv/config";

const config: HardhatUserConfig = {
    solidity: "0.8.0",
    paths: {
        sources: "./contracts", // Directory for contracts
        artifacts: "./artifacts", // Directory for artifacts
    },
    networks: {
        goerli: {
            url: process.env.RPC_URL,
            accounts: [process.env.PRIVATE_KEY ?? (() => { throw new Error("PRIVATE_KEY is not defined in the environment variables"); })()],
        },
    },
};

export default config;