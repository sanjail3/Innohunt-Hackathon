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
    uint256 public constant PRICE_CHANGE_THRESHOLD = 1000; 

    struct Project {
        address owner;
        string name;
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
        string description;
        uint256 upvoteCount;
        uint256 downvoteCount;
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
        projects[totalProjects].owner = msg.sender;
        projects[totalProjects].name = name;
        projects[totalProjects].minProposalThreshold = _minProposalThreshold;
        projects[totalProjects].minVoteThreshold = _minVoteThreshold;
        projects[totalProjects].totalShares = _totalshares;
        projects[totalProjects].remainingShares = _totalshares;
        projects[totalProjects].shareprice = _shareprice;
        totalProjects++;

        address newToken = address(new CreateToken(name, symbol, _totalshares, address(this)));
        IERC20(newToken).approve(address(this), _totalshares);
        projectTokens[totalProjects-1] = newToken;
    }

    function buyShares(uint256 projectId, uint256 _amount) external payable {
        require(_amount > 0, "Invalid amount");
        uint256 cost = _amount * projects[projectId].shareprice;
        require(msg.value >= cost, "Insufficient funds");
        IERC20(projectTokens[projectId]).transfer(msg.sender, _amount);
        projects[projectId].remainingShares -= _amount;
        projects[projectId].shareprice = ((projects[projectId].totalShares) + (projects[projectId].totalShares*15)/100) / IERC20(projectTokens[projectId]).balanceOf(address(this));
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
}
