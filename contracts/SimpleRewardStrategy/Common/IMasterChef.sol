// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.6;

interface IMasterChef {
    function deposit(uint256 pid, uint256 amount) external;

    function withdraw(uint256 pid, uint256 amount) external;

    function emergencyWithdraw(uint256 pid) external;
}