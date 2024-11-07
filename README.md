# TokenLottery Contract

## Overview

This contract is a lottery system where users can buy tokens, use those tokens to purchase lottery tickets, and participate in a lottery with a random winner. The winner receives 95% of the balance from the contract, while the owner receives 5%.

### Key Features:
- **ERC-20 Token** for ticket purchases and transactions.
- **ERC-721 NFT** tickets that represent entries in the lottery.
- **User Registration** for participation.
- **Lottery Mechanism** to select a random winner.

## Contracts

### 1. Lottery Contract

This is the main contract for the lottery. It is based on the ERC-20 token and manages the purchase of tokens, registration of users, buying of lottery tickets, and selecting the winner.

#### Functions:

- **constructor**: Initializes the token and the NFT contract address.
- **tokenPrice**: Returns the price for a specific number of ERC-20 tokens.
- **tokenBalance**: Returns the ERC-20 token balance of a specific address.
- **contractTokenBalance**: Returns the ERC-20 token balance of the smart contract.
- **contractEtherBalance**: Returns the ether balance of the smart contract.
- **mint**: Mints new ERC-20 tokens to the contract.
- **register**: Registers a user by creating a unique NFT contract.
- **buyTokens**: Allows users to buy ERC-20 tokens by sending Ether.
- **returnTokens**: Allows users to return ERC-20 tokens and receive the equivalent in Ether.
- **buyTicket**: Allows users to purchase lottery tickets using ERC-20 tokens.
- **viewTickets**: Returns a list of tickets for a specific user.
- **generateWinner**: Determines the lottery winner and transfers the prize.

### 2. MainERC721 Contract

This contract is an ERC-721 contract that mints NFTs representing lottery tickets. It is used by the `Lottery` contract to issue tickets to users.

#### Functions:

- **constructor**: Initializes the NFT contract and associates it with the lottery contract.
- **safeMint**: Mints a new ticket NFT for a user with a specific ticket number.

### 3. TicketNFTs Contract

This is a child contract that helps mint tickets by interacting with the `MainERC721` contract. It allows the lottery system to manage ticket NFTs per user.

#### Functions:

- **constructor**: Initializes the ticket contract with necessary addresses.
- **mintTicket**: Mints a ticket for the user based on the ticket number.

## How to Use

1. **Deploy the Lottery Contract**:
   Deploy the `Lottery` contract to the blockchain. This will automatically deploy a new instance of the `MainERC721` contract for ticket NFTs.

2. **Buy Tokens**:
   Users can purchase ERC-20 tokens using Ether. Call the `buyTokens` function to buy tokens.

3. **Register for the Lottery**:
   Users are automatically registered when they buy tokens for the first time. A personal contract is created for each user with the address of the NFT contract.

4. **Buy Lottery Tickets**:
   Users can use their ERC-20 tokens to buy lottery tickets. Each ticket is represented by an NFT.

5. **Generate Winner**:
   Once enough tickets have been sold, the lottery owner can call the `generateWinner` function to randomly select a winner and transfer the prize.

## Example Workflow

1. Deploy the `Lottery` contract.
2. Users buy ERC-20 tokens using the `buyTokens` function.
3. Users purchase lottery tickets using the `buyTicket` function.
4. Once the lottery is ready, the owner calls `generateWinner` to select and reward the winner.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Dependencies

- [OpenZeppelin Contracts v4.5.0](https://github.com/OpenZeppelin/openzeppelin-contracts)
  - ERC20
  - Ownable
  - ERC721

## Notes

- The lottery is only for demonstration purposes. Ensure proper testing and audits before using in production.
- The contract assumes a fixed ticket price and does not account for dynamic ticket pricing or refunds in case of overpayment beyond the required token price.
