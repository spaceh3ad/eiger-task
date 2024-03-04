// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface IERC20 {
    function balanceOf(address) external view returns (uint);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);
}
