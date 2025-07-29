// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title StoreMinimart - simple minimart contract
contract StoreMinimart {
    address public owner;

    struct Product {
        string name;
        uint256 price;  // in wei
        uint256 stock;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCount;

    event ProductAdded(uint256 productId, string name, uint256 price, uint256 stock);
    event ProductBought(address buyer, uint256 productId, uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(string memory _name, uint256 _price, uint256 _stock) public onlyOwner {
        require(_price > 0, "Price must be > 0");
        products[productCount] = Product(_name, _price, _stock);
        emit ProductAdded(productCount, _name, _price, _stock);
        productCount++;
    }

    function buyProduct(uint256 _productId, uint256 _quantity) public payable {
        Product storage product = products[_productId];
        require(product.stock >= _quantity, "Not enough stock");
        uint256 totalCost = product.price * _quantity;
        require(msg.value >= totalCost, "Not enough Ether sent");

        product.stock -= _quantity;

        // Refund any extra Ether
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit ProductBought(msg.sender, _productId, _quantity);
    }
}
