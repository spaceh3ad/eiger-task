// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "./interfaces/IERC20.sol";

/// @title Proxy - A contract for delegating function calls to an implementation contract
/// @author spaceh3ad
/// @notice This contract implements a proxy pattern to delegate function calls to an implementation contract
/// @dev The contract uses the EIP-1967 storage slot for the implementation contract address
contract Proxy {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Address of the multisig account allowed to upgrade the implementation
    address public immutable multisig;

    /// @dev Explicit storage slot for the implementation contract address, as per EIP-1967.
    uint256 constant EIP1967_IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Error thrown when only the multisig address is allowed to perform an action
    error OnlyMultisig();

    /// @dev Error thrown when an address is expected to be non-zero but is zero
    error ZeroAddress();

    /// @dev Error thrown when a delegate call to the implementation contract fails
    error DelegateCallFailed(bytes resultData);

    /// @dev Error thrown when the approval of Uniswap Router for spending WETH fails
    error ApproveFailed();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Event emitted when the implementation contract is upgraded, required by EIP-1967
    event Upgraded(address indexed implementation);

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if any of the input addresses is zero
    /// @dev Constructor to initialize the Proxy contract
    /// @param _implementation Address of the initial implementation contract
    /// @param _multisig Address of the multisig account allowed to upgrade the implementation
    /// @param _weth Address of the WETH (Wrapped Ether) contract
    constructor(address _implementation, address _multisig, address _weth) {
        if (
            _implementation == address(0) ||
            _multisig == address(0) ||
            _weth == address(0)
        ) revert ZeroAddress();

        multisig = _multisig;

        /// @dev Approve Uniswap Router for spending WETH
        bool ok = IERC20(_weth).approve(
            0xE592427A0AEce92De3Edee1F18E0157C05861564,
            type(uint256).max
        );
        if (!ok) revert ApproveFailed();

        _setImplementation(_implementation);
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the caller is not the multisig account
    /// @dev Function to upgrade the implementation contract
    /// @param _implementation Address of the new implementation contract
    function upgradeTo(address _implementation) external {
        if (msg.sender != multisig) revert OnlyMultisig();
        _setImplementation(_implementation);
    }

    /// @dev Fallback function to delegate calls to the implementation contract
    /// @notice Reverts if the delegate call to the implementation contract fails
    fallback(
        bytes calldata callData
    ) external payable returns (bytes memory resultData) {
        address implementation;

        assembly {
            implementation := sload(EIP1967_IMPLEMENTATION_SLOT)
        }

        bool success;

        (success, resultData) = implementation.delegatecall(callData);

        if (!success) {
            revert DelegateCallFailed(resultData);
        }

        return resultData;
    }

    receive() external payable {}

    /// @notice Emits an Upgraded event as per EIP-1967
    /// @dev Internal function to set the implementation contract address
    /// @param _implementation Address of the new implementation contract
    function _setImplementation(address _implementation) private {
        emit Upgraded(_implementation);
        assembly {
            sstore(EIP1967_IMPLEMENTATION_SLOT, _implementation)
        }
    }
}
