// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // ERC-20-Funktionen
import "@openzeppelin/contracts/access/Ownable.sol"; // Owner-Funktionen
import "forge-std/console.sol"; // für Debugging
import "./LearningBadges.sol"; // NFT-Contract importieren

error InsufficientBalance();
error LessonAlreadyCompleted();
error CourseAlreadyCompleted();

contract IJToken is ERC20, Ownable {
    uint256 public maxSupply = 100000000 * 10 ** decimals(); // Max.: 100Mio Token

    // Quiz-Schwierigkeitsstufen 
    enum QuizLevel { Easy, Medium, Hard }

    mapping(QuizLevel => uint256) public rewardPerLevel; // Belohnungen pro Level
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(QuizLevel => bool)))) public hasClaimedReward; // Belohnungsstatus pro Lektion & Student
    mapping(address => mapping(uint256 => bool)) public completedCourses; // Abgeschlossene Kurse
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public completedLessons; // Abgeschlossene Lektionen
    mapping(address => bool) public approvedCallers; // QuizCaller autorisieren
    mapping(uint256 => string) public courseURIs; // Kurs-URIs mappen

    // NFT-Contract für Kurs-Badges
    LearningBadges public badgeContract; 

    // Events für Logging
    event RewardClaimed(address indexed student, uint256 courseId, uint256 lessonId, QuizLevel level, uint256 amount);
    event CafeteriaPayment(address indexed payer, address cafeteria, uint256 amount);
    event LessonCompleted(address indexed student, uint256 courseId, uint256 lessonId);
    event CourseCompleted(address indexed student, uint256 courseId);
    event CourseURIUpdated(uint256 indexed courseId, string uri);
    event BurnedTokens(address indexed cafeteria, uint256 amount);
    event ApprovedCallerAdded(address indexed caller);
    event ApprovedCallerRemoved(address indexed caller);

    // Modifier für autorisierte externe Contracts
    modifier onlyApprovedCaller() {
        require(approvedCallers[msg.sender] || msg.sender == owner(), "UnauthorizedCaller");
        _;
    }

    // Konstruktor
    constructor(address _owner, address _badgeContract) ERC20("IJToken", "IJT") Ownable(_owner) {
        badgeContract = LearningBadges(_badgeContract); 

        // Belohnungen für die Schwierigkeitsstufen definieren
        rewardPerLevel[QuizLevel.Easy] = 50 * 10 ** decimals(); // 50 Tokens
        rewardPerLevel[QuizLevel.Medium] = 100 * 10 ** decimals(); // 100 Tokens
        rewardPerLevel[QuizLevel.Hard] = 200 * 10 ** decimals(); // 200 Tokens

        // 50 Mio Token für den Ersteller des Contracts minten
        _mint(_owner, 50000000 * 10 ** decimals());
    }

    // Admin kann die Belohnungen für ein Quiz-Level anpassen
    function setRewardPerLevel(QuizLevel level, uint256 reward) public onlyOwner {
        rewardPerLevel[level] = reward;
    }

    // Admin kann ApprovedCaller hinzufügen 
    function addApprovedCaller(address caller) external onlyOwner {
        approvedCallers[caller] = true;
        emit ApprovedCallerAdded(caller);
    }

    // Admin kann ApprovedCaller entfernen
    function removeApprovedCaller(address caller) external onlyOwner {
        approvedCallers[caller] = false;
        emit ApprovedCallerRemoved(caller);
    }

    // Belohnung für bestandene Quizzes 
    function rewardStudent(address student, uint256 courseId, uint256 lessonId, QuizLevel level) public onlyApprovedCaller {
        require(bytes(getCourseURI(courseId)).length > 0, "Ungueltige courseId!");
        require(!hasClaimedReward[student][courseId][lessonId][level], "Belohnung bereits beansprucht!");

        uint256 rewardAmount = rewardPerLevel[level];
        require(totalSupply() + rewardAmount <= maxSupply, "Maximaler Supply erreicht!");

        _mint(student, rewardAmount); // Mintet die Belohnungen basierend auf dem Quiz-Level
        hasClaimedReward[student][courseId][lessonId][level] = true;
        emit RewardClaimed(student, courseId, lessonId, level, rewardAmount); // Logging
    }

    // Token-Bezahl-Funktion
    function payCafeteria(address cafeteria, uint256 amount) public {
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();
        _transfer(msg.sender, cafeteria, amount);
        emit CafeteriaPayment(msg.sender, cafeteria, amount);
    }

    // Lektion abschließen und "rewardStudent" aufrufen
    function completeLesson(address student, uint256 courseId, uint256 lessonId, QuizLevel level) public onlyOwner {
        require(bytes(getCourseURI(courseId)).length > 0, "Ungueltige courseId!");
        if (completedLessons[student][courseId][lessonId]) revert LessonAlreadyCompleted();
        completedLessons[student][courseId][lessonId] = true;

        rewardStudent(student, courseId, lessonId, level);
        emit LessonCompleted(student, courseId, lessonId);
    }

    // Kurs abschließen
    function completeCourse(address student, uint256 courseId) public onlyOwner {
        require(bytes(getCourseURI(courseId)).length > 0, "Ungueltige courseId!");
        if (completedCourses[student][courseId]) revert CourseAlreadyCompleted();
        completedCourses[student][courseId] = true;

        // NFT-Vergabe
        string memory uri = getCourseURI(courseId);
        badgeContract.awardCourseBadge(student, courseId, uri);

        emit CourseCompleted(student, courseId);
    }

    // Status von Kurs oder Lektion prüfen
    function isCompleted(address student, uint256 courseId, uint256 lessonId, bool isLesson, QuizLevel level) public view returns (bool) {
        if (isLesson) {
            return completedLessons[student][courseId][lessonId]; 
        } else if (lessonId > 0) {
            return hasClaimedReward[student][courseId][lessonId][level];
        } else {
            return completedCourses[student][courseId]; 
        }
    }

    // Badges für Kurse
    function getCourseURI(uint256 courseId) public view returns (string memory) {
        if (bytes(courseURIs[courseId]).length > 0) {
            return courseURIs[courseId];
        }
        if (courseId == 1) {
            return "https://gateway.pinata.cloud/ipfs/bafkreiahjhisptstzyl2763n7lznsdzp45qfnh2pgvgwzs3hkgbwju66l4"; // Programmieren 1
        } else if (courseId == 2) {
            return "https://gateway.pinata.cloud/ipfs/bafkreiaq5jqhi5r5pcvuinhsxf46teuy7zp5j6s2k7kx763vuca47flrg4"; // Softwareentwicklung
        } else if (courseId == 3) {
            return "https://gateway.pinata.cloud/ipfs/bafkreid7tp4ejy25y35eqk2zl7dktxevvrhcxbcufrfmnyd3w6gpm35iay"; // Datenbanken
        } else {
            return "https://gateway.pinata.cloud/ipfs/bafkreiaq5x64hcozyvvdw7daarowd35ekgc3kr4kbnbibk5lbwbh7idm6q"; // Default-Badge
        }
    }

    // Admin kann Kurs-URI setzen
    function setCourseURI(uint256 courseId, string memory uri) public onlyOwner {
        courseURIs[courseId] = uri;
        emit CourseURIUpdated(courseId, uri);
    }

    // Tokens werden zurück zum Owner geschickt (nur AC)
    function returnToContractOwner(uint256 amount) public onlyApprovedCaller {
        require(balanceOf(msg.sender) >= amount, "Nicht genug Tokens!");
        _transfer(msg.sender, owner(), amount); 
    }

    // Tokens werden geburnt
    function burn(uint256 amount) public onlyOwner {
        require(balanceOf(owner()) >= amount, "Nicht genug Tokens!");
        _burn(owner(), amount);
        emit BurnedTokens(owner(), amount);
    }
}
