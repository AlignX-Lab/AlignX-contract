// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Xcontract is Ownable {
    // uint256 topicId -> uint256 sceneId -> uint256[] scenarioId
    // uint256 scenario -> address user -> uint256 vote
    // User vote for topicId->sceneId->scenarioId[]
    // Vote data is retrieved off chain for calculation

    mapping(address userID => mapping(uint256 dataID => uint256 label)) public data2Lable;
    address[] public users;
    address rewardToken;
    mapping(address => uint256) public user2TotalScore;

    constructor(address owner, address rewardToken_) Ownable(owner) {
        rewardToken = rewardToken_;
    }

    /// @notice cast a vote by user
    /// @dev called by user per topic per scene basis
    /// @param dataIDs_ dataIDs to vote for
    /// @param votes_ votes (0|1) for the dataIDs
    function castVote(address userID_, uint256[] calldata dataIDs_, uint256[] calldata votes_)
        external
    {
        require(dataIDs_.length == votes_.length, "Xcontract: dataIDs and votes length mismatch");
        // try to stack rewardToken to this contract
        // TODO
        for (uint256 i = 0; i < dataIDs_.length; i++) {
            data2Lable[userID_][dataIDs_[i]] = votes_[i];
            users.push(userID_);
        }
    }

    /// @notice submit data2Lable to train
    /// @dev called by timer (maybe with chainlink Automation). Maybe implemented with Chainlink Function
    function submitData2Train() external {
        // TODO
    }

    /// @notice user clain reward 
    /// @dev called by user
    function claimReward() external {
        // TODO
    }

    /// @notice put model score and compute Softmax with data2Lable to get User dividend ratio
    /// @dev called by backend training server
    function putModelScore(uint256[] calldata dataIDs_, uint256[] calldata stdVotes_) external onlyOwner {
        require(dataIDs_.length == stdVotes_.length, "Xcontract: dataIDs and votes length mismatch");

        uint256[] memory totalScores = new uint256[](users.length);

        // Compute scores for each user
        for (uint256 i = 0; i < users.length; i++) {
            uint256 userTotalScore = 0;
            for (uint256 j = 0; j < dataIDs_.length; j++) {
                userTotalScore += data2Lable[users[i]][dataIDs_[j]] * stdVotes_[j];
            }
            totalScores[i] = userTotalScore;
        }
        for (uint256 i = 0; i < users.length; i++) {
            user2TotalScore[users[i]] = totalScores[i];
        }
    }
}
