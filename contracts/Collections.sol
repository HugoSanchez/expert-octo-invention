// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Meta.sol";

contract Collections is ERC721Meta {
    // Setting up counter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Owner
    address _owner;
    // Moderators
    mapping(address => bool) _moderators;
    // Members
    mapping(address => bool) _members;

    // Constructor
    constructor(string memory _title, string memory _simbol)
        ERC721(_title, _simbol)
    {
        _owner = msg.sender;
        _moderators[msg.sender] = true;
        _members[msg.sender] = true;
    }

    //
    // MODIFIERS section.
    //

    // Owner
    modifier OnlyOwner() {
        require(msg.sender == _owner, "Only contract owner is allowed");
        _;
    }

    // Moderators
    modifier OnlyModerator() {
        require(_moderators[msg.sender] == true, "Only moderators allowed");
        _;
    }

    // Members
    modifier OnlyMembers() {
        require(_members[msg.sender] == true, "Only members allowed");
        _;
    }

    //
    // MODERATORS section.
    //

    function getOwner() public view returns (address) {
        return _owner;
    }

    // Get moderators.
    function getModerator(address _moderator) public view returns (bool) {
        return _moderators[_moderator];
    }

    // Adds contract moderators.
    // Also adds moderator as member.
    function addModerator(address _newModeratorAddress)
        public
        OnlyOwner
        returns (bool)
    {
        require(
            _moderators[_newModeratorAddress] == false,
            "Moderator already exists"
        );

        _moderators[_newModeratorAddress] = true;
        _members[_newModeratorAddress] = true;

        return true;
    }

    // Delete Moderator
    function deleteModerator(address _moderatorToBeDeleted)
        public
        OnlyOwner
        returns (bool)
    {
        require(
            _moderators[_moderatorToBeDeleted] == true,
            "Moderator does not exist"
        );
        delete _moderators[_moderatorToBeDeleted];
        delete _members[_moderatorToBeDeleted];
        return true;
    }

    //
    // MEMBERS section.
    //

    // Get members.
    function getMember(address _member) public view returns (bool) {
        return _members[_member];
    }

    // Adds contract members.
    function addMember(address _newMemberAddress)
        public
        OnlyModerator
        returns (bool)
    {
        require(_members[_newMemberAddress] == false, "Member already exists");
        _members[_newMemberAddress] = true;
        return true;
    }

    // Delete members
    function deleteMember(address _memberToBeDeleted)
        public
        OnlyModerator
        returns (bool)
    {
        require(
            _members[_memberToBeDeleted] == true,
            "Moderator does not exist"
        );
        delete _members[_memberToBeDeleted];
        return true;
    }

    //
    // Memories items section
    //

    // Create token: only members can mint a new memory.
    function mintMemory(
        string memory name,
        string memory description,
        string memory contentUri
    ) public OnlyMembers returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenData(newItemId, name, description, contentUri, msg.sender);
        return newItemId;
    }

    // Deletes an item from the collection
    function deleteMemory(uint256 tokenID) public OnlyModerator returns (bool) {
        _burn(tokenID);
        return true;
    }
}
