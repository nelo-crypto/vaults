let SimpleRewardStrategySushiSwapMasterChef = artifacts.require("./SimpleRewardStrategySushiSwapMasterChef.sol");

module.exports = function (deployer) {
    deployer.then(async () => {
        let vaultContractAddress = '';
        let vaultContract = null;

        if (vaultContractAddress === '') {
            vaultContract = await deployer.deploy(SimpleRewardStrategySushiSwapMasterChef);

            console.log('\n*************************************************************************\n');
            console.log(`SimpleRewardStrategySushiSwapMasterChef Address: ${vaultContract.address}`);
            console.log('\n*************************************************************************\n');
        } else {
            vaultContract = await SimpleRewardStrategySushiSwapMasterChef.at(vaultContractAddress);
        }

        // Replace with the actual mainnet addresses
        await vaultContract.setRewardToken('<RewardTokenAddress>');
        await vaultContract.setFirstToken('<FirstTokenAddress>');
        await vaultContract.setSecondToken('<FirstTokenAddress>');
        await vaultContract.setLpToken('<LPToken>');
        await vaultContract.setPid(<PoolPID>);
        await vaultContract.setMinSlaveBalance('30000000000000000');
        await vaultContract.setWNativeToken('<WNativeTokenAddress>');
        await vaultContract.setRouter('<RouterAddress>');
        await vaultContract.setPool('<PoolAddress>');
        await vaultContract.runAllApprovals();
    })
};