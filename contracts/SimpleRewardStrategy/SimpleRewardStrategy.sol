// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../BaseStrategyVault.sol";

contract SimpleRewardStrategy is BaseStrategyVault(1)
{
    // Tokens
    address public _rewardToken;
    address public _firstToken;
    address public _secondToken;
    address public _lpToken;
    address public _wNativeToken;

    // Contracts
    address public _router;
    address public _pool;

    uint256 public _pid = 0;
    uint256 public _minSlaveBalance = 0;

    uint public _strategyVersion = 6;

    event Received(address, uint);
    event Reinvest(uint256 _rewardAmount);
    event RefillMinSlaveBalance(uint256 _rewardAmount);

    function checkConfig() internal {
        require(_rewardToken != address(0), "001: Reward token not set");
        require(_firstToken != address(0), "002: First token not set");
        require(_secondToken != address(0), "003: Second token not set");
        require(_lpToken != address(0), "004: LP token not found");
        require(_wNativeToken != address(0), "009: W Native token not found");
        require(_router != address(0), "005: Router address not set");
        require(_pool != address(0), "007: Pool address not set");
        require(_pid != 0, "008: PID is not set");
        require(_minSlaveBalance != 0, "010: Min slave balance not set");
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);

        _slave.transfer(address(this).balance);
    }

    function setRewardToken(address newRewardToken) public onlyMaster {
        require(newRewardToken != address(0));
        _rewardToken = newRewardToken;
    }

    function setFirstToken(address newFirstToken) public onlyMaster {
        require(newFirstToken != address(0));
        _firstToken = newFirstToken;
    }

    function setSecondToken(address newSecondToken) public onlyMaster {
        require(newSecondToken != address(0));
        _secondToken = newSecondToken;
    }

    function setLpToken(address newLpToken) public onlyMaster {
        require(newLpToken != address(0));
        _lpToken = newLpToken;
    }

    function setPid(uint256 pid) public onlyMaster {
        _pid = pid;
    }

    function setMinSlaveBalance(uint256 minSlaveBalance) public onlyMaster {
        _minSlaveBalance = minSlaveBalance;
    }

    function setWNativeToken(address newWNativeToken) public onlyMaster {
        require(newWNativeToken != address(0));
        _wNativeToken = newWNativeToken;
    }

    function setRouter(address newRouter) public onlyMaster {
        require(newRouter != address(0));
        _router = newRouter;
    }

    function setPool(address newPool) public onlyMaster {
        require(newPool != address(0));
        _pool = newPool;
    }
}