// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";

contract Lottery is ERC20, Ownable {

    // Address of the NFT contract for the Project
    address public nft;

    constructor() ERC20("Lottery", "RFR") {
        _mint(address(this), 1000);
        nft = address(new MainERC721());
    }

    // Lottery prize winner
    address public winner;

    // User registration
    mapping(address => address) public user_contract;

    // ERC-20 token price
    function tokenPrice(uint256 _numTokens) internal pure returns (uint256) {
        return _numTokens * (1 ether);
    }

    // View the ERC-20 token balance of a user
    function tokenBalance(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    // View the ERC-20 token balance of the Smart Contract
    function contractTokenBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    // View the ether balance of the Smart Contract
    function contractEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Generate new ERC-20 tokens
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // User registration
    function register() internal {
        address personalContractAddress = address(new TicketNFTs(msg.sender, address(this), nft));
        user_contract[msg.sender] = personalContractAddress;
    }

    // User information
    function userInfo(address _account) public view returns (address) {
        return user_contract[_account];
    }

    // Purchase of ERC-20 tokens
    function buyTokens(uint256 _numTokens) public payable {
        // Register the user if they are not already registered
        if (user_contract[msg.sender] == address(0)) {
            register();
        }

        // Calculate the cost of the tokens to buy
        uint256 cost = tokenPrice(_numTokens);
        require(msg.value >= cost, "Buy more tokens or pay with more ether");

        // Check if enough tokens are available in the contract
        uint256 balance = contractTokenBalance();
        require(_numTokens <= balance, "Buy an appropriate number of tokens");

        // Return any excess ether
        uint256 returnValue = msg.value - cost;
        if (returnValue > 0) {
            payable(msg.sender).transfer(returnValue);
        }

        // Transfer tokens to the user
        _transfer(address(this), msg.sender, _numTokens);
    }

    // Return tokens to the Smart Contract
    function returnTokens(uint _numTokens) public payable {
        require(_numTokens > 0, "Must return more than 0 tokens");
        require(_numTokens <= tokenBalance(msg.sender), "Insufficient tokens to return");

        // Transfer tokens from the user to the contract
        _transfer(msg.sender, address(this), _numTokens);
        
        // Pay the equivalent ether price of the returned tokens
        payable(msg.sender).transfer(tokenPrice(_numTokens));
    }

    // Lottery ticket price (in ERC-20 tokens)
    uint public ticketPrice = 5;

    // User-to-ticket mapping
    mapping(address => uint[]) userTickets;

    // Ticket-to-winner mapping
    mapping(uint => address) ticketOwner;

    // Random number for tickets
    uint randNonce = 0;

    // Purchased lottery tickets
    uint[] purchasedTickets;

    // Buy lottery tickets
    function buyTicket(uint _numTickets) public {
        // Total ticket price
        uint totalPrice = _numTickets * ticketPrice;
        require(totalPrice <= tokenBalance(msg.sender), "Insufficient tokens");

        // Transfer tokens from the user to the contract
        _transfer(msg.sender, address(this), totalPrice);

        // Generate tickets
        for (uint i = 0; i < _numTickets; i++) {
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
            randNonce++;

            // Store ticket data and assign ownership
            userTickets[msg.sender].push(random);
            purchasedTickets.push(random);
            ticketOwner[random] = msg.sender;

            // Mint a new NFT for the ticket number
            TicketNFTs(user_contract[msg.sender]).mintTicket(msg.sender, random);
        }
    }

    // View a user's tickets
    function viewTickets(address _owner) public view returns (uint[] memory) {
        return userTickets[_owner];
    }

    // Generate the lottery winner
    function generateWinner() public onlyOwner {
        // Determine the length of the array
        uint length = purchasedTickets.length;
        // Ensure at least one ticket was purchased
        require(length > 0, "No tickets purchased");
        // Select a random number between: [0-length]
        uint random = uint(keccak256(abi.encodePacked(block.timestamp))) % length;
        // Select the random number
        uint selection = purchasedTickets[random];
        // Lottery winner's address
        winner = ticketOwner[selection];
        // Transfer 95% of the lottery prize to the winner
        payable(winner).transfer(address(this).balance * 95 / 100);
        // Transfer 5% of the lottery prize to the owner
        payable(owner()).transfer(address(this).balance * 5 / 100);
    }
    
}

// NFT Smart Contract
contract MainERC721 is ERC721 {

    address public lotteryAddress;

    constructor() ERC721("Lottery", "RF") {
        lotteryAddress = msg.sender;
    }

    // NFT minting
    function safeMint(address _owner, uint256 _ticket) public {
        require(msg.sender == Lottery(lotteryAddress).userInfo(_owner), "Not authorized to mint this NFT");
        _safeMint(_owner, _ticket);
    }
}

contract TicketNFTs {

    // Owner's relevant data
    struct Owner {
        address ownerAddress;
        address parentContract;
        address nftContract;
        address userContract;
    }

    Owner public owner;

    // Smart Contract (child) constructor
    constructor(address _owner, address _parentContract, address _nftContract) {
        owner = Owner(_owner, _parentContract, _nftContract, address(this));
    }

    // Lottery ticket number conversion
    function mintTicket(address _owner, uint _ticket) public {
        require(msg.sender == owner.parentContract, "Not authorized to execute this function");
        MainERC721(owner.nftContract).safeMint(_owner, _ticket);
    }
}
