// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {Swapper} from "../src/Swapper.sol";
import {PriceProvider} from "../src/PriceProvider.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";

contract SwapperUnit is Test {
    event Upgraded(address indexed newContract);

    Swapper swapper;
    Config config;

    address alice = makeAddr("alice");

    struct Config {
        address weth;
        address token;
        uint16 secondsAgo;
    }

    function setUp() public {
        string memory rpc = "goerli";
        vm.createSelectFork(rpc);

        config = Config({
            weth: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6,
            token: 0xdD69DB25F6D620A7baD3023c5d32761D353D3De9,
            ///@dev secondsAgo error https://docs.uniswap.org/contracts/v3/reference/error-codes
            secondsAgo: 10 // for goerli we use lower value to aviod OLD error
        });

        swapper = new Swapper(config.weth, config.secondsAgo);

        vm.deal(alice, 2 ether);
    }

    function test_getAmountOut() public {
        vm.expectRevert(PriceProvider.InvalidPool.selector);
        swapper.estimateAmountOut(
            address(0xdead), // tokenOut (invalid token address)
            1 ether // amount in eth
        );

        uint256 amountOut = swapper.estimateAmountOut(
            config.token,
            1 ether // amount in eth
        );

        assertGt(amountOut, 0);
    }

    function test_swap() public {
        // we need to approve weth for uni router (using proxy handles that)
        vm.prank(address(swapper));
        IERC20(config.weth).approve(
            0xE592427A0AEce92De3Edee1F18E0157C05861564,
            type(uint256).max
        );

        vm.prank(alice);
        uint256 actualAmountOut = swapper.swapEtherToToken{value: 1 ether}(
            config.token,
            0
        );

        assertEq(IERC20(config.token).balanceOf(alice), actualAmountOut);
    }

    function test_invalidToken() public {
        vm.expectRevert(PriceProvider.InvalidPool.selector);
        swapper.estimateAmountOut(address(0xdead), 1 ether);

        vm.expectRevert();
        vm.prank(alice);
        swapper.swapEtherToToken{value: 1 ether}(address(0xdead), 0);
    }
}
