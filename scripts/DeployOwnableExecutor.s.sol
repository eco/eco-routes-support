// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GnosisSafeProxyFactory} from "@safe-global/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import {GnosisSafe} from "@safe-global/safe-contracts/contracts/GnosisSafe.sol";
import {OwnableExecutor} from "@rhinestone/core-modules/src/OwnableExecutor/OwnableExecutor.sol";

contract DeployOwnableExecutor is Script {
    address constant SAFE_PROXY_FACTORY = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;
    address deployer;
    bytes32 constant SALT = keccak256("OwnableExecutorDeployment"); // Unique salt for CREATE2

    function run() external {
        vm.startBroadcast();
        deployer = msg.sender;

        // Check if `OwnableExecutor` singleton is deployed
        address ownableExecutorSingleton = getOrDeploySingleton();

        // Compute deterministic CREATE2 address
        address predictedAddress = computeCreate2Address(ownableExecutorSingleton);

        // Check if the proxy is already deployed
        if (isContract(predictedAddress)) {
            console.log("OwnableExecutor proxy already deployed at:", predictedAddress);
        } else {
            // Deploy a new OwnableExecutor instance using the SafeProxyFactory
            GnosisSafeProxyFactory factory = GnosisSafeProxyFactory(SAFE_PROXY_FACTORY);
            GnosisSafeProxy newExecutor = factory.createProxy(ownableExecutorSingleton, "");

            console.log("Deployed OwnableExecutor proxy at:", address(newExecutor));
        }

        vm.stopBroadcast();
    }

    /// @notice Checks if the OwnableExecutor singleton is deployed, deploys if necessary
    function getOrDeploySingleton() internal returns (address) {
        address expectedAddress = computeCreate2Address(type(OwnableExecutor).creationCode);
        
        // If already deployed, return its address
        if (isContract(expectedAddress)) {
            console.log("OwnableExecutor singleton already deployed at:", expectedAddress);
            return expectedAddress;
        }

        // Deploy the singleton using CREATE2
        address singleton;
        assembly {
            let codeSize := mload(type(OwnableExecutor).creationCode)
            singleton := create2(0, add(type(OwnableExecutor).creationCode, 0x20), codeSize, SALT)
        }

        console.log("Deployed OwnableExecutor singleton at:", singleton);
        return singleton;
    }

    /// @notice Computes the CREATE2 deterministic address
    function computeCreate2Address(bytes memory bytecode) public view returns (address) {
        return address(uint160(uint256(keccak256(
            abi.encodePacked(
                bytes1(0xFF),
                deployer,
                SALT,
                keccak256(bytecode)
            )
        ))));
    }

    /// @notice Checks if an address has contract code
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}