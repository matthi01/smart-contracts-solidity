pragma solidity ^0.4.23;

contract ProductSales {
    
    // define structs
    struct Product {
        uint id;
        string name;
        uint inventory;
        uint price;
    }
    
    struct Buyer {
        string name;
        string email;
        string mailingAddress;
        uint totalOrders;
        bool isActive;
    }
    
    struct Order {
        uint orderId;
        uint productId;
        uint quantity;
        address buyer;
    }
    
    // define mappings
    mapping (uint => Product) public products;
    mapping (address => Buyer) public buyers;
    mapping (uint => Order) public orders;
    
    // define state variables
    address public owner;
    uint public numProducts;
    uint public numBuyers;
    uint public numOrders;
    
    // modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        } 
        _;
    }
    
    // functions
    constructor() public {
        owner = msg.sender;
        numProducts = 0;
        numBuyers = 0;
        numOrders = 0;
    }
    
    //add product
    function addProduct(uint id, string name, uint inventory, uint price) public onlyOwner {
        Product storage p = products[id];
        p.id = id;
        p.name = name;
        p.inventory = inventory;
        p.price = price;
        numProducts++;
    }
    
    // update product
    function updateProduct(uint id, string name, uint inventory, uint price) public onlyOwner {
        products[id].name = name;
        products[id].inventory = inventory;
        products[id].price = price;
    }
    
    // register a buyer
    function registerBuyer(string name, string email, string mailingAddress) public {
        Buyer storage b = buyers[msg.sender];
        b.name = name;
        b.email = email;
        b.mailingAddress = mailingAddress;
        b.isActive = true;
        b.totalOrders = 0;
        numBuyers++;
    }
    
    // buy product
    function buyProduct(uint id, uint quantity) public payable returns (uint newOrderId) {
        // check inventory
        if (products[id].inventory < quantity) {
            revert("Not enough inventory available");
        }
        
        // check payment amount
        if (msg.value < (products[id].price * quantity)) {
            revert();
        } 
        
        // check if buyer is registered
        if (buyers[msg.sender].isActive != true) {
            revert("Need to register as a buyer first");
        }
        
        // update order count for buyer
        buyers[msg.sender].totalOrders++;
        
        // gen new order id
        newOrderId = uint(msg.sender) + block.timestamp;
        
        // create order
        Order storage o = orders[newOrderId];
        o.orderId = newOrderId;
        o.productId = id;
        o.quantity = quantity;
        o.buyer = msg.sender;
        
        // update orders
        numOrders++;
        
        // update products
        products[id].inventory = products[id].inventory - quantity;
        
        // refund any balance if they overpaid
        if (msg.value > products[id].price * quantity) {
            uint refundAmount = products[id].price - msg.value;
            if (!msg.sender.send(refundAmount)) {
                revert("Refund of overpayment failed");
            }
        } 
    }
    
    // allow owner to withdraw funds
    function withdrawFunds() public onlyOwner {
        if (!owner.send(address(this).balance)) {
            revert("Fund transfer failed");
        }
    }
        
    // kill
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}