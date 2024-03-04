// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {Multisig} from "../src/Multisig.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";

contract MultisigUnit is Test {
    event Upgrade(address newContract);

    Multisig public multisig;

    address alice = makeAddr("alice");

    address exampleWETH = makeAddr("exampleWETH");

    address signer1 = makeAddr("signer1");
    address signer2 = makeAddr("signer2");
    address signer3 = makeAddr("signer3");
    address signer4 = makeAddr("signer4");
    address signer5 = makeAddr("signer5");

    address newImplementation = makeAddr("newImplementation");
    address newImplementation2 = makeAddr("newImplementation2");

    function setUp() public {
        address[] memory signers = new address[](5);

        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        signers[3] = signer4;
        signers[4] = signer5;

        vm.mockCall(
            exampleWETH,
            abi.encodeWithSelector(
                IERC20.approve.selector,
                0xE592427A0AEce92De3Edee1F18E0157C05861564,
                type(uint256).max
            ),
            abi.encode(true)
        );

        multisig = new Multisig(3, signers, address(1234567890), exampleWETH);
        console.logBytes(
            abi.encode(3, signers, address(1234567890), exampleWETH)
        );
        vm.deal(alice, 2 ether);
    }

    function test_proposeUpgrade() public {
        vm.startPrank(signer1);
        vm.expectRevert(Multisig.InvalidContract.selector);
        multisig.proposeUpgrade(address(0));

        multisig.proposeUpgrade(newImplementation);
        assertEq(multisig.upgradeInProgress(), true);
        assertEq(multisig.newContract(), newImplementation);

        vm.expectRevert(Multisig.TimeLockNotExpired.selector);
        multisig.proposeUpgrade(newImplementation2);

        vm.warp(25 hours);
        multisig.proposeUpgrade(newImplementation2);

        vm.stopPrank();
    }

    function test_approveUpgrade() public {
        vm.prank(signer1);
        multisig.proposeUpgrade(newImplementation);

        vm.prank(signer2);
        multisig.approveUpgrade();

        vm.expectRevert(Multisig.AlreadyApproved.selector);
        vm.prank(signer2);
        multisig.approveUpgrade();

        vm.expectEmit(true, false, false, true);
        emit Upgrade(newImplementation);

        vm.prank(signer3);
        multisig.approveUpgrade();

        vm.expectRevert(Multisig.NoUpgradeInProgress.selector);
        vm.prank(signer4);
        multisig.approveUpgrade();
    }

    function invariant_singersConsistency() public {
        assertEq(multisig.isSigner(signer1), true);
        assertEq(multisig.isSigner(signer2), true);
        assertEq(multisig.isSigner(signer3), true);
        assertEq(multisig.isSigner(signer4), true);
        assertEq(multisig.isSigner(signer5), true);
    }

    function invariant_upgrade() public {
        address _proxy = address(multisig.proxy());
        assert(_proxy != address(0) && _proxy != multisig.newContract());
    }
}
