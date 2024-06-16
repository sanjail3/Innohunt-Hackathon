"use client"
import React, { createContext, useState, useEffect } from 'react';
import {ethers} from "ethers";
import {abi} from "../utils/ContractAbi";

const Web3Context = createContext();

export const Web3Provider = ({ children }) => {
    const [walletConnected, setWalletConnected] = useState(false);
    const [loggedUser, setLoggedUser] = useState('');
    const [contractInstance, setContractInstance] = useState(null);

    const contractAddress = '0xBbb5Cac770233Bd0746c06C3C2f66fa2696dEF5F'; 

    const initWeb3 = async () => {
        if (window.ethereum && walletConnected) {
        const provider = new ethers.BrowserProvider(window.ethereum);
            try {
                const signer = await provider.getSigner();
                const contract = new ethers.Contract(contractAddress, abi, signer);
                setContractInstance(contract);
                console.log("Contract Loaded..!");
            } catch (error) {
                console.error('Error connecting to wallet:', error);
            }
        } else {
            console.error('Web3 provider not detected');
        }
    };

    useEffect(() => {
        initWeb3();
    },[walletConnected]);

    return (
        <Web3Context.Provider value={{ contractInstance, walletConnected, loggedUser, setLoggedUser, setWalletConnected }}>
            {children}
        </Web3Context.Provider>
    );
};


export default Web3Context;