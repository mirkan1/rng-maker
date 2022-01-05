// SPDX-License-Identifier: MIT
// @author rngmaker
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

contract raqNFT is ERC721URIStorage, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public baseURI = "data:application/json;base64,";
  string public notRevealedUri;
  uint256 public cost = 10 ether;
  uint256 public maxSupply = 2000;
  uint256 public maxMintAmount = 1;
  uint256 public nftPerAddressLimit = 3;
  uint256 public glitchCounter = 1;
  bool public paused = false;
  bool public revealed = false;
  bool public onlyWhitelisted = true;
  address[] public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;

  constructor(
    string memory _initNotRevealedUri,
    address[] memory _whitelist
  ) ERC721("raqNFT", "RAQ") {
    notRevealedUri = string(abi.encodePacked(baseURI, _initNotRevealedUri));
    whitelistedAddresses = _whitelist;
    console.log(notRevealedUri);
    console.log("Hello Raq! It is alive");
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // publica
  function mint(uint256 _mintAmount, bool isGlitch, string memory _base64) public payable {
    require(!paused, "the contract is paused");
    uint256 supply = _tokenIds.current();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");
    if (msg.sender != owner()) {
        if(onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        } else {
          require(msg.value >= cost * _mintAmount, "insufficient funds");
        }
    }
    addressMintedBalance[msg.sender]++;
    _safeMint(msg.sender, supply);
    _setTokenURI(supply, _base64);
    _tokenIds.increment();
    if (isGlitch) {
      glitchCounter++;
    }
  }

//   function makeAnEpicNFT(string memory _base64) public payable returns (string memory) {
//     return "this function is depricated: use mint(uint256 _mintAmount, string memory _base64)";
//     // require(!paused);
//     // if (msg.sender != owner()) {
//     //     require(msg.value >= cost);
//     // }
//     // uint256 newItemId = _tokenIds.current();
//     // _safeMint(msg.sender, newItemId);
//     // _setTokenURI(newItemId, string(abi.encodePacked(jsonBase, _base64)));
//     // _tokenIds.increment();
//  }
  function totalSupply() public view returns (uint256) {
    return maxSupply;
  }

  function totalCount() public view returns (uint256) {
    uint256 _val = uint256(_tokenIds._value);
    if (_val == 0) {
      return 0;
    }
    return _val - 1;
  }

  function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
        return true;
      }
    }
    return false;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require( _exists(tokenId), "ERC721Metadata: URI query for nonexistent token" );
    if(revealed == false) {
      return notRevealedUri;
    }
    string memory _tokenURI = super.tokenURI(tokenId); // equals to _tokenURIs[tokenId];
    return _tokenURI;
  }

  // public onlyOwner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }
  
  function whitelistUsers(address[] calldata _users) public onlyOwner {
    delete whitelistedAddresses;
    whitelistedAddresses = _users;
  }
  function setMaxSupply(uint256 _maxSupply) public onlyOwner {
    maxSupply = _maxSupply;
  }
 
  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}