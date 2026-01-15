// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/INFTCollection.sol";
import "./events/NFTCollectionEvents.sol";

contract NFTCollection is ERC721, Ownable, INFTCollection, NFTCollectionEvents {
    uint256 private nextTokenId;
    uint256 public maxSupply;
    string private baseTokenURI;
    bool public mintingPaused;
    uint256 public mintPrice;
    address public minter;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        string memory _baseTokenURI,
        uint256 _mintPrice
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        baseTokenURI = _baseTokenURI;
        mintPrice = _mintPrice;
    }

    modifier onlyMinterOrOwner() {
        require(
            msg.sender == owner() || msg.sender == minter,
            "Not authorized"
        );
        _;
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function mint(address _to) external payable override returns (uint256) {
        require(nextTokenId < maxSupply, "Cannot mint more tokens");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(!mintingPaused, "Minting is paused");
        uint256 tempNextTokenId = nextTokenId;
        nextTokenId++;
        _safeMint(_to, tempNextTokenId);

        emit NFTMinted(_to, tempNextTokenId);

        return tempNextTokenId;
    }

    function minterMint(
        address _to
    ) external onlyMinterOrOwner returns (uint256) {
        require(nextTokenId < maxSupply, "Cannot mint more tokens");
        require(!mintingPaused, "Minting is paused");
        uint256 tempNextTokenId = nextTokenId;
        nextTokenId++;
        _safeMint(_to, tempNextTokenId);

        emit NFTMinted(_to, tempNextTokenId);

        return tempNextTokenId;
    }

    function totalSupply() external view override returns (uint256) {
        return nextTokenId;
    }

    function baseURI() external view override returns (string memory) {
        return baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _newBaseTokenURI) external onlyOwner {
        string memory tempBaseTokenURI = baseTokenURI;

        baseTokenURI = _newBaseTokenURI;
        emit BaseURIUpdated(tempBaseTokenURI, baseTokenURI);
    }

    function pauseMinting() external onlyOwner {
        require(!mintingPaused, "Minting is already paused");

        mintingPaused = true;
        emit MintingPaused(true);
    }

    function resumeMinting() external onlyOwner {
        require(mintingPaused, "Minting is not paused");

        mintingPaused = false;
        emit MintingPaused(false);
    }
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient balance");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }

    function setMintPrice(uint256 _setMintPrice) external onlyOwner {
        uint256 oldMintPrice = mintPrice;
        mintPrice = _setMintPrice;
        emit MintPriceUpdated(oldMintPrice, mintPrice);
    }
}
