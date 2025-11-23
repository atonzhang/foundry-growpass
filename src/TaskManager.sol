// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {GrowToken} from "./GrowToken.sol";
import {GrowPass} from "./GrowPass.sol";
import {console} from "forge-std/console.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TaskManager is IERC721Receiver {
    GrowToken private growToken;
    GrowPass private immutable growPass;

    struct Task {
        string name;
        uint256 reward;   // GROW token amount
        uint256 levelReq; // Required NFT level to unlock
    }

    Task[] public tasks;
    mapping(address => mapping(uint256 => bool)) public completed;

    event TaskCompleted(address indexed user, uint256 taskId, uint256 reward);

    constructor(address _growPass) {
        growPass = GrowPass(_growPass);

        // Sample tasks
        _addTask("Watch Solidity Intro", 100 ether, 1);
        _addTask("Deploy First Contract", 300 ether, 2);
        _addTask("Write Foundry Test", 500 ether, 3);
        _addTask("Submit PR to Open Source", 1000 ether, 5);
    }

    function _addTask(string memory name, uint256 reward, uint256 level) internal {
        tasks.push(Task(name, reward, level));
    }

    /// @dev Complete a task (called by frontend)
    function completeTask(uint256 taskId) external {
        require(taskId < tasks.length, "Invalid task");
        require(!completed[msg.sender][taskId], "Already done");

        Task memory task = tasks[taskId];
        completed[msg.sender][taskId] = true;

        // Mint tokens
        growToken.mint(msg.sender, task.reward);

        // Check if NFT can be minted
        if (_canMintLevel(msg.sender, task.levelReq)) {
            growPass.mint(msg.sender, task.levelReq);
        }

        emit TaskCompleted(msg.sender, taskId, task.reward);
    }

    function _canMintLevel(address user, uint256 level) internal view returns (bool) {
        // Simple rule: complete N tasks to mint level
        uint256 count = 0;
        for (uint256 i = 0; i < tasks.length; i++) {
            if (completed[user][i]) count++;
        }
        return count >= level;
    }

    function getGrowToken() external view returns (address) {
        return address(growToken);
    }

    function setGrowToken(address _growToken) external {
        require(address(growToken) == address(0), "GrowToken already set");
        growToken = GrowToken(_growToken);
    }

    function getGrowPass() external view returns (GrowPass) {
        return growPass;
    }

    // Implement ERC721Receiver interface
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        // Check if caller is GrowPass contract
        require(msg.sender == address(growPass), "Unauthorized NFT transfer");
        return IERC721Receiver.onERC721Received.selector;
    }

    // View functions
    function taskCount() external view returns (uint256) { return tasks.length; }
}