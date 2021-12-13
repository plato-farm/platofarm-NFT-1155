// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract TypeOfNft is Ownable {

    using SafeMath for uint256;

    uint256 public constant itemMax = 100;    // for calculate the itemId
    uint256 public constant itemMaxSupply = 1000000000;     // total supply limit for per item
    
    uint256 public totalMinted;     // total minted limit for all item

    mapping(uint256 => bool) public typeActive;     // on/off the type of mint
    mapping(uint256 => uint256) public typeAmount;  // view the items of type
    mapping(uint256 => uint256) public typeMinted;  // total minted limit for per type
    mapping(uint256 => mapping(uint256 => uint256)) public itemSupply;  // currently, total minted limit for per item
    
    function getTypeInfo(uint256 _types) public view returns(bool, uint256, uint256) {
        return (typeActive[_types], typeAmount[_types], typeMinted[_types]);
    }

    function getItemSupply(uint256 _types, uint256 _items) public view returns(uint256) {
        return itemSupply[_types][_items];
    }

    function addTypeItem(uint256 _types, uint256 _items) public onlyOwner {
        require(!typeActive[_types], "type existed");
        require(_types > 0, "types cannot equivalent to 0");
        require(_items > 0 && _items < 100, "error items");
 
        typeAmount[_types] = _items;
        typeActive[_types] = true;
    }

    function updateType(uint256 _types, uint256 _items) public onlyOwner {
        require(typeActive[_types], "type not exist");
        require(_items > 0 && _items < 100, "error items");
 
        typeAmount[_types] = _items;
        typeActive[_types] = true;
    }

    function pauseType(uint256 _types) public onlyOwner {
        require(typeActive[_types], "type not exist");
        typeActive[_types] = false;
    }

    function unpauseType(uint256 _types) public onlyOwner {
        require(!typeActive[_types], "type has exist");
        typeActive[_types] = true;
    }

    function _itemCounter(uint256 tokenType, uint256 tokenItem, uint256 amount) internal {

        itemSupply[tokenType][tokenItem] = itemSupply[tokenType][tokenItem].add(amount);
        typeMinted[tokenType] = typeMinted[tokenType].add(amount);
        totalMinted = totalMinted.add(amount);
    }

}
