# Uniswap V2 Core - Foundry Edition

This repository contains the core contracts for the Uniswap V2 Protocol. For the periphery contracts, see the [uniswap-v2-periphery](https://github.com/Uniswap/v2-periphery) repository.

### Foundry Modification
This repository has been modified to also support Foundry Solidity tests.

If you already have Foundry's `forge` installed, first install the dependencies with `yarn`, and then simply run `forge test` to run the Solidity tests under contracts/test folder.

Due to the solidity version that the v2 contracts were deployed/compiled in (`0.5.16`), limited fuzz testing could be employed. 
Cheatcodes which mutate the `vm` state also could not be used. 
This is because [Forge Standard Library's](https://github.com/foundry-rs) `Test` contract is only compatible with solidity version `0.6.2` onwards.