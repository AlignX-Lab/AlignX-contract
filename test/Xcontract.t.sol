// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Xcontract.sol"; // Adjust the import path based on your project structure

contract XcontractTest is Test {
    Xcontract xContract;
    address owner;
    address rewardToken;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this); // Test contract is the owner
        rewardToken = address(0);
        xContract = new Xcontract(owner, rewardToken);
        user1 = address(0x171a88675c013AA1b78c79CBa06C4bBB8c60E1ac);
        vm.label(user1, "User1");
        vm.label(rewardToken, "RewardToken");
    }

    function testVoteCasting() public {
        uint256[] memory dataIDs = new uint256[](2);
        uint256[] memory votes = new uint256[](2);
        dataIDs[0] = 1;
        dataIDs[1] = 2;
        votes[0] = 1;
        votes[1] = 0; // Ensuring votes are strictly binary

        vm.prank(user1);
        xContract.castVote(user1, dataIDs, votes, 100);

        assertEq(xContract.data2Lable(user1, 1), 1, "Vote for dataID 1 by user1 should be 1 (Yes)");
        assertEq(xContract.data2Lable(user1, 2), 0, "Vote for dataID 2 by user1 should be 0 (No)");
    }

    function testBinaryScoreComputation() public {
        // Setup votes
        uint256[] memory dataIDs = new uint256[](1);
        uint256[] memory votes = new uint256[](1);
        uint256[] memory stdVotes = new uint256[](1);
        dataIDs[0] = 1;
        votes[0] = 1; // Binary vote
        stdVotes[0] = 50; // Standard vote score

        vm.prank(user1);
        xContract.castVote(user1, dataIDs, votes, 100);

        // Call score computation as the owner
        vm.prank(owner);
        xContract.putModelScore(dataIDs, stdVotes);

        uint256 totalScore = xContract.user2TotalScore(user1);
        assertEq(
            totalScore, 50, "Total score for user1 should be 50, corresponding to the standard vote score for a 'Yes'"
        );
    }
}
