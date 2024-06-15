import { HardhatRuntimeEnvironment } from "hardhat/types";
import {DeployFuction} from 'hardhat-deploy/types';
import { ethers } from "hardhat";


const DeployInnoHunt : DeployFuction = async(hre: HardhatRuntimeEnvironment)=>{
    const {getNamedAccounts, deployments, network} = hre;
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();
    console.log("Deploying InnoHunt ...");
    const innohuntToken = await deploy("InnoHunt", {
        from: deployer,
        args: [],
        log: true
    });
    console.log("Deployed InnoHunt to address " + innohuntToken.address);
}



export default DeployInnoHunt;