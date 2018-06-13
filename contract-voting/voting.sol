pragma solidity ^0.4.23;

contract Voting {
    
    // define structs
    struct Voter {
        bool voted;
        uint vote;
        bool rightToVote;
    }
    
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }
    
    // define mappings
    mapping (address => Voter) public voters;
    mapping (uint => Proposal) public proposals;
    
    // define state variables
    address public owner;
    uint public votingStart;
    uint public votingTime;
    uint public numProposals;
    
    // define modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Only the owner of the contract can perform this action");
        }
        _;
    }
    
    // define functions
    constructor(bytes32[] proposalNames, uint votingTimeLimit) public {
        owner = msg.sender;
        votingStart = now;
        votingTime = votingTimeLimit;
        numProposals = proposalNames.length;
        
        // add each of the proposal names as a proposal
        for (uint i = 0; i < proposalNames.length; i++) {
            Proposal storage p = proposals[i];
            p.name = proposalNames[i];
            p.voteCount = 0;
        }
    }
    
    // give an address the right to vote
    function giveRightToVote(address voter) public onlyOwner {
        if (voters[voter].voted) {
            revert("Voter has already cast their vote");
        }
        voters[voter].rightToVote = true;
    }
    
    // vote
    function vote(uint proposal) public {
        if (!voters[msg.sender].rightToVote) {
            revert("Voter does not have the right to vote yet");
        } else if (voters[msg.sender].voted) {
            revert("Voter has already cast their vote");
        } else if ((votingStart + votingTime) > now) {
            revert("Voting time has closed");
        }
        
        proposals[proposal].voteCount++;
        
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;
    }
    
    // get the winning proposal
    function winningProposal() public view returns (uint winningProposalId, bytes32 proposalName) {
        uint winningVoteCount = 0;
        
        for (uint i = 0; i < numProposals; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
                proposalName = proposals[i].name;
            }
        }
    }
}