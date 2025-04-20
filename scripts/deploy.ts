import * as dotenv from 'dotenv';
import { createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { sepolia } from 'viem/chains'; // Use Sepolia instead of Goerli
import fs from 'fs';
import path from 'path';
import { ethers } from 'ethers';

dotenv.config({ path: '/workspaces/Memoire/memoire/.env' });

console.log('PRIVATE_KEY:', process.env.PRIVATE_KEY);
console.log('RPC_URL:', process.env.RPC_URL);

const rawPrivateKey = process.env.PRIVATE_KEY || '';
if (!rawPrivateKey) {
    throw new Error('PRIVATE_KEY is not defined in the .env file');
}
const PRIVATE_KEY = rawPrivateKey.startsWith('0x') ? rawPrivateKey : `0x${rawPrivateKey}`;

const RPC_URL = process.env.RPC_URL || '';
if (!RPC_URL) {
    throw new Error('RPC_URL is not defined in the .env file');
}

async function main() {
    const account = privateKeyToAccount(PRIVATE_KEY as `0x${string}`);

    const client = createWalletClient({
        account,
        chain: sepolia, // Use Sepolia
        transport: http(RPC_URL),
    });

    // Path to the compiled contract artifact
    const artifactPath = path.join(__dirname, '../artifacts/contracts/Memoire.sol/MemoireVault.json');
    console.log('Artifact Path:', artifactPath);

    // Load the ABI and bytecode from the artifact
    const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
    const abi = artifact.abi;
    const bytecode = artifact.bytecode as `0x${string}`;

    // Deploy the contract
    console.log('Deploying contract...');
    const hash = await client.deployContract({
        abi,
        bytecode,
        args: [], // Add constructor arguments here if required
    });

    console.log('Transaction hash:', hash);

    // Wait for the transaction to be mined
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    console.log('Waiting for transaction to be mined...');
    const receipt = await provider.waitForTransaction(hash);

    if (receipt && receipt.contractAddress) {
        console.log('Contract deployed to:', receipt.contractAddress);
    } else {
        console.error('Failed to retrieve contract address from receipt.');
    }
}

main().catch((err) => {
    console.error('Deployment failed:', err);
    process.exit(1);
});