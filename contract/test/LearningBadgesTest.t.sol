// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/LearningBadges.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearningBadgesTest is Test {
    LearningBadges badgeContract;
    address owner;
    address student;
    address approvedMinter;
    address unauthorizedUser;

    function setUp() public {
        owner = address(uint160(uint256(keccak256("owner"))));
        student = address(uint160(uint256(keccak256("student"))));
        approvedMinter = address(uint160(uint256(keccak256("approvedMinter"))));
        unauthorizedUser = address(uint160(uint256(keccak256("unauthorizedUser"))));

        vm.startPrank(owner);
        badgeContract = new LearningBadges();
        vm.stopPrank();
    }

    // 1. Nur Owner kann Approved Minter hinzufügen
    function testOwnerCanAddApprovedMinter() public {
        vm.startPrank(owner);
        badgeContract.addApprovedMinter(approvedMinter);
        vm.stopPrank();

        vm.prank(approvedMinter);
        badgeContract.awardCourseBadge(student, 1, "https://gateway.pinata.cloud/ipfs/bafybeig6wn2h6nbx3pqdqnw43rtwcdvj5dfklhuma7geljbvfmhd26xkme");
        assertTrue(badgeContract.hasCourseBadge(student, 1), "NFT wurde nicht vergeben!");
    }

    // 2. Nicht-Owner kann keinen Approved Minter hinzufügen
    function testUnauthorizedUserCannotAddApprovedMinter() public {
        vm.prank(unauthorizedUser);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, unauthorizedUser));
        badgeContract.addApprovedMinter(unauthorizedUser);
    }

    // 3. Nur Approved Minter oder Owner kann NFT vergeben
    function testOnlyApprovedMinterOrOwnerCanAwardNFT() public {
        vm.prank(unauthorizedUser);
        vm.expectRevert("Unauthorized Caller");
        badgeContract.awardCourseBadge(student, 1, "https://gateway.pinata.cloud/ipfs/bafybeig6wn2h6nbx3pqdqnw43rtwcdvj5dfklhuma7geljbvfmhd26xkme");
    }

    // 4. NFT existiert nach Vergabe
    function testNFTExistsAfterAward() public {
        vm.startPrank(owner);
        badgeContract.awardCourseBadge(student, 1, "https://gateway.pinata.cloud/ipfs/bafybeig6wn2h6nbx3pqdqnw43rtwcdvj5dfklhuma7geljbvfmhd26xkme");
        vm.stopPrank();

        assertEq(badgeContract.ownerOf(1), student, "NFT wurde nicht korrekt ausgegeben!");
    }

    // 5. Student kann kein zweites NFT für denselben Kurs erhalten
    function testStudentCannotReceiveDuplicateNFT() public {
        vm.startPrank(owner);
        badgeContract.awardCourseBadge(student, 1, "https://gateway.pinata.cloud/ipfs/bafybeig6wn2h6nbx3pqdqnw43rtwcdvj5dfklhuma7geljbvfmhd26xkme");
        vm.expectRevert("Badge fuer diesen Kurs bereits erhalten!");
        badgeContract.awardCourseBadge(student, 1, "https://gateway.pinata.cloud/ipfs/bafybeig6wn2h6nbx3pqdqnw43rtwcdvj5dfklhuma7geljbvfmhd26xkme");
        vm.stopPrank();
    }
}
