require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
var path = require('path');
const {PRIVATE_KEY} = process.env;

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    contracts_build_directory: path.join(__dirname, "client/src/contracts"),
    networks: {
        develop: {
            port: 8545
        },
        hecomainnet: {
            provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://http-mainnet.hecochain.com'),
            network_id: 128,
        },
        auroramainnet: {
            provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://mainnet.aurora.dev'),
            network_id: 1313161554,
            gas: 10000000
        },
        fantommainnet: {
            provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://rpc.ftm.tools'),
            network_id: 250,
            gas: 1000000
        },
        harmonymainnet: {
            provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://api.harmony.one'),
            network_id: 1666600000,
            gas: 8000000
        },
        andromedamainnet: {
            provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://andromeda.metis.io/'),
            network_id: 1088,
            gas: 8000000
        },
    },
    compilers: {
        solc: {
            version: "0.8.10"
        }
    },
    plugins: [
        'truffle-contract-size'
    ]
};