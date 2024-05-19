// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Xcontract is Ownable {
    // uint256 topicId -> uint256 sceneId -> uint256[] scenarioId
    // uint256 scenario -> address user -> uint256 vote
    // User vote for topicId->sceneId->scenarioId[]
    // Vote data is retrieved off chain for calculation

    mapping(address userID => mapping(uint256 dataID => uint256 label)) public data2Lable;
    address[] public users;
    mapping(address userID => uint256[] dataIDs) public user2DataIDs;
    address rewardToken;
    mapping(address => uint256) public user2TotalScore;

    constructor(address owner, address rewardToken_) Ownable(owner) {
        rewardToken = rewardToken_;
    }

    /// @notice cast a vote by user
    /// @dev called by user per topic per scene basis
    /// @param dataIDs_ dataIDs to vote for
    /// @param votes_ votes (0|1) for the dataIDs
    function castVote(address userID_, uint256[] calldata dataIDs_, uint256[] calldata votes_, uint256 stack_)
        external
    {
        require(dataIDs_.length == votes_.length, "Xcontract: dataIDs and votes length mismatch");
        // try to stack rewardToken to this contract
        IERC20 token = IERC20(rewardToken);
        require(tx.origin == userID_, "Xcontract: only user can cast vote");
        token.transferFrom(userID_, address(this), stack_);
        for (uint256 i = 0; i < dataIDs_.length; i++) {
            data2Lable[userID_][dataIDs_[i]] = votes_[i];
            users.push(userID_);
        }
        user2DataIDs[userID_] = dataIDs_;
    }

    struct Data2LabelPair {
        address userID;
        uint256 dataID;
        uint256 label;
    }

    function fetchData2Train() external view returns (Data2LabelPair[] memory) {
        uint256 totalCount = 0;
        for (uint256 i = 0; i < users.length; i++) {
            address userID = users[i];
            for (uint256 j = 0; j < user2DataIDs[userID].length; j++) {
                totalCount++;
            }
        }

        Data2LabelPair[] memory pairs = new Data2LabelPair[](totalCount);
        uint256 index = 0;
        for (uint256 i = 0; i < users.length; i++) {
            address userID = users[i];
            mapping(uint256 => uint256) storage innerMap = data2Lable[userID];
            for (uint256 j = 0; j < user2DataIDs[userID].length; j++) {
                uint256 dataID = user2DataIDs[userID][j];
                pairs[index++] = Data2LabelPair(userID, dataID, innerMap[dataID]);
            }
        }

        return pairs;
    }

    /// @notice user clain reward
    /// @dev called by user
    function claimReward() external {
        uint256 sum = 0;
        for (uint256 i = 0; i < users.length; i++) {
            sum += user2TotalScore[users[i]];
        }
        uint256 balance = IERC20(rewardToken).balanceOf(address(this));
        uint256 userReward = user2TotalScore[msg.sender]*balance/sum;
        IERC20 token = IERC20(rewardToken);
        require(tx.origin == msg.sender, "Xcontract: only user can cast vote");
        token.transferFrom(address(this), msg.sender, userReward);
    }

    /// @notice put model score and compute Softmax with data2Lable to get User dividend ratio
    /// @dev called by backend training server
    function putModelScore(uint256[] calldata dataIDs_, uint256[] calldata stdVotes_) external {
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
    
    function setRewardToken(address token_) external {
        rewardToken = token_;
    }
}
