// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Xcontract} from "../src/Xcontract.sol";

contract XContractTest is Test {
    struct UsersVotes {
        address[] users;
        uint256[] votes;
    }
    // struct ScenariosVotes{
    //     uint256[] scenarios;
    //     uint256[] votes;
    // }

    Xcontract xcontract;
    uint256 topicId;
    uint256[] scenes;
    uint256[] scenariosLength;
    address alice;
    address bob;
    address owner;

    function setUp() public {
        topicId = 0; // let's assume we only have 1 topic to vote
        scenes.push(0); // this topic has 2 scenes
        scenes.push(1);
        scenariosLength.push(10); // scene_0 has 10 scenarios
        scenariosLength.push(10); // scene_1 has 10 scenarios
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        owner = makeAddr("owner");

        xcontract = new Xcontract(owner);
    }

    // topic [0]
    // scene [0,1]
    // for scene_0, userA voted scenarios [0,1,2] with vote [5,2,3]
    // for scene_1, userA voted scenarios [1,4] with votes [5,5]
    // for scene_0, userB voted scenarios [2,4,8] with votes [1,1,5]

    function test_registeredTopicAndScene() public {
        vm.prank(owner);
        xcontract.registerTopic(topicId, scenes, scenariosLength);
        uint256[] memory topics = xcontract.getTopicArray();
        assertEq(topics.length, 1);
    }

    // run with --via-ir to avoid stack too deep error
    function test_castVote() public {
        registerTopicAndScene();
        uint256 sceneId_0 = 0;

        uint256[] memory scenarios_0 = new uint256[](3);
        scenarios_0[0] = 0;
        scenarios_0[1] = 1;
        scenarios_0[2] = 2;
        uint256[] memory votes_0 = new uint256[](3);
        votes_0[0] = 5;
        votes_0[1] = 2;
        votes_0[2] = 3;

        vm.prank(alice);
        xcontract.castVote(topicId, sceneId_0, scenarios_0, votes_0);
        // bytes32 topic0_Scene1 = keccak256(abi.encode(topicId,sceneId_0));
        Xcontract.ScenariosVotes memory userVotedScenarios_0 =
            xcontract.getUserToScenariosVotes(alice, topicId, sceneId_0);
        assertEq(userVotedScenarios_0.scenarios[0], 0);
        assertEq(userVotedScenarios_0.scenarios[1], 1);
        assertEq(userVotedScenarios_0.scenarios[2], 2);
        assertEq(userVotedScenarios_0.votes[0], 5);
        assertEq(userVotedScenarios_0.votes[1], 2);
        assertEq(userVotedScenarios_0.votes[2], 3);

        Xcontract.UsersVotes memory usersVotes_0_0 =
            xcontract.getScenarioToUsersVotes(topicId, sceneId_0, scenarios_0[0]);
        assertEq(usersVotes_0_0.users.length, 1);
        assertEq(usersVotes_0_0.users[0], alice);
        assertEq(usersVotes_0_0.votes.length, 1);
        assertEq(usersVotes_0_0.votes[0], 5);
        Xcontract.UsersVotes memory usersVotes_0_1 =
            xcontract.getScenarioToUsersVotes(topicId, sceneId_0, scenarios_0[1]);
        assertEq(usersVotes_0_1.users.length, 1);
        assertEq(usersVotes_0_1.users[0], alice);
        assertEq(usersVotes_0_1.votes.length, 1);
        assertEq(usersVotes_0_1.votes[0], 2);

        // Alice cast second scenario
        uint256 sceneId_1 = 1;
        uint256[] memory scenarios_1 = new uint256[](3);
        scenarios_1[0] = 1;
        scenarios_1[1] = 4;
        uint256[] memory votes_1 = new uint256[](3);
        votes_1[0] = 5;
        votes_1[1] = 5;
        vm.prank(alice);
        xcontract.castVote(topicId, sceneId_1, scenarios_1, votes_1);
        Xcontract.ScenariosVotes memory userVotedScenarios_1 =
            xcontract.getUserToScenariosVotes(alice, topicId, sceneId_1);
        assertEq(userVotedScenarios_1.scenarios[0], 1);
        assertEq(userVotedScenarios_1.scenarios[1], 4);
        assertEq(userVotedScenarios_1.votes[0], 5);
        assertEq(userVotedScenarios_1.votes[1], 5);

        Xcontract.UsersVotes memory usersVotes_1 = xcontract.getScenarioToUsersVotes(topicId, sceneId_1, scenarios_1[0]);
        assertEq(usersVotes_1.users.length, 1);
        assertEq(usersVotes_1.users[0], alice);
        assertEq(usersVotes_1.votes.length, 1);
        assertEq(usersVotes_1.votes[0], 5);

        // Bob cast for scene 0
        // for scene_0, userB voted scenarios [2,4,8] with votes [1,1,5]
        uint256[] memory scenarios_0_B = new uint256[](3);
        scenarios_0_B[0] = 2;
        scenarios_0_B[1] = 4;
        scenarios_0_B[2] = 8;
        uint256[] memory votes_0_B = new uint256[](3);
        votes_0_B[0] = 1;
        votes_0_B[1] = 1;
        votes_0_B[2] = 5;
        vm.prank(bob);
        xcontract.castVote(topicId, sceneId_0, scenarios_0_B, votes_0_B);

        Xcontract.ScenariosVotes memory userVotedScenarios_0_B =
            xcontract.getUserToScenariosVotes(bob, topicId, sceneId_0);
        assertEq(userVotedScenarios_0_B.scenarios[0], 2);
        assertEq(userVotedScenarios_0_B.scenarios[1], 4);
        assertEq(userVotedScenarios_0_B.scenarios[2], 8);
        assertEq(userVotedScenarios_0_B.votes[0], 1);
        assertEq(userVotedScenarios_0_B.votes[1], 1);
        assertEq(userVotedScenarios_0_B.votes[2], 5);

        // scene 0, scenario 1 has two voters = A,B
        Xcontract.UsersVotes memory usersVotes_0_B =
            xcontract.getScenarioToUsersVotes(topicId, sceneId_0, scenarios_0_B[0]);
        assertEq(usersVotes_0_B.users.length, 2);
        assertEq(usersVotes_0_B.users[0], alice);
        assertEq(usersVotes_0_B.users[1], bob);
        assertEq(usersVotes_0_B.votes.length, 2);
        assertEq(usersVotes_0_B.votes[0], 3);
        assertEq(usersVotes_0_B.votes[1], 1);
    }

    // helper

    function registerTopicAndScene() public {
        vm.prank(owner);
        xcontract.registerTopic(topicId, scenes, scenariosLength);
    }
}
