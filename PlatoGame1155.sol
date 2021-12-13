// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC1155Supply.sol";
import "./MinterRole.sol";
import "./TypeOfNft.sol";

contract PlatoGame1155 is ERC1155Supply, TypeOfNft, MinterRole {

    using SafeMath for uint256;
    
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol, string memory _tokenURI) ERC1155Supply(_tokenURI) {
        name = _name;
        symbol = _symbol;
    }

    /**
     * @dev set tokenURI.
     * Requirements: - the caller must have the `owner`.
     */
    function setURI(string memory _tokenURI) public onlyOwner {
        _setURI(_tokenURI);
    }

    /**
     * @dev Mint NFTs. Only the  minter can call it.
     */
    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyMinter {
        uint256 tokenType = tokenId.div(itemMax);
        uint256 tokenItem = tokenId.mod(itemMax);
        require(typeActive[tokenType], "mint: token type not exist");
        require(tokenItem < typeAmount[tokenType], "mint: token item not exist");
        require(itemSupply[tokenType][tokenItem].add(amount) <= itemMaxSupply, "mint: mint exceeds the maximum limit of item");

        if (isLimitMinter(_msgSender())) {
            (, uint256 limitAmount) = getLimitMinter(_msgSender());
            require(
                getMinterTotalMint(_msgSender()).add(amount) <= limitAmount,
                "mint: limit account's minting exceeds the allowable amount"
            );
        }

        if (tokenType != 1) {
            require(
                tokenItem != 0,
                "mint: except for land, the mantissa of the remaining numbers of tokenId starts from 1"
            );
        }
        _mint(to, tokenId, amount, data);
        _itemCounter(tokenType, tokenItem, amount);
        minterTotalMint[_msgSender()].add(amount);
    }

    /**
     * @dev Mint NFTs. Only the minter can call it.
     */
    function batchMint(address to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public onlyMinter {
         (bool PASS, uint256 totalAmount, string memory ERROR) = batchMintCheck(tokenIds, amounts);
        //  if (!PASS) {
        //      revert(ERROR);
        //  }
         require(PASS, ERROR);
         
        _mintBatch(to, tokenIds, amounts, data);
        
        minterTotalMint[_msgSender()].add(totalAmount);
    }

    /**
     * @dev Mint NFTs. Only the  minter can call it.
     */
    function batchMintCheck(uint256[] memory tokenIds, uint256[] memory amounts) internal returns(bool, uint256, string memory) {
        
        require(
            tokenIds.length == amounts.length,
            "mintBatchCheck: The parameters do not match"
        );

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            
            uint256 tokenType = tokenIds[i].div(itemMax);
            if (!typeActive[tokenType]) {
                return (false, 0, "mintBatchCheck: token type not exist");
            }

            uint256 tokenItem = tokenIds[i].mod(itemMax);
            if (tokenItem > typeAmount[tokenType]) {
                return (false, 0, "mintBatchCheck: token item not exist");
            }
            if (tokenType != 1 && tokenItem == 0) {
                return (false, 0, "mintBatchCheck: except for land, the mantissa of the remaining numbers of tokenId starts from 1");
            }

            totalAmount = totalAmount.add(amounts[i]);
            if (isLimitMinter(_msgSender())) {
                (, uint256 limitAmount) = getLimitMinter(_msgSender());
                if (getMinterTotalMint(_msgSender()).add(amounts[i]) > limitAmount) {
                    return (false, 0, "mintBatchCheck: limit account's minting exceeds the allowable amount");
                }
            }

            itemSupply[tokenType][tokenItem] = itemSupply[tokenType][tokenItem].add(amounts[i]);
            if (itemSupply[tokenType][tokenItem].add(amounts[i]) > itemMaxSupply) {
                return (false, 0, "mintBatchCheck: mint exceeds the maximum limit of item");
            }
            
            _itemCounter(tokenType, tokenItem, amounts[i]);
        }
        return (true, totalAmount, "");
    }

    function burn(address account, uint256 id, uint256 amount) public {
        _burn(account, id, amount);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {
        _burnBatch(account, ids, amounts);
    }
}

