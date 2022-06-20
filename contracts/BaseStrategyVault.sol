// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.6;

contract BaseStrategyVault {
    address public _master;
    address payable public _slave;
    uint public _version = 4;
    uint public _flavour = 0;

    struct Command {
        address payable remoteTarget;
        bytes remoteFunctionEncoding;
        uint256 gas;
        bool isActive;
    }

    mapping(uint256 => Command) public _commands;

    event CommandResponse(bool success, bytes data);

    /**
     * @dev Throws if called by any account other than the master.
     */
    modifier onlyMaster() {
        require(_master == msg.sender, "Caller is not the master");
        _;
    }

    /**
     * @dev Throws if called by any account not master or slave.
     */
    modifier onlyMasterOrSlave() {
        require((_master == msg.sender) || (_slave == msg.sender), "Caller is not the master or slave");
        _;
    }

    constructor(uint flavour) public
    {
        // Both _master and _slave set to vitalik.eth but you should change this
        _master = address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);
        _slave = payable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);
        _flavour = flavour;
    }

    // This function really needs to be here
    function remoteWriteCommand(
        address payable remoteTarget,
        bytes memory remoteFunctionEncoding,
        uint256 gas
    ) onlyMaster public payable returns (bool, bytes memory) {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = remoteTarget.call{value : msg.value, gas : gas}(remoteFunctionEncoding);

        emit CommandResponse(success, data);

        require(success, "012: Remote write command failed");

        return (success, data);
    }

    // This function really needs to be here
    function remoteReadCommand(
        address remoteTarget,
        bytes memory remoteFunctionEncoding
    ) onlyMaster public view returns (bool, bytes memory) {
        (bool success, bytes memory data) = remoteTarget.staticcall(remoteFunctionEncoding);

        return (success, data);
    }

    function runWriteCommand(
        uint256 topic
    ) onlyMaster public payable returns (bool, bytes memory) {
        if (!_commands[topic].isActive) {
            return (false, abi.encode("0"));
        }

        (bool success, bytes memory data) = _commands[topic].remoteTarget.call{value : msg.value, gas : _commands[topic].gas}(_commands[topic].remoteFunctionEncoding);

        emit CommandResponse(success, data);

        require(success, "011: Run write command failed");

        return (success, data);
    }

    function runReadCommand(
        uint256 topic
    ) onlyMaster public view returns (bool, bytes memory) {
        if (!_commands[topic].isActive) {
            return (false, abi.encode("0"));
        }

        (bool success, bytes memory data) = _commands[topic].remoteTarget.staticcall(_commands[topic].remoteFunctionEncoding);

        return (success, data);
    }

    function setSlave(address payable newSlave) public onlyMaster {
        require(newSlave != address(0));
        _slave = newSlave;
    }

    function setMaster(address payable newMaster) public onlyMaster {
        require(newMaster != address(0));
        _master = newMaster;
    }

    function setCommand(
        uint256 topic,
        address payable remoteTarget,
        bytes memory remoteFunctionEncoding,
        uint256 gas
    ) onlyMaster public {
        _commands[topic].remoteTarget = remoteTarget;
        _commands[topic].remoteFunctionEncoding = remoteFunctionEncoding;
        _commands[topic].gas = gas;
        _commands[topic].isActive = false;
    }
}