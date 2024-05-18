// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Xcontract.sol";

contract XContractScript is Script {
    Xcontract xContract;
    address owner;
    address rewardToken;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        owner = address(this); // Test contract is the owner
        rewardToken = address(0);
        xContract = new Xcontract(owner, rewardToken);

        vm.stopBroadcast();
    }
}
