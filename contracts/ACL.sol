// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Meta.sol";

contract ACL {
    // Owner
    address _owner;
    // Moderators
    mapping(address => bool) _moderators;
    // Members
    mapping(address => bool) _members;

    // READ logic type
    /**
    Type 1 - Open/Public; anyonce can read
    Type 2 - Members - Authorized members can read
    Type 3 - ERC 20 - ERC20 holders can read
    Type 4 - ERC721 - ERC721 holders can read 
     */
    uint256 readLogicType;

    // WRITE logic type
    /**
    Type 1 - Moderators - Only moderators can write 
    Type 2 - Members - Authorized members can write
    Type 3 - ERC 20 - ERC20 holders can write
    Type 4 - ERC721 - ERC721 holders can write 
     */
    uint256 writeLogicType;

    // Read/write smart contract address
    address smartContractAddress;
    // Read/write minum balance
    uint256 minimumBalance;

    // Constructor
    constructor(
        uint8 _readLogicType,
        uint8 _writeLogicType,
        address _smartContractAddress,
        uint256 _minimumBalance
    ) {
        _owner = msg.sender;
        _moderators[msg.sender] = true;
        _members[msg.sender] = true;

        readLogicType = _readLogicType;
        writeLogicType = _writeLogicType;
        smartContractAddress = _smartContractAddress;
        minimumBalance = _minimumBalance;
    }

    ////////////////////////////
    // MODIFIERS section.
    ////////////////////////////

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

    ////////////////////////////
    // MODERATORS section.
    ////////////////////////////

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

    ////////////////////////////
    // MEMBERS section.
    ////////////////////////////

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

    ////////////////////////////
    // READ / WRITE section.
    ////////////////////////////

    function checkReadPermission() public view returns (uint256 answer) {
        if (readLogicType == 1) return 1;
        else if (readLogicType == 2) {
            if (_members[msg.sender] == true) return 1;
            if (_members[msg.sender] == false) return 0;
        }
        // Todo: develop logic for ERC20 & ERC721
    }

    function checkWritePermission() public view returns (uint256 answer) {
        if (writeLogicType == 1) {
            if (_moderators[msg.sender] == true) return 1;
            if (_moderators[msg.sender] == true) return 0;
        } else if (readLogicType == 2) {
            if (_members[msg.sender] == true) return 1;
            if (_members[msg.sender] == false) return 0;
        }
        // Todo: develop logic for ERC20 & ERC721
    }
}
