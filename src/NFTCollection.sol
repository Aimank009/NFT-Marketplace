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

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        string memory _baseTokenURI
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        baseTokenURI = _baseTokenURI;
    }

    function mint(address _to) external override returns (uint256) {
        require(nextTokenId < maxSupply, "Cannot mint more tokens");
        uint256 tempNextTokenId = nextTokenId;
        nextTokenId++;
        _safeMint(_to, tempNextTokenId);

        emit NFTMinted(_to, tempNextTokenId);

        return tempNextTokenId;
    }

    function totalSupply() external view override returns (uint256) {
        return nextTokenId;
    }
}
