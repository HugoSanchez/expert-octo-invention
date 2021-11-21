// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721Meta is ERC721 {
    using Strings for uint256;

    struct TokenDataStruct {
        string name;
        string description;
        string contentURI;
        uint256 timestamp;
        address creator;
    }

    // Optional mapping for token URIs
    mapping(uint256 => TokenDataStruct) private _tokensData;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenMetadataAndURI(uint256 tokenId)
        public
        view
        virtual
        returns (TokenDataStruct memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        TokenDataStruct memory _tokenData = _tokensData[tokenId];
        string memory base = _baseURI();

        // If there's base URI, return the baseURI + contentURI.
        if (bytes(base).length > 0) {
            _tokenData.contentURI = string(
                abi.encodePacked(base, _tokenData.contentURI)
            );
        }

        return _tokenData;
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenData(
        uint256 tokenId,
        string memory _name,
        string memory _description,
        string memory _contentURI,
        address _creator
    ) internal virtual {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );

        _tokensData[tokenId] = TokenDataStruct(
            _name,
            _description,
            _contentURI,
            block.timestamp,
            _creator
        );
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        delete _tokensData[tokenId];
    }
}
