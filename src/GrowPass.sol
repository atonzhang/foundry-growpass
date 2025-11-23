// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract GrowPass is ERC721 {
    uint256 public nextId;
    mapping(uint256 => uint256) public tokenLevel; // 1-5

    constructor() ERC721("GrowPass", "GPASS") {}

    /// @dev Mint NFT by consuming GROW tokens
    function mint(address to, uint256 level) external returns (uint256) {
        require(level >= 1 && level <= 5, "Invalid level");
        uint256 id = ++nextId;
        _safeMint(to, id);
        tokenLevel[id] = level;
        return id;
    }

    /// @dev 动态 SVG 元数据（链上生成）
    function tokenURI(uint256 id) public view override returns (string memory) {
        string memory name = string(abi.encodePacked("GrowPass #", _toString(id)));
        string memory svg = _generateSVG(id, tokenLevel[id]);

        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name":"', name, '",',
            '"description":"Proof of learning growth",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ))));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _generateSVG(uint256 id, uint256 level) internal pure returns (string memory) {
        string[5] memory colors = ["#10B981", "#3B82F6", "#8B5CF6", "#F59E0B", "#EF4444"];
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<rect width="350" height="350" fill="#1a1a1a"/>',
            '<circle cx="175" cy="175" r="100" fill="', colors[level-1], '"/>',
            '<text x="175" y="180" font-size="48" fill="white" text-anchor="middle">',
            _toString(level), '</text>',
            '<text x="175" y="230" font-size="24" fill="#ccc" text-anchor="middle">Pass #', _toString(id), '</text>',
            '</svg>'
        ));
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) { digits--; buffer[digits] = bytes1(uint8(48 + value % 10)); value /= 10; }
        return string(buffer);
    }
}