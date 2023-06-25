// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract GroceryShop {
    address public owner;
    uint256 public purchaseId; // id counter

    struct Grocery {
        string name;
        uint256 numberOfItems;
    }
    enum GroceryType {
        Milk,
        Bread,
        Egg
    }

    struct PurchaseDetail {
        address buyer;
        GroceryType itemType;
        uint256 numberOfTimesBought;
    }

    mapping(GroceryType => Grocery) public groceryItem;
    mapping(uint256 => PurchaseDetail) public purchaseReceipt;

    constructor() {
        owner = msg.sender;
        groceryItem[GroceryType.Bread] = Grocery("Roti", 10);
        groceryItem[GroceryType.Milk] = Grocery("Susu", 10);
        groceryItem[GroceryType.Egg] = Grocery("Telur", 10);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call the function");
        _;
    }

    modifier numberChecking(uint256 number) {
        require(number > 0, "Must be at least 1");
        _;
    }

    function add(
        GroceryType _groceryType,
        uint256 _numberAdded
    ) public onlyOwner numberChecking(_numberAdded) {
        groceryItem[_groceryType].numberOfItems += _numberAdded;
    }

    function buy(
        GroceryType _groceryType,
        uint256 _numberToBuy
    ) public payable numberChecking(_numberToBuy) {
        require(
            groceryItem[_groceryType].numberOfItems >= _numberToBuy,
            "Insufficient stock"
        );

        uint256 total = _numberToBuy * (0.001 ether);
        require(msg.value >= total, "Invalid amount");

        // purchaseId++;
        purchaseId = purchaseId + 1;

        groceryItem[_groceryType].numberOfItems -= _numberToBuy;

        purchaseReceipt[purchaseId] = PurchaseDetail(
            msg.sender,
            _groceryType,
            _numberToBuy
        );
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Failed to withdraw balance");
    }

    function viewReceipt(
        uint256 _purchaseId
    ) public view returns (address, GroceryType, uint256) {
        return (
            purchaseReceipt[_purchaseId].buyer,
            purchaseReceipt[_purchaseId].itemType,
            purchaseReceipt[_purchaseId].numberOfTimesBought
        );
    }

    // function testing(int32 number) public pure returns (string memory) {
    //     if (number > 0) {
    //         return "Greater than zero";
    //     } else {
    //         return "Less than zero";
    //     }
    // }
}
