import { defineStore } from "pinia";
import { ref } from "vue";
import Web3 from "web3";
import tokenAbi from "../abi/token.json";

export const useWalletStore = defineStore("walletStore", () => {
  const CONTRACT_ADDRESS = "0x5D7f6e2Da683Ec0da8526b7a28F0BF5a676Ed5B8";
  const web3 = ref<Web3 | null>(null);
  const account = ref<string | null>(null);
  const contract = ref<any | null>(null);
  const balance = ref<string | null>(null);

  const connectWallet = async () => {
    if (window.ethereum) {
      web3.value = new Web3(window.ethereum);
      await window.ethereum.request({ method: "eth_requestAccounts" });

      const accounts = await web3.value.eth.getAccounts();
      account.value = accounts[0];
      contract.value = new web3.value.eth.Contract(tokenAbi, CONTRACT_ADDRESS);
      getBalance();
      console.log("Wallet verbunden:", account.value);
    } else {
      console.error("Kein Web3-Provider gefunden!");
    }
  };

  const disconnectWallet = () => {
    account.value = null;
    contract.value = null;
    balance.value = null;
  };

  const getBalance = async () => {
    if (!contract.value || !account.value) await connectWallet();
    if (!contract.value || !account.value) return;

    try {
      const balanceRaw = await contract.value.methods
        .balanceOf(account.value)
        .call();
      balance.value = web3.value!.utils.fromWei(balanceRaw, "ether");
    } catch (error) {
      console.error("Fehler beim Abrufen des Kontostands:", error);
    }

    console.log(`Balance: ${balance.value} IJT`);
  };

  return {
    balance,
    account,
    getBalance,
    connectWallet,
    disconnectWallet,
  };
});
