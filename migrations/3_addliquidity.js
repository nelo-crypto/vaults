let SimpleRewardStrategy = artifacts.require("./SimpleRewardStrategy.sol");

module.exports = function (deployer) {
    deployer.then(async () => {
        let vault = await SimpleRewardStrategy.at('<VaultContractAddress>');

        const tx = await vault.addLiquidity();
        console.log(tx);
    })
};