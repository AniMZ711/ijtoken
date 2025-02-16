require('dotenv').config({ path: 'privateKey.env' });
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { ethers } = require('ethers');

// Konfigurationen
const RPC_URL = "https://data-seed-prebsc-1-s1.binance.org:8545/"; // Binance Testnet
const PRIVATE_KEY = process.env.PRIVATE_KEY; // Private Key 
const CONTRACT_ADDRESS = "0x5D7f6e2Da683Ec0da8526b7a28F0BF5a676Ed5B8"; // Adresse des IJToken-Contracts

const ABI = [
    "function rewardStudent(address student, uint256 courseId, uint256 lessonId, uint8 level) external",
    "function completeCourse(address student, uint256 courseId) external",
    "function completeLesson(address student, uint256 courseId, uint256 lessonId, uint8 level) external", 
    "function isCompleted(address student, uint256 courseId, uint256 lessonId, bool isLesson, uint8 level) public view returns (bool)"
];

// Blockchain-Verbindung
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

// Überprüfen, ob die Server-Adresse als "ApprovedCaller" registriert ist
async function checkIfApprovedCaller() {
    const approvedCallersAbi = ["function approvedCallers(address) public view returns (bool)"];
    const contractWithRead = new ethers.Contract(CONTRACT_ADDRESS, approvedCallersAbi, provider);

    const isApproved = await contractWithRead.approvedCallers(wallet.address);
    if (!isApproved) {
        console.error(`Fehler: Die Server-Adresse (${wallet.address}) ist KEIN ApprovedCaller!`);
        process.exit(1); 
    } else {
        console.log(`Die Server-Adresse (${wallet.address}) ist ein ApprovedCaller.`);
    }
}

// Express-Server erstellen
const app = express();
app.use(cors());
app.use(bodyParser.json());

console.log(wallet.address);

// Token automatisch vergeben
app.post('/reward', async (req, res) => {
    const { student, courseId, lessonId, level } = req.body;
    if (!student || courseId === undefined || lessonId === undefined || level === undefined) {
        return res.status(400).send("Fehlende Parameter: student, courseId, lessonId oder level.");
    }

    try {
        console.log(`Belohnung für Kurs ${courseId} - Lektion ${lessonId} - Level ${level}...`);

        // Token vergeben
        const txReward = await contract.rewardStudent(student, courseId, lessonId, level);
        await txReward.wait();
        console.log(`Tokens gesendet! TX-Hash: ${txReward.hash}`);

        res.json({ success: true, txRewardHash: txReward.hash });
    } catch (error) {
        console.error("Fehler bei der Belohnung:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Lektion abschließen
app.post('/completeLesson', async (req, res) => {
    const { student, courseId, lessonId, level } = req.body;
    if (!student || courseId === undefined || lessonId === undefined || level === undefined) {
        return res.status(400).send("Fehlende Parameter: student, courseId, lessonId oder level.");
    }

    try {
        console.log(`Lektion ${lessonId} in Kurs ${courseId} abschließen...`);
        const tx = await contract.completeLesson(student, courseId, lessonId, level);
        await tx.wait();
        console.log(`Lektion abgeschlossen! TX-Hash: ${tx.hash}`);
        res.json({ success: true, txHash: tx.hash });
    } catch (error) {
        console.error("Fehler bei completeLesson:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Kurs abschließen
app.post('/completeCourse', async (req, res) => {
    const { student, courseId } = req.body;
    if (!student || courseId === undefined) {
        return res.status(400).send("Fehlende Parameter: student oder courseId.");
    }

    try {
        console.log(`Kurs ${courseId} für Student ${student} abschließen...`);
        const tx = await contract.completeCourse(student, courseId);
        await tx.wait();
        console.log(`Kurs abgeschlossen! TX-Hash: ${tx.hash}`);
        res.json({ success: true, txHash: tx.hash });
    } catch (error) {
        console.error("Fehler bei completeCourse:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Status von Lektion oder Kurs abrufen
app.post('/isCompleted', async (req, res) => {
    const { student, courseId, lessonId, isLesson, level } = req.body;
    if (!student || courseId === undefined || lessonId === undefined || isLesson === undefined || level === undefined) {
        return res.status(400).send("Fehlende Parameter: student, courseId, lessonId, isLesson oder level.");
    }

    try {
        const completed = await contract.isCompleted(student, courseId, lessonId, isLesson, level);
        res.json({ success: true, completed: completed });
    } catch (error) {
        console.error("Fehler bei isCompleted:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Server starten
const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server läuft auf http://localhost:${PORT}`);
});
