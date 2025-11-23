// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/console.sol";

/// @title GROW – Grow Token
contract GrowToken is ERC20 {
    address private immutable taskManager;

    constructor(address _taskManager) ERC20("Grow Token", "GROW") {
        taskManager = _taskManager;
    }

    function mint(address to, uint256 amount) external {
        console.log("msg.sender: ", msg.sender);
        console.log("taskManager: ", taskManager);

        // Only taskManager can call the mint method
        require(msg.sender == taskManager, "Unauthorized");
        _mint(to, amount);
    }

    function getTaskManager() external view returns (address) {
        return taskManager;
    }
}