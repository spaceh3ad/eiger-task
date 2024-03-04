// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Swapper} from "../src/Swapper.sol";
import {Multisig} from "../src/Multisig.sol";

contract DeployScript is Script {
    Config config;

    Swapper public swapper;
    Multisig public multisig;

    address signer1 = makeAddr("signer1");
    address signer2 = makeAddr("signer2");
    address signer3 = makeAddr("signer3");
    address signer4 = makeAddr("signer4");
    address signer5 = makeAddr("signer5");

    address[] signers = new address[](5);

    struct Config {
        address weth;
        address token;
        uint16 secondsAgo;
    }

    function setUp() public {
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        signers[3] = signer4;
        signers[4] = signer5;

        config = Config({
            weth: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6,
            token: 0xdD69DB25F6D620A7baD3023c5d32761D353D3De9,
            ///@dev secondsAgo error https://docs.uniswap.org/contracts/v3/reference/error-codes
            secondsAgo: 10 // for goerli we use lower value to aviod OLD error
        });
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        swapper = new Swapper(config.weth, config.secondsAgo);
        multisig = new Multisig(3, signers, address(swapper), config.weth);
        vm.stopBroadcast();
    }
}
