// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error SaleInactive();
error SoldOut();
error InvalidPrice();
error WithdrawFailed();
error InvalidQuantity();

import "./ERC721A";

contract ThisContract is ERC721A, Ownable, ERC2981 {
    uint256 public price = 0.001 ether;
    uint256 public presalePrice = 0.0001 ether;
    uint256 public maxPerWallet = 10;
    uint256 public maxPerTransaction = 10;
    uint256 public presaleMaxPerWallet = 1;
    uint256 public presaleMaxPerTransaction = 1;

    uint256 public immutable presaleSupply = 100;
    uint256 public immutable supply = 1000;

    enum SaleState {
        CLOSED,
        PRESALE,
        OPEN
    }

    SaleState public saleState = SaleState.CLOSED;

    string public _baseTokenURI;

    mapping(address => uint256) public addressMintBalance;    

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        uint96 _royaltyAmount
    ) ERC721A(_name, _symbol) {
        _baseTokenURI = _baseUri;
        _setDefaultRoyalty(owner(), _royaltyAmount);
    }

    function mint(uint256 qty) external payable {
        if (saleState != SaleState.OPEN) revert SaleInactive();
        if (_currentIndex > supply) revert SoldOut();
        if (msg.value != price * qty) revert InvalidPrice();

        if (addressMintBalance[msg.sender] + qty > maxPerWallet) revert InvalidQuantity();
        if (qty > maxPerTransaction) revert InvalidQuantity();

        _safeMint(msg.sender, qty);

        addressMintBalance[msg.sender] += qty;
    }

    function presale(uint256 qty) external payable {
        if (saleState != SaleState.PRESALE) revert SaleInactive();
        if (_currentIndex > presaleSupply) revert SoldOut();
        if (msg.value != presalePrice * qty) revert InvalidPrice();

        if (addressMintBalance[msg.sender] + qty > presaleMaxPerWallet) revert InvalidQuantity();
        if (qty > presaleMaxPerTransaction) revert InvalidQuantity();

        _safeMint(msg.sender, qty);

        addressMintBalance[msg.sender] += qty;
    }

    

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setPresalePrice(uint256 newPrice) external onlyOwner {
        presalePrice = newPrice;
    }

    function setSaleState(uint8 _state) external onlyOwner {
        saleState = SaleState(_state);
    }

    function freeMint(uint256 qty, address recipient) external onlyOwner {
        if (_currentIndex > supply) revert SoldOut();
        _safeMint(recipient, qty);
    }

    function setPerWalletMax(uint256 _val) external onlyOwner {
        maxPerWallet = _val;
    }

    function setPerTransactionMax(uint256 _val) external onlyOwner {
        maxPerTransaction = _val;
    }

    function setPresalePerWalletMax(uint256 _val) external onlyOwner {
        presaleMaxPerWallet = _val;
    }

    function setPresalePerTransactionMax(uint256 _val) external onlyOwner {
        presaleMaxPerTransaction = _val;
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        if (!success) revert WithdrawFailed();
    }

    function setRoyaltyInfo(address receiver, uint96 feeBasisPoints)
        external
        onlyOwner
    {
        _setDefaultRoyalty(receiver, feeBasisPoints);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
