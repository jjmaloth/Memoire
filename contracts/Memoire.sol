// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MemoireVault
 * @dev A decentralized time-locked vault system allowing users to store content identifiers (CIDs)
 *      with controlled unlock times and permissioned access for other wallets.
 */
contract MemoireVault {
    // Maximum permissible unlock period (10 years)
    uint constant MAX_UNLOCK_PERIOD = 3650 days;

    /**
     * @dev Vault structure holding metadata and access control.
     */
    struct Vault {
        address owner;                     // Creator and owner of the vault
        string cid;                        // Content identifier (e.g. IPFS CID)
        uint unlockTime;                   // Timestamp when vault can be retrieved
        bool retrieved;                    // Flag indicating if the vault has been accessed
        mapping(address => bool) permitted; // Mapping of addresses permitted to access the vault
        address[] permittedWallets;        // Array of explicitly permitted wallet addresses
    }

    mapping(uint => Vault) private vaults;          // Mapping of vault IDs to Vaults
    mapping(address => uint[]) private userVaults;  // Mapping of user addresses to their vault IDs
    uint private vaultCounter = 1000;               // Auto-incrementing vault ID starting from 1000

    // Events for external listeners
    event VaultCreated(uint indexed vaultId, address indexed owner, string cid, uint unlockTime);
    event VaultRetrieved(uint indexed vaultId, address indexed retriever, string cid);
    event WalletPermitted(uint indexed vaultId, address indexed wallet);
    event WalletRevoked(uint indexed vaultId, address indexed wallet);
    event UnlockTimeExtended(uint indexed vaultId, uint newUnlockTime);
    event VaultDestroyed(uint indexed vaultId);

    /**
     * @dev Modifier to restrict functions to vault owners only.
     */
    modifier onlyOwner(uint vaultId) {
        require(msg.sender == vaults[vaultId].owner, "Only owner can execute");
        _;
    }

    /**
     * @notice Creates a new time-locked vault.
     * @param cid The content identifier associated with the vault.
     * @param unlockTime The future timestamp after which the vault can be accessed.
     */
    function createVault(string calldata cid, uint unlockTime) external {
        require(bytes(cid).length > 0, "CID cannot be empty");
        require(unlockTime > block.timestamp, "Unlock time must be in the future");
        require(unlockTime <= block.timestamp + MAX_UNLOCK_PERIOD, "Unlock time too far in future");

        vaultCounter++;
        Vault storage v = vaults[vaultCounter];
        v.owner = msg.sender;
        v.cid = cid;
        v.unlockTime = unlockTime;
        v.retrieved = false;

        userVaults[msg.sender].push(vaultCounter);

        emit VaultCreated(vaultCounter, msg.sender, cid, unlockTime);
    }

    /**
     * @notice Retrieve a vault's content if unlock time has passed and caller is authorized.
     * @param vaultId The ID of the vault to retrieve.
     * @return The CID associated with the vault.
     */
    function retrieveVault(uint vaultId) external returns (string memory) {
        Vault storage v = vaults[vaultId];
        require(msg.sender == v.owner || v.permitted[msg.sender], "Access denied");
        require(block.timestamp >= v.unlockTime, "Vault still locked");
        require(!v.retrieved, "Vault already retrieved");

        v.retrieved = true;
        emit VaultRetrieved(vaultId, msg.sender, v.cid);
        return v.cid;
    }

    /**
     * @notice Permit another wallet address to access a vault once it's unlocked.
     * @param vaultId The ID of the vault.
     * @param wallet The wallet address to be permitted.
     */
    function permitWallet(uint vaultId, address wallet) external onlyOwner(vaultId) {
        require(wallet != address(0), "Invalid address");
        require(!vaults[vaultId].permitted[wallet], "Wallet already permitted");

        vaults[vaultId].permitted[wallet] = true;
        vaults[vaultId].permittedWallets.push(wallet);

        emit WalletPermitted(vaultId, wallet);
    }

    /**
     * @notice Revoke a wallet's permission to access a vault.
     * @param vaultId The ID of the vault.
     * @param wallet The wallet address to be revoked.
     */
    function revokeWallet(uint vaultId, address wallet) external onlyOwner(vaultId) {
        require(vaults[vaultId].permitted[wallet], "Wallet not permitted");

        vaults[vaultId].permitted[wallet] = false;

        // Remove wallet from the permittedWallets array
        address[] storage permittedList = vaults[vaultId].permittedWallets;
        for (uint i = 0; i < permittedList.length; i++) {
            if (permittedList[i] == wallet) {
                permittedList[i] = permittedList[permittedList.length - 1];
                permittedList.pop();
                break;
            }
        }

        emit WalletRevoked(vaultId, wallet);
    }

    /**
     * @notice Get the list of vault IDs owned by a given address.
     * @param user The address whose vault IDs are to be retrieved.
     * @return An array of vault IDs.
     */
    function getVaultIds(address user) external view returns (uint[] memory) {
        return userVaults[user];
    }

    /**
     * @notice Check if a vault is currently open.
     * @param vaultId The ID of the vault.
     * @return True if open, false if still locked.
     */
    function isVaultOpen(uint vaultId) external view returns (bool) {
        return block.timestamp >= vaults[vaultId].unlockTime;
    }

    /**
     * @notice Get current status and unlock time of a vault.
     * @param vaultId The ID of the vault.
     * @return isOpen Whether the vault is open.
     * @return unlockTime The unlock timestamp.
     */
    function getVaultStatus(uint vaultId) external view returns (bool isOpen, uint unlockTime) {
        isOpen = block.timestamp >= vaults[vaultId].unlockTime;
        unlockTime = vaults[vaultId].unlockTime;
    }

    /**
     * @notice Extend the unlock time of a vault (owner-only).
     * @param vaultId The ID of the vault.
     * @param newUnlockTime The new future unlock timestamp.
     */
    function extendUnlockTime(uint vaultId, uint newUnlockTime) external onlyOwner(vaultId) {
        require(newUnlockTime > block.timestamp, "Unlock time must be in the future");
        require(newUnlockTime <= block.timestamp + MAX_UNLOCK_PERIOD, "Unlock time too far in future");
        require(newUnlockTime > vaults[vaultId].unlockTime, "New unlock time must be later");

        vaults[vaultId].unlockTime = newUnlockTime;
        emit UnlockTimeExtended(vaultId, newUnlockTime);
    }

    /**
     * @notice Destroy a vault before it becomes accessible (owner-only).
     * @param vaultId The ID of the vault.
     */
    function destroyVault(uint vaultId) external onlyOwner(vaultId) {
        require(block.timestamp < vaults[vaultId].unlockTime, "Cannot destroy unlocked vault");

        // Remove vault ID from the owner's list
        uint[] storage ids = userVaults[msg.sender];
        for (uint i = 0; i < ids.length; i++) {
            if (ids[i] == vaultId) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
                break;
            }
        }

        delete vaults[vaultId];
        emit VaultDestroyed(vaultId);
    }

    /**
     * @notice Get the list of currently permitted wallets for a vault.
     * @param vaultId The ID of the vault.
     * @return Array of permitted wallet addresses.
     */
    function getPermittedWallets(uint vaultId) external view returns (address[] memory) {
        return vaults[vaultId].permittedWallets;
    }
}
