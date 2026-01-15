# NFT Collection - ERC721 Smart Contract

A complete ERC721 NFT collection contract with minting, pricing, pause functionality, and admin controls.

## Features

- Sequential token ID minting (0, 1, 2, ...)
- Configurable max supply limit
- Customizable mint price with payment handling
- Metadata URI management for off-chain assets
- Pause and resume minting functionality
- Owner withdrawal of collected funds
- Full ERC721 compliance with safe transfers

## Contract Architecture

```
src/
  NFTCollection.sol        - Main contract with all logic
  interfaces/
    INFTCollection.sol     - External interface definition
  events/
    NFTCollectionEvents.sol - Event declarations
```

## Functions

### User Functions

| Function | Description |
|----------|-------------|
| `mint(address to)` | Mint a new NFT to specified address (requires payment) |
| `tokenURI(uint256 tokenId)` | Get metadata URI for a token |
| `ownerOf(uint256 tokenId)` | Get owner of a token |
| `balanceOf(address owner)` | Get token count for an address |
| `transferFrom(from, to, tokenId)` | Transfer token ownership |
| `safeTransferFrom(from, to, tokenId)` | Safe transfer with receiver check |
| `approve(address to, uint256 tokenId)` | Approve address to transfer token |
| `setApprovalForAll(operator, approved)` | Approve operator for all tokens |

### Admin Functions

| Function | Description |
|----------|-------------|
| `pauseMinting()` | Pause all minting operations |
| `resumeMinting()` | Resume minting operations |
| `setBaseURI(string newURI)` | Update metadata base URL |
| `setMintPrice(uint256 newPrice)` | Update mint price |
| `withdraw()` | Withdraw collected ETH to owner |

### View Functions

| Function | Description |
|----------|-------------|
| `totalSupply()` | Total minted tokens |
| `maxSupply()` | Maximum allowed tokens |
| `mintPrice()` | Current mint price |
| `baseURI()` | Metadata base URL |
| `mintingPaused()` | Check if minting is paused |

## Constructor Parameters

```solidity
constructor(
    string memory name,        // Collection name
    string memory symbol,      // Collection symbol
    uint256 maxSupply,         // Maximum tokens allowed
    string memory baseTokenURI,// Metadata base URL
    uint256 mintPrice          // Price per mint in wei
)
```

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Deploy

```shell
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <KEY>
```

## Dependencies

- OpenZeppelin Contracts v5.0 (ERC721, Ownable)
- Foundry (development framework)

## License

MIT
