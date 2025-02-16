// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract LearningBadges is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId = 1;

    // Mapping
    mapping(address => mapping(uint256 => bool)) public hasCourseBadge; // Badge pro Kurs
    mapping(address => bool) public approvedMinters;

    // Events
    event BadgeAwarded(address indexed student, uint256 courseId, uint256 tokenId);

    constructor() ERC721("LearningBadges", "LBD") Ownable(msg.sender) {}

    // Nur IJToken-Contract oder Owner (Uni) kann Badges vergeben
    function awardCourseBadge(address student, uint256 courseId, string memory uri) external {
        require(approvedMinters[msg.sender] || msg.sender == owner(), "Unauthorized Caller");
        require(!hasCourseBadge[student][courseId], "Badge fuer diesen Kurs bereits erhalten!");

        uint256 tokenId = _nextTokenId;
        _safeMint(student, tokenId);
        _setTokenURI(tokenId, uri);

        hasCourseBadge[student][courseId] = true;
        _nextTokenId++;
        
        emit BadgeAwarded(student, courseId, tokenId);
    }

    function addApprovedMinter(address minter) external onlyOwner {
        approvedMinters[minter] = true;
    }

    function removeApprovedMinter(address minter) external onlyOwner {
        approvedMinters[minter] = false;
    }
}
