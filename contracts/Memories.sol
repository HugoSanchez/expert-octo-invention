// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Meta.sol";


contract NFT is ERC721Meta {
    
    // Setting up counter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 
    
    // Owner 
    address _owner;
    
    // Moderators
    mapping(address => bool) _moderators;
    // Array with all moderators addresses
    address[] private _allModerators;
    
    // Members
    mapping(address => bool) _members;
    
     // Constructor
    constructor() ERC721("Metaverse Tokens", "METT") {
        _owner = msg.sender;
        _moderators[msg.sender] = true;
        _members[msg.sender] = true;
        _allModerators.push(msg.sender);
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
    
    // Get moderators.
    function getModerator(address _moderator) public view returns(bool) {
        return _moderators[_moderator];
    }
    
    // Get ALL moderators.
    function getAllModerators() public view returns(address[] memory) {
        return _allModerators;
    }
    
    // Adds contract moderators.
    function addModerator(address _newModeratorAddress) public OnlyOwner returns(bool) {
        require(_moderators[_newModeratorAddress] == false, "Moderator already exists");
        _moderators[_newModeratorAddress] = true;
        _allModerators.push(_newModeratorAddress);
       if (_members[_newModeratorAddress] = false) {
           _members[_newModeratorAddress] = true;}
        return true;
    }
    
    // Delete Moderator
    function deleteModerator(address _moderatorToBeDeleted) public OnlyOwner returns(bool) {
        require(_moderators[_moderatorToBeDeleted] == true, "Moderator does not exist");
        _removeModeratorFromArray(_moderatorToBeDeleted);
        delete _moderators[_moderatorToBeDeleted];
        return true;
    }
    
    
    //
    // MEMBERS section.
    // 
    
    // Get members.
    function getMember(address _member) public view returns(bool) {
        return _members[_member];
    }
    
    // Adds contract members.
    function addMember(address _newMemberAddress) public OnlyModerator returns(bool) {
        require(_members[_newMemberAddress] == false, "Member already exists");
        _moderators[_newMemberAddress] = true;
        return true;
    }
    
    // Delete members
    function deleteMember(address _memberToBeDeleted) public OnlyModerator returns(bool) {
        require(_members[_memberToBeDeleted] == true, "Moderator does not exist");
        delete _members[_memberToBeDeleted];
        return true;
    }
    
    
    //
    // HELPERS
    // 
    
    // Remove item from Array
    function _removeModeratorFromArray(address _moderatorToDelete) private {
        uint index;
        for (uint i = 0; i < _allModerators.length; i++) {
            index = i;
            address currentModerator = _allModerators[i];
            if (currentModerator == _moderatorToDelete) {
                // Move the last element into the place to delete
                _allModerators[index] = _allModerators[_allModerators.length - 1];
                // Remove the last element
                _allModerators.pop();
            }
        }
    }
    
    
    // Create token: only members can mint a new memory.
    function mintMemory(
    
        string memory name, 
        string memory description, 
        string memory contentUri
        
        ) public OnlyMembers returns (uint) {
            
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
    
            _mint(msg.sender, newItemId);
            _setTokenData(newItemId, name, description, contentUri);
            return newItemId;
    }
}