// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Simple ERC-721A Contract to show all NFTs on marketplaces at once.
contract TheContract is ERC721A, Ownable {

    string public baseURI = "ipfs://CID/";
    uint256 maxsupply = 1000; //Supply will be equal to quantity.

    constructor(
        string memory _name,
        string memory _symbol) 
        
        ERC721A(_name, _symbol) {
        // It will mint the amount at the address that deployed this contract.
        _mint(msg.sender, maxsupply);
    }

}
