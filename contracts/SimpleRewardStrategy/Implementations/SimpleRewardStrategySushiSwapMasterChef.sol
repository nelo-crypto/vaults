// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../Common/IERC20.sol";
import "../Common/IUniswapV2Router.sol";
import "../Common/IMasterChef.sol";
import "../SimpleRewardStrategy.sol";

contract SimpleRewardStrategySushiSwapMasterChef is SimpleRewardStrategy
{
    function refillMinSlaveBalance(uint256 currentRewardsAmount) onlyMasterOrSlave public {
        address[] memory _rewardToWNativePath = new address[](2);

        _rewardToWNativePath[0] = _rewardToken;
        _rewardToWNativePath[1] = _wNativeToken;

        IUniswapV2Router routerInstance = IUniswapV2Router(_router);

        uint256 amountInForFullRefill = routerInstance.getAmountsIn(
            _minSlaveBalance,
            _rewardToWNativePath
        )[0];

        if (amountInForFullRefill > currentRewardsAmount) {
            // Swap all rewards into gas refill
            routerInstance.swapExactTokensForETH(
                currentRewardsAmount,
                0,
                _rewardToWNativePath,
                address(this),
                block.timestamp + 1 days
            );

            emit RefillMinSlaveBalance(currentRewardsAmount);
        } else {
            // Swap only what is needed, leave the rest for normal processing
            routerInstance.swapExactTokensForETH(
                amountInForFullRefill,
                0,
                _rewardToWNativePath,
                address(this),
                block.timestamp + 1 days
            );

            emit RefillMinSlaveBalance(amountInForFullRefill);
        }
    }

    /**
    * @dev Node bot should call this function
     */
    function reinvest() onlyMasterOrSlave public {
        runWriteCommand(0);
        runWriteCommand(1);

        IMasterChef(_pool).deposit(_pid, 0);

        uint256 rewardsAmount = IERC20(_rewardToken).balanceOf(address(this));

        emit Reinvest(rewardsAmount);

        // Zero or not divisible
        if (rewardsAmount <= 1) {
            return;
        }

        if (address(_slave).balance < _minSlaveBalance) {
            refillMinSlaveBalance(rewardsAmount);

            // Reupdate rewards amount
            rewardsAmount = IERC20(_rewardToken).balanceOf(address(this));

            if (rewardsAmount <= 1) {
                return;
            }
        }

        uint256 amountTokenIn = rewardsAmount / 2;

        address[] memory _rewardToFirstTokenPath = new address[](2);
        _rewardToFirstTokenPath[0] = _rewardToken;
        _rewardToFirstTokenPath[1] = _firstToken;

        address[] memory _rewardToSecondTokenPath = new address[](2);
        _rewardToSecondTokenPath[0] = _rewardToken;
        _rewardToSecondTokenPath[1] = _secondToken;

        IUniswapV2Router routerInstance = IUniswapV2Router(_router);

        routerInstance.swapExactTokensForTokens(
            amountTokenIn,
            0,
            _rewardToFirstTokenPath,
            address(this),
            block.timestamp + 1 days
        )[1];

        routerInstance.swapExactTokensForTokens(
            amountTokenIn,
            0,
            _rewardToSecondTokenPath,
            address(this),
            block.timestamp + 1 days
        )[1];

        addLiquidity();
    }

    /**
    * @dev Node bot should call this function
     */
    function addLiquidity() onlyMasterOrSlave public {
        IUniswapV2Router routerInstance = IUniswapV2Router(_router);

        uint256 firstAmount = IERC20(_firstToken).balanceOf(address(this));
        uint256 secondAmount = IERC20(_secondToken).balanceOf(address(this));

        routerInstance.addLiquidity(
            _firstToken,
            _secondToken,
            firstAmount,
            secondAmount,
            0,
            0,
            address(this),
            block.timestamp + 1 days
        );

        uint _lpAmount = IERC20(_lpToken).balanceOf(address(this));

        IMasterChef(_pool).deposit(_pid, _lpAmount);
    }

    function runAllApprovals() public onlyMaster {
        runRouterApprovals();
        runPoolApprovals();
    }

    function runRouterApprovals() public onlyMaster {
        runRouterApproval(_rewardToken);
        runRouterApproval(_firstToken);
        runRouterApproval(_secondToken);
        runRouterApproval(_wNativeToken);
    }

    function runPoolApprovals() public onlyMaster {
        runPoolApproval(_lpToken);
    }

    function runRouterApproval(address token) internal {
        uint256 allowance = IERC20(token).allowance(address(this), _router);
        uint256 maxAllowance = 2 ** 256 - 1;

        if (allowance == 0) {
            IERC20(token).approve(_router, maxAllowance);
        }
    }

    function runPoolApproval(address token) internal {
        uint256 allowance = IERC20(token).allowance(address(this), _pool);
        uint256 maxAllowance = 2 ** 256 - 1;

        if (allowance == 0) {
            IERC20(token).approve(_pool, maxAllowance);
        }
    }

    function emergencyExit() onlyMaster public {
        IMasterChef(_pool).emergencyWithdraw(_pid);

        withdrawLpToken();
        withdrawRewardToken();
        withdrawFirstToken();
        withdrawSecondToken();
        withdrawNativeBalance();
    }

    function emergencyExitCustomPid(uint256 pid) onlyMaster public {
        IMasterChef(_pool).emergencyWithdraw(pid);

        withdrawLpToken();
        withdrawRewardToken();
        withdrawFirstToken();
        withdrawSecondToken();
        withdrawNativeBalance();
    }

    function withdraw(uint256 pid, uint256 amount) onlyMaster public {
        withdrawLp(pid, amount);
        withdrawLpToken();
        withdrawRewardToken();
        withdrawFirstToken();
        withdrawSecondToken();
        withdrawNativeBalance();
    }

    function withdrawLp(uint256 pid, uint256 amount)  onlyMaster public {
        IMasterChef(_pool).withdraw(pid, amount);
    }

    function withdrawLpToken() onlyMaster public {
        uint256 lpAmount = IERC20(_lpToken).balanceOf(address(this));
        if (lpAmount > 0) {
            IERC20(_lpToken).transfer(_master, lpAmount);
        }
    }

    function withdrawNativeBalance() onlyMaster public {
        if (address(this).balance > 0) {
            _slave.transfer(address(this).balance);
        }
    }

    function withdrawFirstToken() onlyMaster public {
        uint256 firstAmount = IERC20(_firstToken).balanceOf(address(this));
        if (firstAmount > 0) {
            IERC20(_firstToken).transfer(_master, firstAmount);
        }
    }

    function withdrawSecondToken() onlyMaster public {
        uint256 secondAmount = IERC20(_secondToken).balanceOf(address(this));
        if (secondAmount > 0) {
            IERC20(_secondToken).transfer(_master, secondAmount);
        }
    }

    function withdrawRewardToken() onlyMaster public {
        uint256 rewardAmount = IERC20(_rewardToken).balanceOf(address(this));
        if (rewardAmount > 0) {
            IERC20(_rewardToken).transfer(_master, rewardAmount);
        }
    }
}