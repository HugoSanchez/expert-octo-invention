// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Meta.sol";
import "./ACL.sol";

contract Collections is ERC721URIStorage {
    // Setting up counter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // ACL address
    ACL public _acl;

    // Constructor: deploys ACL contract
    constructor(
        uint8 readType,
        uint8 writeType,
        address smartContractAddress,
        uint256 minumBalance
    ) ERC721("Something", "SSS") {
        _acl = new ACL(readType, writeType, smartContractAddress, minumBalance);
    }

    ////////////////////////////
    // Minting new items section
    ////////////////////////////

    // Error when no msg-sender has no permissions
    error noWritePermission(address writer, uint256 response);
    error sorrySomethingWentWrong(address writer, uint256 response);

    // mintMemory: only members can mint a new memory.
    function mintNewItem(string memory contentUri)
        public
        returns (uint256 tokenID)
    {
        uint256 permission = _acl.checkWritePermission();
        if (permission == 0) revert noWritePermission(msg.sender, permission);
        else if (permission == 1) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, contentUri);
            return newItemId;
        }
    }

    // Deletes an item from the collection
    function deleteMemory(uint256 tokenID) public returns (bool) {
        _burn(tokenID);
        return true;
    }
}
