// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
abstract contract NFTCollectionEvents {
    event NFTMinted(address indexed to, uint256 indexed tokenId);
    event BaseURIUpdated(string oldURI, string newURI);
    event MintingPaused(bool isPaused);
}
