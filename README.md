# **Memoire: A Decentralized Time Capsule on EVM**

**Memoire** is a decentralized application that enables users to create and store encrypted digital memories—such as images or messages—that remain locked until a specified future unlock date. Developed as a final project for the Encode EVM Bootcamp, Memoire integrates **EVM smart contracts**, **IPFS for decentralized storage**, and **Randamu for verifiable time-based encryption** to ensure privacy, data integrity, and delayed access.

## 🔐 Core Features

- **Time-Locked Submissions** – Users upload content and define a future unlock date. Files are encrypted and stored on IPFS, remaining inaccessible until the specified time.
- **Decentralized Storage (IPFS)** – Media is stored on a distributed, verifiable network using immutable content identifiers (CIDs).
- **Smart Contract Access Control** – On-chain logic registers ownership and verifies whether a file can be unlocked, based on the wallet and timestamp.
- **Randamu Integration** – Delivers tamper-proof, verifiable encryption and unlock conditions using decentralized randomness.
- **Secure Retrieval Flow** – When the unlock date is met, users can decrypt and access their original files directly from IPFS.

## 🛠️ Tech Stack

- **Solidity** – Smart contracts governing access and identity.
- **NestJS** – Type-safe, modular backend API for uploads, encryption coordination, and blockchain interactions.
- **IPFS** – Decentralized file storage for persistent, censorship-resistant data.
- **Randamu** – Verifiable encryption and unlock timing using decentralized randomness.
- **React/Next.js** – Optional frontend stack for user interaction.

## 📦 Use Cases

- Digital legacy capsules
- Time-released personal notes or art
- Delayed self-publishing
- Promotional or creative drops with future access windows

---

> Memoire was developed as a capstone project for the Encode EVM Bootcamp, showcasing applied use of decentralized technologies for private, timed content distribution.

