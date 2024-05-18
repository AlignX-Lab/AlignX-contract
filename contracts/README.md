## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# Data structure    
**Example** 
```
topic_id -> scene_id_0 -> scenarios_id_0
                       -> scenarios_id_1
                       -> scenarios_id_2
topic_id -> scene_id_1 -> scenarios_id_0
                       -> scenarios_id_1
                       -> scenarios_id_2
```

Workflow
1. Owner need to call `registerTopic(uint256 topicId_, uint256[] calldata scenes, uint256[] calldata scenariosLength)` before user can vote for topic.

Cast a vote:
1. User need to call `castVote(uint256 topicId, uint256 sceneId_, uint256[] calldata scenarios_, uint256[] calldata votes_)` per topic & scene Id. 
