// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {Swapper} from "../src/Swapper.sol";

import {Proxy} from "../src/Proxy.sol";

import {Multisig} from "../src/Multisig.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";

contract ProxyUnit is Test {
    event Upgraded(address indexed newContract);

    Config config;

    struct Config {
        address weth;
        address token;
        uint16 secondsAgo;
    }

    Proxy public proxy;
    Swapper public swapper;

    address alice = makeAddr("alice");

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
        proxy = new Proxy(address(swapper), address(this), config.weth);

        vm.deal(alice, 2 ether);

        vm.label(address(proxy), "Proxy");
        vm.label(address(swapper), "Swapper");
    }

    function test_fallback() public {
        vm.startPrank(alice);

        address(proxy).call{value: 1 ether}(
            abi.encodeWithSignature(
                "swapEtherToToken(address,uint256)",
                config.token,
                0
            )
        );
        assertGt(IERC20(config.token).balanceOf(alice), 0);

        vm.expectRevert(Proxy.DelegateCallFailed.selector);
        address(proxy).call(
            abi.encodeWithSignature("nonExistingFunction(uint256)", 1337)
        );

        vm.stopPrank();
    }

    function test_upgradeTo() public {
        vm.expectEmit(true, true, false, true);
        emit Upgraded(address(12345));
        proxy.upgradeTo(address(12345));

        vm.expectRevert(Proxy.OnlyMultisig.selector);
        vm.prank(alice);
        proxy.upgradeTo(address(12345));
    }
}
