// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import "./interfaces/IWETH9.sol";

/// @author spaceh3ad
/// @title PriceProvider - A contract for fetching token prices using Uniswap V3
/// @notice This contract implements a function to estimate the output amount based on TWAP (Time-Weighted Average Price)
/// @dev The contract uses the OracleLibrary to fetch prices for tokens
contract PriceProvider {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @dev Uniswap V3 Factory contract address
    /// @dev https://docs.uniswap.org/contracts/v3/reference/deployments#goerli-addresses
    address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    /// @dev Wrapped Ether (wETH) contract instance
    WETH9 immutable wETH;

    /// @dev Time interval in seconds for TWAP calculation
    uint32 immutable secondsAgo; // 8 hours

    /// @dev Fee level for Uniswap V3 pools
    uint16 constant FEE = 3000; // choose 0.3% fee pools

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @dev Error thrown when try to swap through non-exsitant pool
    error InvalidPool();

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev Constructor to initialize the PriceProvider contract
    /// @param _weth Address of the Wrapped Ether (wETH) contract
    /// @param _secondsAgo Time interval in seconds for TWAP calculation
    constructor(address _weth, uint16 _secondsAgo) {
        wETH = WETH9(_weth);
        secondsAgo = _secondsAgo;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Function to estimate the output amount based on TWAP (Time-Weighted Average Price)
    /// @param tokenOut Address of the output token
    /// @param amountIn Amount of input token
    /// @return amountOut Estimated output amount
    function estimateAmountOut(
        address tokenOut,
        uint128 amountIn
    ) external view returns (uint256 amountOut) {
        address pool = IUniswapV3Factory(FACTORY).getPool(
            tokenOut,
            address(wETH),
            FEE
        );

        if (pool == address(0)) {
            revert InvalidPool();
        }

        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);
        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            address(wETH),
            tokenOut
        );
    }
}
