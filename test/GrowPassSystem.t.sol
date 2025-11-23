// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Deploy} from "../script/Deploy.s.sol";
import {GrowToken} from "../src/GrowToken.sol";
import {GrowPass} from "../src/GrowPass.sol";
import {TaskManager} from "../src/TaskManager.sol";

contract GrowPassSystemTest is Test {
    Deploy public deployer;
    GrowToken public growToken;
    GrowPass public growPass;
    TaskManager public taskManager;
    
    address public user = address(1);

    function setUp() public {
        deployer = new Deploy();
        deployer.run();
        
        // Get deployed contract instances
        growToken = GrowToken(deployer.growToken());
        growPass = GrowPass(deployer.growPass());
        taskManager = TaskManager(payable(address(deployer.taskManager())));
    }

    modifier initVm() {
        deal(address(growToken), user, 1 ether);
        vm.startPrank(user);
        _;
        vm.stopPrank();
    }

    function testFullSystemDeployment() public view {
        // Check that all contracts are deployed correctly
        assertTrue(address(growToken) != address(0));
        assertTrue(address(growPass) != address(0));
        assertTrue(address(taskManager) != address(0));
        
        // Check that relationships between contracts are set correctly
        assertEq(growToken.getTaskManager(), address(taskManager));
        assertEq(address(taskManager.getGrowToken()), address(growToken));
        assertEq(address(taskManager.getGrowPass()), address(growPass));
    }

    function testEndToEndFlow() public initVm {
        taskManager.completeTask(0); // "Watch Solidity Intro"
        
        // Check if user received token rewards
        assertGt(growToken.balanceOf(user), 0);
        
        // Check if corresponding NFT was minted
        assertGt(growPass.balanceOf(user), 0);
        
        // Check NFT level
        uint256 tokenId = 1; // 第一个铸造的 NFT
        uint256 level = growPass.getTokenLevel(tokenId);
        console.log("NFT Level:", level);
        assertTrue(level >= 1 && level <= 5);
    }

    function testMultipleTasksCompletion() public {
        vm.startPrank(user);
        
        // 完成多个任务
        taskManager.completeTask(0); // "Watch Solidity Intro"
        taskManager.completeTask(1); // "Deploy First Contract"
        
        vm.stopPrank();
        
        // 检查用户余额
        assertGt(growToken.balanceOf(user), 0);
    }
}