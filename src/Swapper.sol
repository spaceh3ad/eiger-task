// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {PriceProvider} from "./PriceProvider.sol";
import {IERC20} from "./interfaces/IERC20.sol";

/// @title Swapper - A contract for swapping tokens using Uniswap V3
/// @notice This contract implements a function to swap incoming Ether for a specified ERC-20 token using Uniswap V3
/// @dev The contract uses the PriceProvider contract to fetch prices for tokens
/// @author spaceh3ad
contract Swapper is PriceProvider {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @dev The Uniswap V3 Swap Router contract address
    /// @dev https://docs.uniswap.org/contracts/v3/reference/deployments\#goerli-addresses
    ISwapRouter public constant SWAP_ROUTER =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Modifier to wrap incoming Ether into WETH (Wrapped Ether)
    modifier wrapEther() {
        WETH.deposit{value: msg.value}();
        _;
    }

    /// @dev Constructor for initializing the Swapper contract
    /// @dev The constructor calls the constructor of the PriceProvider contract
    /// @param _weth The address of the WETH (Wrapped Ether) contract
    /// @param _secondsAgo The number of seconds ago to use for fetching historical prices
    constructor(
        address _weth,
        uint16 _secondsAgo
    ) PriceProvider(_weth, _secondsAgo) {}

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @dev Function to swap incoming Ether to the specified ERC-20 token
    /// @param token The address of ERC-20 token to swap Ether for
    /// @param minAmount The minimum amount of tokens to be received after the swap
    /// @return The actual amount of tokens received after the swap
    function swapEtherToToken(
        address token,
        uint256 minAmount
    ) public payable wrapEther returns (uint) {
        return
            SWAP_ROUTER.exactInputSingle(
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: address(WETH),
                    tokenOut: token,
                    fee: 3000, // 0.3% fee
                    recipient: msg.sender,
                    deadline: block.timestamp + 1, // 1 second from now
                    amountIn: msg.value,
                    amountOutMinimum: minAmount,
                    sqrtPriceLimitX96: 0
                })
            );
    }
}
