// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GrowPass} from "../src/GrowPass.sol";

contract GrowPassTest is Test {
    GrowPass public growPass;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        growPass = new GrowPass();
    }

    function testConstructor() public view {
        assertEq(growPass.name(), "GrowPass");
        assertEq(growPass.symbol(), "GPASS");
        assertEq(growPass.nextId(), 0);
    }

    function testMintValidLevel() public {
        vm.prank(owner);
        uint256 tokenId = growPass.mint(user, 1);
        
        assertEq(tokenId, 1);
        assertEq(growPass.nextId(), 1);
        assertEq(growPass.ownerOf(1), user);
        assertEq(growPass.tokenLevel(1), 1);
    }

    function testMintInvalidLowLevel() public {
        vm.expectRevert("Invalid level");
        vm.prank(owner);
        growPass.mint(user, 0);
    }

    function testMintInvalidHighLevel() public {
        vm.expectRevert("Invalid level");
        vm.prank(owner);
        growPass.mint(user, 6);
    }

    function testMintMultipleTokens() public {
        vm.startPrank(owner);
        
        uint256 tokenId1 = growPass.mint(user, 1);
        uint256 tokenId2 = growPass.mint(user, 3);
        uint256 tokenId3 = growPass.mint(user, 5);
        
        vm.stopPrank();
        
        assertEq(tokenId1, 1);
        assertEq(tokenId2, 2);
        assertEq(tokenId3, 3);
        
        assertEq(growPass.nextId(), 3);
        assertEq(growPass.tokenLevel(1), 1);
        assertEq(growPass.tokenLevel(2), 3);
        assertEq(growPass.tokenLevel(3), 5);
    }

    function testTokenURI() public {
        vm.prank(owner);
        uint256 tokenId = growPass.mint(user, 3);
        
        string memory uri = growPass.tokenURI(tokenId);
        // URI should start with data:application/json;base64,
        assertTrue(bytes(uri).length > 0);
        // 这里可以进一步验证返回的 JSON 内容
    }
}