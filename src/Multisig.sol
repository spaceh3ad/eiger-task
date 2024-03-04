// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Proxy} from "./Proxy.sol";

/// @author spaceh3ad
/// @title Multisig Wallet Contract with Upgradeable Proxy Pattern
/// @notice This contract implements a multisig wallet with an upgrade mechanism for the associated proxy contract.
/// @dev The contract uses a proposal versioning system to efficiently manage upgrade proposals without requiring iteration over signers for each proposal.
contract Multisig {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Time lock duration for upgrades.
    uint32 public constant TIME_LOCK_DURATION = 24 hours;

    /// @dev Timestamp of the last upgrade attempt.
    uint32 public lastUpgradeTimestamp;

    /// @dev Minimum required signatures for actions.
    uint8 immutable threshold;

    /// @dev Count of approvals for the current upgrade.
    uint8 private approvalCount;

    /// @dev Flag indicating if an upgrade process is currently active.
    bool public upgradeInProgress;

    /// @dev Current proposal version.
    uint16 private currentProposalVersion;

    /// @dev Instance of the Proxy contract.
    Proxy public immutable proxy;

    /// @dev Address of the new contract for upgrades.
    address public newContract;

    /// @dev Mapping to track if an address is a signer.
    mapping(address => bool) public isSigner;

    /// @dev Maps signer addresses to the last proposal version they approved.
    mapping(address => uint256) private lastApprovedVersion;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Error thrown when the proposed contract address is invalid.
    error InvalidContract();

    /// @dev Error thrown when the contract setup is invalid.
    error InvalidSetup();

    /// @dev Error thrown when the signer address is invalid.
    error InvalidSigner();

    /// @dev Error thrown when an upgrade is not in progress.
    error NoUpgradeInProgress();

    /// @dev Error thrown when the signer has already approved the current proposal.
    error AlreadyApproved();

    /// @dev Error thrown when the time lock for an upgrade has not expired.
    error TimeLockNotExpired();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @dev Emitted when an upgrade is successfully executed.
    /// @param newContract Address of the new contract to which the proxy was upgraded.
    event Upgrade(address indexed newContract);

    /// @dev Emitted when a new upgrade proposal is made.
    /// @param proposedContract Address of the contract proposed for upgrade.
    /// @param proposalVersion Version of the proposal made.
    event UpgradeProposed(
        address indexed proposedContract,
        uint256 indexed proposalVersion
    );

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier to restrict function access to only signer addresses.
    /// @notice Reverts if the caller is not a signer.
    modifier onlySigner() {
        if (!isSigner[msg.sender]) revert InvalidSigner();
        _;
    }

    /// @notice Modifier to ensure no upgrade is in progress or the time lock has expired.
    /// @notice Reverts if an upgrade is in progress or the time lock has not expired.
    modifier upgradeNotInProgress() {
        if (
            upgradeInProgress &&
            block.timestamp <= lastUpgradeTimestamp + TIME_LOCK_DURATION
        ) revert TimeLockNotExpired();
        _;
    }

    /// @notice Constructs a new Multisig contract.
    /// @notice Initializes the contract with the provided threshold, signers, and initial implementation.
    /// @notice Reverts if the threshold is less than 3, greater than the number of signers, or if the WETH or implementation addresses are zero.
    /// @notice Reverts if any of the signers is the zero address.
    /// @param _threshold Minimum number of approvals required for an action.
    /// @param _signers Initial list of signers.
    /// @param _implementation Address of the initial contract implementation for the proxy.
    /// @param _weth Address of the WETH token, for example, used within the proxy or contract logic.
    constructor(
        uint8 _threshold,
        address[] memory _signers,
        address _implementation,
        address _weth
    ) {
        if (
            _threshold < 3 ||
            _threshold > _signers.length ||
            _weth == address(0) ||
            _implementation == address(0)
        ) revert InvalidSetup();

        threshold = _threshold;
        proxy = new Proxy(_implementation, address(this), _weth);

        for (uint256 i = 0; i < _signers.length; i++) {
            if (_signers[i] == address(0)) revert InvalidSigner();
            isSigner[_signers[i]] = true;
        }
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Proposes a new contract address for upgrading the proxy.
    /// @notice Emits an UpgradeProposed event and increments the proposal version.
    /// @notice reverts if the proposed contract is the same as the current contract or the zero address.
    /// @dev Increments the proposal version, effectively resetting approvals.
    /// @param _newContract The address of the proposed new contract.
    function proposeUpgrade(
        address _newContract
    ) external onlySigner upgradeNotInProgress {
        if (address(proxy) == _newContract || _newContract == address(0)) {
            revert InvalidContract();
        }

        upgradeInProgress = true;
        lastUpgradeTimestamp = uint32(block.timestamp);
        newContract = _newContract;
        currentProposalVersion++;
        approvalCount = 1; // Count proposer as 1st voter

        emit UpgradeProposed(_newContract, currentProposalVersion);
    }

    /// @notice Approves the current upgrade proposal.
    /// @notice emits an Upgrade event and upgrades the proxy if the threshold is reached.
    /// @notice revert if the upgrade is not in progress or the signer has already approved the current proposal.
    /// @dev Signers can only approve once per proposal version.
    function approveUpgrade() external onlySigner {
        if (!upgradeInProgress) {
            revert NoUpgradeInProgress();
        }
        if (lastApprovedVersion[msg.sender] == currentProposalVersion) {
            revert AlreadyApproved();
        }

        lastApprovedVersion[msg.sender] = currentProposalVersion;
        approvalCount++;

        if (approvalCount == threshold) {
            upgradeInProgress = false;
            lastUpgradeTimestamp = 0;
            approvalCount = 0;
            emit Upgrade(newContract);
            proxy.upgradeTo(newContract);
        }
    }
}
