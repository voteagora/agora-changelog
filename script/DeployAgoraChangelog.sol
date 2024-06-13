// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AgoraChangelog} from "../src/AgoraChangelog.sol";

contract DeployAgoraChangelog is Script {
    function run() external {
        // Address of the deployer and the initial manager
        address manager = vm.envAddress("MANAGER_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");

        // Private key for deploying
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions using the private key
        vm.startBroadcast(privateKey);

        // Deploy the contract
        AgoraChangelog changelog = new AgoraChangelog();
        changelog.initialize(manager, owner);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Output the deployed contract address
        console.log("AgoraChangelog deployed at:", address(changelog));
    }
}
