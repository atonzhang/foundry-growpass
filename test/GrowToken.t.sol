// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GrowToken} from "../src/GrowToken.sol";
import {TaskManager} from "../src/TaskManager.sol";

contract GrowTokenTest is Test {
    GrowToken public growToken;
    TaskManager public taskManager;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        taskManager = new TaskManager(address(0));
        growToken = new GrowToken(address(taskManager));
        taskManager.setGrowToken(address(growToken));
    }

    function testConstructor() public view {
        assertEq(growToken.name(), "Grow Token");
        assertEq(growToken.symbol(), "GROW");
        assertEq(growToken.getTaskManager(), address(taskManager));
    }

    function testMintByTaskManager() public {
        uint256 amount = 100 ether;
        
        // TaskManager should be able to mint tokens
        vm.prank(address(taskManager));
        growToken.mint(user, amount);
        
        assertEq(growToken.balanceOf(user), amount);
    }

    function testMintByNonTaskManager() public {
        uint256 amount = 100 ether;
        
        // Non-TaskManager addresses should not be able to mint tokens
        vm.expectRevert("Unauthorized");
        vm.prank(user);
        growToken.mint(user, amount);
    }

    function testMintZeroAmount() public {
        // TaskManager can mint 0 amount tokens
        vm.prank(address(taskManager));
        growToken.mint(user, 0);
        
        assertEq(growToken.balanceOf(user), 0);
    }
}