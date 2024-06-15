import { expect } from "chai";
import { ethers } from "hardhat";
const { Abi } = require('../token.js');

describe("InnoHunt", function () {
  let innoHunt: any;
  let deployer: any;
  let user: any;
  let projectId = 0;
  let totalshares = 1000;

  before(async function () {
    [deployer, user] = await ethers.getSigners();
    const InnoHunt = await ethers.getContractFactory("InnoHunt");
    innoHunt = await InnoHunt.deploy();
  });

  it("should create a project", async function () {
    const name = "Test Project";
    const symbol = "TST";
    const minProposalThreshold = 1;
    const minVoteThreshold = 1;
    const shareprice = 1;
    

    await innoHunt.connect(deployer).createProject(
      name,
      symbol,
      minProposalThreshold,
      minVoteThreshold,
      shareprice,
      totalshares
    );

    const project = await innoHunt.projects(projectId);
    expect(project.name).to.equal(name);
    expect(project.totalShares).to.equal(totalshares);
    expect(project.remainingShares).to.equal(totalshares);
    expect(project.shareprice).to.equal(shareprice);
  });

  it("should allow user to buy shares", async function () {
    const userBalance = await ethers.provider.getBalance(user);
    console.log("Buying Shares!!!!!!");
    console.log("User Balance before buying shares " + parseInt(`${userBalance}`)/1e18);
    const amount = 10;
    const project = await innoHunt.projects(projectId);
    const cost = parseInt(project.shareprice) * amount;

    await innoHunt.connect(user).buyShares(projectId, amount, {
      value: ethers.parseEther(`${cost}`)
    });
    const projectTokenContractAddress = await innoHunt.projectTokens(projectId);
    let innoToken = new ethers.Contract(projectTokenContractAddress, Abi, deployer);
    let remainingShares = await innoToken.balanceOf(innoHunt);
    expect(parseInt(remainingShares)).to.equal(totalshares-amount);

    const userBalance1 = await ethers.provider.getBalance(user);
    console.log("User Balance after buying shrares " + parseInt(`${userBalance1}`)/1e18);

    const contractBalance = await ethers.provider.getBalance(innoHunt);
    console.log("Contract Balance : " + parseInt(`${contractBalance}`)/1e18);
  });



  it("should allow user to sell shares", async function () {
    const amount = 5;
    const project = await innoHunt.projects(projectId);
    const revenue = project.shareprice;

    const userBalance = await ethers.provider.getBalance(user);
    console.log("Selling Shares!!!!!!");
    console.log("User Balance before selling shares " + parseInt(`${userBalance}`)/1e18);

    const tokenAddress = await innoHunt.projectTokens(projectId);
    let innoToken = new ethers.Contract(tokenAddress, Abi, deployer);

    await innoToken.connect(user).approve(innoHunt, amount);
    await innoHunt.connect(user).sellShares(projectId, amount);
    const userTokenBalance = await innoToken.balanceOf(user.address);

    const contractTokenBalance = await innoToken.balanceOf(innoHunt);
    expect(parseInt(userTokenBalance)).to.equal(amount);
    expect(contractTokenBalance).to.equal(project.totalShares - 5n);

    const userBalance1 = await ethers.provider.getBalance(user);
    console.log("User Balance after selling shares " + parseInt(`${userBalance1}`)/1e18);

    const contractBalance = await ethers.provider.getBalance(innoHunt);
    console.log("Contract Balance : " + parseInt(`${contractBalance}`)/1e18);
  });
});
