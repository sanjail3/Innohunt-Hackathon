// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";


contract CreateToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address to) ERC20(name, symbol) {
        _mint(to, initialSupply);
    }
}

contract InnoHunt {
    address private owner;
    uint public totalProjects;

    struct Project {
        address owner;
        uint256 totalRaised;
        uint256 totalShares;
        uint256 remainingShares;
        uint256 shareprice;
        mapping(address => uint256) shares;
        address[] investors;
        uint256 minProposalThreshold;
        uint256 minVoteThreshold;
        uint256 proposalCount;
        mapping(uint256 => Proposal) proposals;
    }

    struct Proposal {
        uint256 upvoteCount;
        uint256 downvoteCount;
        uint256 startTime;
        uint256 duration;
        uint256 endTime;
        uint256 threshold;
        mapping(address => Vote) votes;
    }

    struct Vote {
        bool hasVoted;
        bool isUpvote;
        uint256 voteWeight;
    }

    mapping(uint256 => Project) public projects;
    mapping(uint256 => address) public projectTokens;

    constructor() {
        owner = msg.sender;
    }

    function createProject(string memory name,string memory symbol, uint _minProposalThreshold, uint _minVoteThreshold, uint _shareprice, uint _totalshares) external {
        Project storage project = projects[totalProjects];
        project.owner = msg.sender;
        project.minProposalThreshold = _minProposalThreshold;
        project.minVoteThreshold = _minVoteThreshold;
        project.totalShares = _totalshares;
        project.remainingShares = _totalshares;
        project.shareprice = _shareprice;
        totalProjects++;

        address newToken = address(new CreateToken(name, symbol, _totalshares, address(this)));
        IERC20(newToken).approve(address(this), _totalshares);
        projectTokens[totalProjects-1] = newToken;
    }

    function buyShares(uint256 projectId, uint256 _amount) external payable {
        require(_amount > 0, "Invalid amount");
        Project storage project = projects[projectId];
        uint256 cost = _amount * project.shareprice;
        require(msg.value >= cost, "Insufficient funds");
        project.totalRaised += cost;
        IERC20(projectTokens[projectId]).transfer(msg.sender, _amount);
        project.remainingShares -= _amount;
        project.shareprice = ((project.totalShares) + (project.totalShares*15)/100) / IERC20(projectTokens[projectId]).balanceOf(address(this));
    }

    function sellShares(uint256 projectId, uint256 _amount) external payable {
        require(_amount > 0 && IERC20(projectTokens[projectId]).balanceOf(msg.sender) >= _amount, "Invalid amount");
        uint256 revenue = _amount * projects[projectId].shareprice;
        IERC20(projectTokens[projectId]).transferFrom(msg.sender,address(this), _amount);
        projects[projectId].remainingShares += _amount;
        (bool s,) = msg.sender.call{value: revenue*1e18}("");
        require(s);
        projects[projectId].shareprice = ((projects[projectId].totalShares) - (projects[projectId].totalShares*15)/100) / IERC20(projectTokens[projectId]).balanceOf(address(this));
    }


    function createProposal(uint projectId, uint duration,uint _threshold) external {
        Project storage project = projects[projectId];
        project.proposalCount++;
        Proposal storage newProposal = project.proposals[project.proposalCount];
        newProposal.threshold = _threshold;
        newProposal.startTime = block.timestamp; 
        newProposal.duration = duration * 1 days; 
        newProposal.endTime = newProposal.startTime + newProposal.duration;
    }

    function vote(uint projectId, uint256 proposalId, bool isUpvote, uint _amount) external {
        Project storage project = projects[projectId];
        Proposal storage proposal = project.proposals[proposalId];
        require(proposal.endTime > block.timestamp);
        require(_amount > 0  && _amount <=  project.shares[msg.sender]);
        require(!proposal.votes[msg.sender].hasVoted, "Already voted");

        if (isUpvote) {
            proposal.upvoteCount += _amount;
        } else {
            proposal.downvoteCount += _amount;
        }
        proposal.votes[msg.sender] = Vote(true, isUpvote, _amount);
    }

    function getProposalVotes(uint projectId, uint256 proposalId) external view returns (uint256 upvotes, uint256 downvotes) {
        Project storage project = projects[projectId];
        Proposal storage proposal = project.proposals[proposalId];
        return (proposal.upvoteCount, proposal.downvoteCount);
    }
}
