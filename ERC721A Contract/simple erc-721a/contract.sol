// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Simple ERC-721A Contract to show all NFTs on marketplaces at once.
contract ContractName is ERC721A, Ownable {

    string public baseURI = "ipfs://{CID}/";
    string public baseExtension = ".json";
    uint256 currentIndex = 1; //Make first tokenId = first json file.
    uint256 maxsupply = 1000; //It will be equal to quantity.

    constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol) {
        // It will mint the quantity at the address that deployed this contract.
        _mint(msg.sender, maxsupply);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return currentIndex;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension)) : '';
    }
}
