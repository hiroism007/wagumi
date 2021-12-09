// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFT is ERC721Enumerable, ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;

  constructor(string memory customBaseURI_, bytes32 merkleRoot_)
    ERC721("Wagumi Cats", "WAGUMI")
  {
    customBaseURI = customBaseURI_;
    root = merkleRoot_;
  }

  /** WHITELIST MARKLE TREE ROOT **/
  bytes32 public immutable root;

  /** MINTING LIMITS **/

  mapping(address => uint256) private mintCountMap;

  mapping(address => uint256) private allowedMintCountMap;

  uint256 public constant MINT_LIMIT_PER_WALLET = 1;

  function allowedMintCount(address minter) public view returns (uint256) {
    return MINT_LIMIT_PER_WALLET - mintCountMap[minter];
  }

  function updateMintCount(address minter, uint256 count) private {
    mintCountMap[minter] += count;
  }

  /** MINTING **/

  uint256 public constant MAX_SUPPLY = 1000;

  function mint() public nonReentrant {
    require(saleIsActive, "Sale not active");

    if (allowedMintCount(_msgSender()) >= 1) {
      updateMintCount(_msgSender(), 1);
    } else {
      revert("Minting limit exceeded");
    }

    require(totalSupply() < MAX_SUPPLY, "Exceeds max supply");

    _safeMint(_msgSender(), totalSupply());
  }

  /** ACTIVATION **/

  bool public saleIsActive = true;

  function setSaleIsActive(bool saleIsActive_) external onlyOwner {
    saleIsActive = saleIsActive_;
  }

  /** URI HANDLING **/

  string private customBaseURI;

  function setBaseURI(string memory customBaseURI_) external onlyOwner {
    customBaseURI = customBaseURI_;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return customBaseURI;
  }

  /** WHITELIST MERKLE PROOF VERIFICATION */
  function _verify(bytes32 leaf, bytes32[] memory proof)
    internal
    view
    returns (bool)
  {
    return MerkleProof.verify(proof, root, leaf);
  }
}

// Contract created with Studio 721 v1.4.0
// https://721.so
