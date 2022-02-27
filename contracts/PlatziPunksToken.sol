// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PlatziPunksToken is ERC20 {
    constructor(uint256 _maxSupply) ERC20("PlatziPunksToken", "PLPKST") {
        _mint(msg.sender, _maxSupply * 10**decimals());
    }
}
