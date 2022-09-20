// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheContract is ERC721A, Ownable {

    string public baseURI;
    uint256 MAX_MINTS = 10000;
    uint256 MAX_SUPPLY = 10000;
    uint256 public mintRate = 0 ether;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI) 
        
        ERC721A(_name, _symbol) {
        setBaseURI(_initBaseURI);
        _mint(msg.sender, 10000);
    }

    function mint(uint256 quantity) external payable {
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _mint(msg.sender, quantity);
    }
    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() override internal view returns (string memory) {
        return baseURI;
    }

    function setMintRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
