// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {GrowToken} from "../src/GrowToken.sol";
import {GrowPass} from "../src/GrowPass.sol";
import {TaskManager} from "../src/TaskManager.sol";

contract TaskManagerTest is Test {
    GrowToken public growToken;
    GrowPass public growPass;
    TaskManager public taskManager;
    
    address public user = address(1);
    address public otherUser = address(2);

    // 声明从 TaskManager 继承的事件
    event TaskCompleted(address indexed user, uint256 taskId, uint256 reward);

    function setUp() public {
        growPass = new GrowPass();
        taskManager = new TaskManager(address(growPass));
        growToken = new GrowToken(address(taskManager)); 
        taskManager.setGrowToken(address(growToken));
    }

    modifier initVm() {
        vm.startPrank(user);
        _;
        vm.stopPrank();
    }

    function testConstructor() public view {
        assertEq(address(taskManager.getGrowToken()), address(growToken));
        assertEq(address(taskManager.getGrowPass()), address(growPass));
        assertTrue(taskManager.taskCount() > 0);
    }

    function testCompleteTask() public initVm {
        uint256 taskId = 0;
        // 从合约中获取实际的奖励值
        (, uint256 reward,) = taskManager.tasks(taskId);
        
        // 用户完成任务
        // vm.prank(address(taskManager));
        taskManager.completeTask(taskId);
        
        // 检查用户是否获得了奖励
        assertEq(growToken.balanceOf(user), reward);
        
        // 检查任务是否标记为已完成
        assertTrue(taskManager.completed(user, taskId));
    }

    function testCompleteInvalidTask() public {
        uint256 invalidTaskId = taskManager.taskCount();
        
        vm.expectRevert("Invalid task");
        vm.prank(user);
        taskManager.completeTask(invalidTaskId);
    }

    function testCompleteTaskTwice() public {
        uint256 taskId = 0;
        
        // 第一次完成任务
        vm.prank(user);
        taskManager.completeTask(taskId);
        
        // 第二次尝试完成同一任务应该失败
        vm.expectRevert("Already done");
        vm.prank(user);
        taskManager.completeTask(taskId);
    }

    function testTaskCompletionEmitsEvent() public {
        uint256 taskId = 0;
        
        // We need to get the actual task reward value from the TaskManager contract
        // Because using hardcoded values directly in tests may not match
        (, uint256 reward,) = taskManager.tasks(taskId);
        
        vm.expectEmit(true, false, false, true);
        emit TaskCompleted(user, taskId, reward);
        
        vm.prank(user);
        taskManager.completeTask(taskId);
    }

    function testNFTMinting() public {
        // Complete enough tasks to unlock NFT
        vm.startPrank(user);
        
        // 完成第一个任务 (level 1)
        taskManager.completeTask(0); // "Watch Solidity Intro", 100 ether, level 1
        
        // 检查是否铸造了 NFT
        assertEq(growPass.balanceOf(user), 1);
        
        vm.stopPrank();
    }
}