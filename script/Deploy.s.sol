// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {GrowToken} from "../src/GrowToken.sol";
import {GrowPass} from "../src/GrowPass.sol";
import {TaskManager} from "../src/TaskManager.sol";

contract Deploy is Script {
    GrowToken public growToken;
    GrowPass public growPass;
    TaskManager public taskManager;

    function run() external {
        vm.startBroadcast();

        growPass = new GrowPass();
        taskManager = new TaskManager(address(growPass));
        growToken = new GrowToken(address(taskManager));
        taskManager.setGrowToken(address(growToken));

        console.log("GrowToken:", address(growToken));
        console.log("GrowPass:", address(growPass));
        console.log("TaskManager:", address(taskManager));

        vm.stopBroadcast();
    }
}