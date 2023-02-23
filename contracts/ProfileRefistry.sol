// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./Collections.sol";
import "hardhat/console.sol";

// import "./StringToLower.sol";

contract Registry {
    uint256 counter = 0;

    // Mapping profile ID to wallet address
    mapping(address => uint256) addressToProfileID;
    // Mapping handle to profile ID.
    mapping(bytes32 => uint256) handleOwnershipById;
    // Mapping address to ID to profile details
    mapping(uint256 => Profile) idToProfileDetails;

    struct Profile {
        string handle;
        string metadataURI;
        address[] collections;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }

    function getProfileByID(uint256 _id) public view returns (Profile memory) {
        return idToProfileDetails[_id];
    }

    function getIdFromAddress(address _address) public view returns (uint256) {
        return addressToProfileID[_address];
    }

    function registerProfile(
        string calldata _handle,
        string calldata _metadataURI
    ) public {
        bytes32 handleHash = keccak256(bytes(_toLower(_handle)));
        require(
            addressToProfileID[msg.sender] == 0,
            "This address already has a profile."
        );
        require(handleOwnershipById[handleHash] == 0, "Handle already taken");

        counter++;
        addressToProfileID[msg.sender] = counter;
        handleOwnershipById[handleHash] = counter;
        idToProfileDetails[counter].handle = _handle;
        idToProfileDetails[counter].metadataURI = _metadataURI;
    }

    function updateProfileMetadata(
        uint256 _profileId,
        string calldata _metadataURI
    ) public {
        require(
            addressToProfileID[msg.sender] == _profileId,
            "Can't change someone else's collections"
        );
        idToProfileDetails[_profileId].metadataURI = _metadataURI;
    }

    function addCollection(uint256 _profileId, address _collectionAddress)
        public
    {
        require(
            addressToProfileID[msg.sender] == _profileId,
            "Can't change someone else's collections"
        );
        Collections collections = Collections(_collectionAddress);
        // collection.checkFollowPermission(msg.sender);
        idToProfileDetails[_profileId].collections.push(_collectionAddress);
    }

    function removeCollection(uint256 _profileId, uint256 _index) public {
        address[] storage array = idToProfileDetails[_profileId].collections;
        require(_index < array.length, "index out of bound");

        for (uint256 i = _index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    // Turns any string to lower case
    // Borrowed from: https://gist.github.com/ottodevs/c43d0a8b4b891ac2da675f825b1d1dbf
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}

//
// 1. I can create a handle
// 2. I cannot register a profile if it already exists
// 3. I cannot add a collection if I'm not the profile owner
// 4. I cannot add a collection if collection doesn't allow
// 5. I can add a collection if I'm profile owner && collection alows
//
