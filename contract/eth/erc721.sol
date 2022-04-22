// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract ZealotNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
  constructor() ERC721("Zealot", "ZL") {}

  event MintBatch(address indexed owner, address indexed to, uint256 sum);

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function safeMint(address to, uint256 tokenId, string memory uri) public onlyOwner whenNotPaused
  {
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
  }

  function batchMint(address to, uint256[] memory _tokenIds, string[] memory _uris)
  public onlyOwner whenNotPaused returns (bool)
  {
    require(_tokenIds.length > 0, "address length error");
    require(_tokenIds.length == _uris.length, "address and url length mismatching");

    uint256 sum;
    for(uint256 i = 0; i < _tokenIds.length; i++) {
      safeMint(to, _tokenIds[i],  _uris[i]);
      sum += _tokenIds[i];
    }
    emit MintBatch(msg.sender, address(to), sum);
    return true;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
  internal
  whenNotPaused
  override
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
  public
  view
  override(ERC721, ERC721URIStorage)
  returns (string memory)
  {
    return super.tokenURI(tokenId);
  }
}