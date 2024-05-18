// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Xcontract is Ownable {
    // uint256 topicId -> uint256 sceneId -> uint256[] scenarioId
    // uint256 scenario -> address user -> uint256 vote
    // User vote for topicId->sceneId->scenarioId[]
    // Vote data is retrieved off chain for calculation

    address[] public users;
    uint256[] public topics;
    mapping(address user => bool isFirstTime) public isUserRegistered;
    mapping(uint256 topicId => uint256 sceneLength) public topicToSceneLen;
    mapping(bytes32 topicScene => uint256 scenarioLength) public tSToScenarioLen; // Redundant?

    struct UsersVotes {
        address[] users;
        uint256[] votes;
    }

    struct ScenariosVotes {
        uint256[] scenarios;
        uint256[] votes;
    }

    mapping(bytes32 topicScene => mapping(uint256 scenarioId => UsersVotes usersVotes)) scenariosToUsersVotes;
    mapping(address user => mapping(bytes32 topicScene => ScenariosVotes scenariosVotes)) userToScenariosVotes;
    mapping(address user => mapping(uint256 topicId => mapping(uint256 sceneId => bool isSceneVoted))) public
        userToScene; // Redundant?
    mapping(address user => uint256[] topicIds) public userVotedTopics; // Redundant?

    constructor(address owner) Ownable(owner) {}

    /// @notice called by owner to register a topic and its details
    /// @param topicId_ topic id to register
    /// @param scenes array of scene under the topic
    /// @param scenariosLength array of scenarios length under scenes, i.e. scenariosLength[0] is the number of scenarios for scenes[0]
    function registerTopic(uint256 topicId_, uint256[] calldata scenes, uint256[] calldata scenariosLength)
        external
        onlyOwner
    {
        topicToSceneLen[topicId_] = scenes.length;
        topics.push(topicId_);
        require(scenes.length == scenariosLength.length, "mismatch scene and scenario length");
        for (uint256 i = 0; i < scenes.length; i++) {
            bytes32 topicScene = keccak256(abi.encode(topicId_, scenes[i]));
            tSToScenarioLen[topicScene] = scenariosLength[i];
        }
    }

    /// @notice cast a vote by user
    /// @dev called by user per topic per scene basis
    /// @param topicId topicId to vote for
    /// @param sceneId_ sceneId to vote for
    /// @param scenarios_ array of scenarios voted
    /// @param votes_ array of votes as per scenarios_  array, i.e. votes_[0] is the vote for scenarios_[0] from msg.sender
    function castVote(uint256 topicId, uint256 sceneId_, uint256[] calldata scenarios_, uint256[] calldata votes_)
        external
    {
        require(scenarios_.length == votes_.length, "mismatch scenarios and votes length");
        require(topicId < topics.length, "topic is not registered");
        if (!isUserRegistered[msg.sender]) {
            users.push(msg.sender);
        }

        // Check if user votes on a new topic
        uint256 userVotedTopicsLength = userVotedTopics[msg.sender].length;
        uint256 topicLength;
        for (topicLength = 0; topicLength < userVotedTopicsLength; topicLength++) {
            if (userVotedTopics[msg.sender][topicLength] == topicId) break;
        }
        if (userVotedTopicsLength == 0 || topicLength == userVotedTopicsLength) {
            userVotedTopics[msg.sender].push(topicId);
        }

        bytes32 topicScene = keccak256(abi.encode(topicId, sceneId_));
        ScenariosVotes memory userHasVoted = ScenariosVotes(scenarios_, votes_);
        userToScenariosVotes[msg.sender][topicScene] = userHasVoted;

        uint256 scenariosLength = scenarios_.length;
        for (uint256 i = 0; i < scenariosLength; i++) {
            uint256 scenarioId = scenarios_[i];
            scenariosToUsersVotes[topicScene][scenarioId].users.push(msg.sender);
            scenariosToUsersVotes[topicScene][scenarioId].votes.push(votes_[i]);
            userToScene[msg.sender][topicId][scenarioId] = true;
        }
    }

    function claimReward(address user, uint256 topicId, uint256 sceneId) internal returns (uint256) {
        // TODO
    }

    function setReward() external onlyOwner {
        // TODO
    }

    function getTopicArray() external view returns (uint256[] memory) {
        return topics;
    }

    function getUserArray() external view returns (address[] memory) {
        return users;
    }

    function getUserToScenariosVotes(address user, uint256 topicId_, uint256 sceneId_)
        public
        view
        returns (ScenariosVotes memory scenariosVotes_)
    {
        bytes32 topicScene = keccak256(abi.encode(topicId_, sceneId_));
        scenariosVotes_ = userToScenariosVotes[user][topicScene];
    }

    function getScenarioToUsersVotes(uint256 topicId_, uint256 sceneId_, uint256 scenarioId_)
        public
        view
        returns (UsersVotes memory userVotes)
    {
        bytes32 topicScene = keccak256(abi.encode(topicId_, sceneId_));
        userVotes = scenariosToUsersVotes[topicScene][scenarioId_];
    }
}
