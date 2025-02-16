// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/IJToken.sol";
import "../src/LearningBadges.sol";

contract IJTokenTest is Test {
    IJToken token;
    address owner;
    address student;
    address cafeteria;

    function setUp() public {
        owner = address(uint160(uint256(keccak256("owner")))); // Eindeutige Owner-Adresse
        student = address(uint160(uint256(keccak256("student")))); // ""
        cafeteria = address(uint160(uint256(keccak256("cafeteria")))); // ""

        vm.startPrank(owner); // Owner simulieren
        LearningBadges badgeContract = new LearningBadges();
        token = new IJToken(owner, address(badgeContract)); // Contract deployen

        badgeContract.addApprovedMinter(address(token));
        vm.stopPrank();
    }

    // 1. Konstruktor-Test
    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 50000000 * 10 ** token.decimals());
    }

    // 2. Test für Belohnung
    function testRewardStudentEasy() public {
        vm.startPrank(owner);
        token.rewardStudent(student, 1, 1, IJToken.QuizLevel.Easy);
        assertEq(token.balanceOf(student), 50 * 10 ** token.decimals());
        vm.stopPrank();
    }

    // 3. Belohnung bereits beansprucht
    function testRewardAlreadyClaimed() public {
        vm.startPrank(owner);
        token.rewardStudent(student, 1, 1, IJToken.QuizLevel.Easy); // Erste Belohnung
        vm.expectRevert("Belohnung bereits beansprucht!"); // Erwartet einen Fehler
        token.rewardStudent(student, 1, 1, IJToken.QuizLevel.Easy); // Zweite Belohnung -> Fehlermeldung
        vm.stopPrank();
    }

    // 4. Belohnung überschreitet maxSupply
    function testRewardExceedsMaxSupply() public {
        vm.startPrank(owner);
        token.setRewardPerLevel(IJToken.QuizLevel.Hard, 100000001 * 10 ** token.decimals());
        vm.expectRevert("Maximaler Supply erreicht!");
        token.rewardStudent(student, 1, 1, IJToken.QuizLevel.Hard); // Überschreitet maxSupply
        vm.stopPrank();
    }

    // 5. Admin kann Belohnung ändern
    function testSetRewardPerLevel() public {
        vm.startPrank(owner);
        token.setRewardPerLevel(IJToken.QuizLevel.Medium, 150 * 10 ** token.decimals()); // auf 150 geändert
        assertEq(token.rewardPerLevel(IJToken.QuizLevel.Medium), 150 * 10 ** token.decimals());
        vm.stopPrank();
    }

    // 6. Nicht-Owner kann Belohnungen nicht ändern
    function testSetRewardPerLevelNotOwner() public {
        vm.startPrank(student);
        try token.setRewardPerLevel(IJToken.QuizLevel.Medium, 150 * 10 ** token.decimals()) {
            fail();
        } catch {
            // Revert wird gefangen
        }
        vm.stopPrank();
    }

    // 7. Zahlung in der Cafeteria
    function testPayCafeteria() public {
        vm.startPrank(owner);
        token.rewardStudent(student, 1, 1, IJToken.QuizLevel.Hard); // 200 Tokens an Student
        vm.stopPrank();
        vm.startPrank(student); // Student zahlt in Cafeteria
        token.payCafeteria(cafeteria, 100 * 10 ** token.decimals()); // 100 Tokens für Kaffee zahlen
        vm.stopPrank();
        assertEq(token.balanceOf(cafeteria), 100 * 10 ** token.decimals());
    }

    // 8. Student kann nicht mit 0 Tokens bezahlen
    function testPayCafeteriaInsufficientBalance() public {
        assertEq(token.balanceOf(student), 0, "Student sollte 0 Token haben!");
        vm.startPrank(student);

        try token.payCafeteria(cafeteria, 50 * 10 ** token.decimals()) {
            fail();
        } catch {
            // Revert wird gefangen
        }
        vm.stopPrank();
    }

    // 9. Lektion abschließen
    function testCompleteLesson() public {
        vm.startPrank(owner);
        token.completeLesson(student, 1, 1, IJToken.QuizLevel.Easy);
        assertTrue(token.isCompleted(student, 1, 1, true, IJToken.QuizLevel.Easy));
        vm.stopPrank();
    }

    // 10. Kurs abschließen
    function testCompleteCourse() public {
        vm.startPrank(owner);
        token.completeLesson(student, 1, 1, IJToken.QuizLevel.Easy);
        token.completeCourse(student, 1);
        assertTrue(token.isCompleted(student, 1, 0, false, IJToken.QuizLevel.Easy));
        vm.stopPrank();
    }

    // 11. Student kann eine Lektion nicht doppelt abschließen
    function testCompleteLessonTwice() public {
        vm.startPrank(owner);
        token.completeLesson(student, 1, 1, IJToken.QuizLevel.Easy);
        vm.expectRevert(abi.encodeWithSignature("LessonAlreadyCompleted()"));
        token.completeLesson(student, 1, 1, IJToken.QuizLevel.Easy);
        vm.stopPrank();
    }

    // 12. Student kann einen Kurs nicht doppelt abschließen
    function testCompleteCourseTwice() public {
        vm.startPrank(owner);
        token.completeCourse(student, 1);
        assertTrue(token.isCompleted(student, 1, 0, false, IJToken.QuizLevel.Easy));

        vm.expectRevert(abi.encodeWithSignature("CourseAlreadyCompleted()"));
        token.completeCourse(student, 1);
        vm.stopPrank();
    }

    // 13. Cafeteria kann Tokens an Uni zurückgeben
    function testReturnToContractOwner() public {
        uint256 initialBalance = token.balanceOf(owner);
        vm.startPrank(owner);
        token.addApprovedCaller(cafeteria);
        token.transfer(cafeteria, 100 * 10 ** token.decimals());
        vm.stopPrank();

        vm.startPrank(cafeteria);
        token.returnToContractOwner(100 * 10 ** token.decimals());
        vm.stopPrank();
        uint256 finalBalance = token.balanceOf(owner);

        assertEq(finalBalance, initialBalance, "Gleicher Kontostand wie vorher!");
    }

    // 14. Uni kann Tokens aus der Cafeteria burnen
    function testBurn() public {
        vm.startPrank(owner);
        token.burn(50 * 10 ** token.decimals());
        vm.stopPrank();
        assertEq(token.totalSupply(), 49999950 * 10 ** token.decimals());
    }

    // 15. Owner kann ApprovedCaller hinzufügen
    function testAddApprovedCaller() public {
        vm.startPrank(owner);
        token.addApprovedCaller(student);
        assertTrue(token.approvedCallers(student), "Student sollte Approved Caller sein!");
        vm.stopPrank();
    }

    // 16. Nicht-Owner kann keinen ApprovedCaller hinzufügen
    function testAddApprovedCallerNotOwner() public {
        vm.startPrank(student);
        try token.addApprovedCaller(student) {
            fail();
        } catch {
            // Revert wird gefangen
        }
        vm.stopPrank();
    }

    // 17. Nur ApprovedCaller kann rewardStudent() ausführen
    function testRewardStudentOnlyApprovedCaller() public {
        vm.startPrank(owner);
        token.addApprovedCaller(student);
        vm.stopPrank();

        vm.prank(student);
        token.rewardStudent(cafeteria, 1, 1, IJToken.QuizLevel.Easy);
        assertEq(token.balanceOf(cafeteria), 50 * 10 ** token.decimals());
    }

    // 18. Nicht-ApprovedCaller kann rewardStudent() nicht ausführen
    function testRewardStudentNotApprovedCaller() public {
        vm.startPrank(student);
        try token.rewardStudent(cafeteria, 1, 1, IJToken.QuizLevel.Easy) {
            fail();
        } catch {
            // Revert wird gefangen
        }
        vm.stopPrank();
    }

    // 19. Testen, ob Student NFT erhält
    function testStudentReceivesNFTForCourse() public {
        vm.startPrank(owner);
        token.completeCourse(student, 1);
        assertTrue(LearningBadges(token.badgeContract()).hasCourseBadge(student, 1));
        vm.stopPrank();
    }

    // 20. Nicht-Owner darf kein NFT vergeben
    function testNonOwnerCannotAwardNFT() public {
        vm.startPrank(student);
        try token.completeCourse(student, 1) {
            fail();
        } catch {
            // Revert wird gefangen
        }
        vm.stopPrank();
    }
}
