// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTCollection.sol";

contract NFTCollectionTest is Test {
    NFTCollection public nft;

    address public owner = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    string public constant NAME = "Test NFT";
    string public constant SYMBOL = "TNFT";
    uint256 public constant MAX_SUPPLY = 100;
    string public constant BASE_URI = "https://api.example.com/nft/";
    uint256 public constant MINT_PRICE = 0.05 ether;

    function setUp() public {
        nft = new NFTCollection(NAME, SYMBOL, MAX_SUPPLY, BASE_URI, MINT_PRICE);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    receive() external payable {}

    function test_Constructor() public view {
        assertEq(nft.name(), NAME);
        assertEq(nft.symbol(), SYMBOL);
        assertEq(nft.maxSupply(), MAX_SUPPLY);
        assertEq(nft.mintPrice(), MINT_PRICE);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.mintingPaused(), false);
    }

    function test_Mint() public {
        vm.prank(user1);
        uint256 tokenId = nft.mint{value: MINT_PRICE}(user1);

        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.totalSupply(), 1);
    }

    function test_MintMultiple() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        vm.prank(user2);
        nft.mint{value: MINT_PRICE}(user2);

        assertEq(nft.totalSupply(), 2);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.ownerOf(1), user2);
    }

    function test_MintRevertsInsufficientPayment() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient payment");
        nft.mint{value: 0.01 ether}(user1);
    }

    function test_MintRevertsMaxSupply() public {
        NFTCollection smallNft = new NFTCollection(
            NAME,
            SYMBOL,
            2,
            BASE_URI,
            MINT_PRICE
        );

        vm.prank(user1);
        smallNft.mint{value: MINT_PRICE}(user1);

        vm.prank(user1);
        smallNft.mint{value: MINT_PRICE}(user1);

        vm.prank(user1);
        vm.expectRevert("Cannot mint more tokens");
        smallNft.mint{value: MINT_PRICE}(user1);
    }

    function test_MintRevertsPaused() public {
        nft.pauseMinting();

        vm.prank(user1);
        vm.expectRevert("Minting is paused");
        nft.mint{value: MINT_PRICE}(user1);
    }

    function test_TokenURI() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        string memory uri = nft.tokenURI(0);
        assertEq(uri, "https://api.example.com/nft/0");
    }

    function test_BaseURI() public view {
        assertEq(nft.baseURI(), BASE_URI);
    }

    function test_SetBaseURI() public {
        string memory newURI = "https://newapi.example.com/";
        nft.setBaseURI(newURI);
        assertEq(nft.baseURI(), newURI);
    }

    function test_SetBaseURIRevertsNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.setBaseURI("https://hack.com/");
    }

    function test_PauseMinting() public {
        nft.pauseMinting();
        assertEq(nft.mintingPaused(), true);
    }

    function test_PauseMintingRevertsAlreadyPaused() public {
        nft.pauseMinting();
        vm.expectRevert("Minting is already paused");
        nft.pauseMinting();
    }

    function test_ResumeMinting() public {
        nft.pauseMinting();
        nft.resumeMinting();
        assertEq(nft.mintingPaused(), false);
    }

    function test_ResumeMintingRevertsNotPaused() public {
        vm.expectRevert("Minting is not paused");
        nft.resumeMinting();
    }

    function test_PauseMintingRevertsNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.pauseMinting();
    }

    function test_SetMintPrice() public {
        uint256 newPrice = 0.1 ether;
        nft.setMintPrice(newPrice);
        assertEq(nft.mintPrice(), newPrice);
    }

    function test_SetMintPriceRevertsNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.setMintPrice(0.1 ether);
    }

    function test_Withdraw() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        vm.prank(user2);
        nft.mint{value: MINT_PRICE}(user2);

        uint256 contractBalance = address(nft).balance;
        uint256 ownerBalanceBefore = owner.balance;

        nft.withdraw();

        assertEq(address(nft).balance, 0);
        assertEq(owner.balance, ownerBalanceBefore + contractBalance);
    }

    function test_WithdrawRevertsNoBalance() public {
        vm.expectRevert("Insufficient balance");
        nft.withdraw();
    }

    function test_WithdrawRevertsNotOwner() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        vm.prank(user1);
        vm.expectRevert();
        nft.withdraw();
    }

    function test_Transfer() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        vm.prank(user1);
        nft.transferFrom(user1, user2, 0);

        assertEq(nft.ownerOf(0), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function test_Approve() public {
        vm.prank(user1);
        nft.mint{value: MINT_PRICE}(user1);

        vm.prank(user1);
        nft.approve(user2, 0);

        assertEq(nft.getApproved(0), user2);
    }

    function test_ApprovalForAll() public {
        vm.prank(user1);
        nft.setApprovalForAll(user2, true);

        assertEq(nft.isApprovedForAll(user1, user2), true);
    }
}
