# StacksCommerce 🛒

**Next-Generation Decentralized Commerce Platform**

A comprehensive Bitcoin-native marketplace infrastructure built on Stacks that empowers merchants and consumers through trustless commerce, competitive auctions, and transparent reputation systems.

[![Stacks](https://img.shields.io/badge/Stacks-L2-purple)](https://stacks.co/)
[![Clarity](https://img.shields.io/badge/Language-Clarity-blue)](https://clarity-lang.org/)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-orange)](https://bitcoin.org/)

## 🌟 Overview

StacksCommerce revolutionizes digital commerce by leveraging Bitcoin's security through Stacks L2 to create an autonomous marketplace ecosystem. This smart contract establishes a foundation for peer-to-peer commerce where merchants can build verified brands, showcase products through direct sales or dynamic auctions, while consumers benefit from transparent pricing and community-driven reviews.

## 🚀 Key Features

### 🔐 **Bitcoin-Secured Transactions**

- Instant finality with Bitcoin's security guarantees
- STX-based payments with automatic fee distribution
- Escrow mechanisms for auction settlements

### 🏪 **Brand Verification System**

- Merchant identity registration and verification
- Trust-building through on-chain brand profiles
- Admin-controlled verification process

### 💰 **Dual Commerce Modes**

- **Direct Sales**: Immediate purchase with fixed pricing
- **Competitive Auctions**: Time-bound bidding with automatic escrow

### ⭐ **Decentralized Reputation**

- Community-driven product reviews (1-5 star rating)
- On-chain feedback system
- Transparent merchant and product ratings

### 🛡️ **Anti-Fraud Mechanisms**

- Automatic escrow for auction bids
- Previous bidder refunds in auction system
- Platform fee collection for sustainability

## 📋 Contract Architecture

### Core Data Structures

#### Brand Registry

```clarity
;; Merchant identity and verification status
(define-map Brands principal {
  name: (string-ascii 50),
  verified: bool,
  created-at: uint
})
```

#### Product Catalog

```clarity
;; Core product information and availability
(define-map Products uint {
  brand: principal,
  name: (string-ascii 100),
  description: (string-ascii 500),
  price: uint,
  available: bool,
  created-at: uint,
  is-auction: bool
})
```

#### Auction System

```clarity
;; Time-bound competitive bidding mechanism
(define-map Auctions uint {
  end-block: uint,
  min-price: uint,
  highest-bid: uint,
  highest-bidder: (optional principal),
  is-active: bool
})
```

#### Review System

```clarity
;; Community-driven reputation and feedback
(define-map Reviews {product-id: uint, reviewer: principal} {
  rating: uint,
  comment: (string-ascii 200),
  timestamp: uint
})
```

## 🔧 Core Functions

### Brand Management

- `register-brand`: Register a new merchant brand
- `verify-brand`: Admin function for brand verification

### Direct Sales

- `list-product`: Create product listing for immediate purchase
- `purchase-product`: Execute instant purchase with fee distribution

### Auction System

- `create-auction`: Launch time-bound competitive auction
- `place-bid`: Submit competitive bid with automatic escrow
- `end-auction`: Finalize auction with winner settlement

### Reputation System

- `add-review`: Submit product review and rating

### Data Access

- `get-product`: Retrieve product information
- `get-brand`: Retrieve brand information
- `get-auction`: Retrieve auction state
- `get-review`: Retrieve specific review
- `get-platform-fee`: Get current platform fee
- `get-product-count`: Get total products listed

## 💳 Fee Structure

- **Platform Fee**: 2.5% (25 basis points per 1000)
- Automatic fee distribution on all transactions
- Transparent fee collection for protocol sustainability

## 🏗️ Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development tool
- Node.js and npm (for testing)
- Stacks wallet for interaction

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/grace-ayomide/stacks-commerce
   cd stacks-commerce
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Project Structure

```
stacks-commerce/
├── contracts/
│   └── stacks-commerce.clar    # Main contract
├── tests/
│   └── stacks-commerce.test.ts # Test suite
├── settings/
│   ├── Devnet.toml
│   ├── Testnet.toml
│   └── Mainnet.toml
├── Clarinet.toml               # Project configuration
├── package.json
└── README.md
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Check contract syntax
clarinet check

# Run unit tests
npm test

# Run specific test file
npm test -- stacks-commerce.test.ts
```

## 🚀 Deployment

### Testnet Deployment

```bash
clarinet integrate
```

### Mainnet Deployment

1. Configure your deployment settings in `settings/Mainnet.toml`
2. Deploy using Clarinet or Stacks CLI
3. Verify contract deployment on [Stacks Explorer](https://explorer.stacks.co/)

## 📖 Usage Examples

### Register as a Merchant

```clarity
(contract-call? .stacks-commerce register-brand "My Store")
```

### List a Product

```clarity
(contract-call? .stacks-commerce list-product 
  "Premium Widget" 
  "High-quality widget with warranty" 
  u1000000) ;; 1 STX
```

### Create an Auction

```clarity
(contract-call? .stacks-commerce create-auction
  "Rare Collectible"
  "Limited edition collectible item"
  u500000   ;; 0.5 STX minimum
  u144)     ;; 144 blocks (~24 hours)
```

### Place a Bid

```clarity
(contract-call? .stacks-commerce place-bid u1 u750000) ;; 0.75 STX bid
```

### Purchase a Product

```clarity
(contract-call? .stacks-commerce purchase-product u1)
```

### Add a Review

```clarity
(contract-call? .stacks-commerce add-review 
  u1 
  u5 
  "Excellent product, fast delivery!")
```

## 🔒 Security Features

- **Input Validation**: All functions include comprehensive input validation
- **Access Control**: Brand verification restricted to contract owner
- **Error Handling**: Detailed error codes for debugging and user feedback
- **Escrow System**: Automatic bid escrow and refunds in auctions
- **Balance Checks**: STX balance verification before transactions

## 📊 Error Codes

| Code | Description |
|------|-------------|
| 100 | Unauthorized access |
| 101 | Invalid brand owner |
| 102 | Invalid pricing |
| 103 | Product not found |
| 104 | Insufficient balance |
| 105 | Auction expired |
| 106 | Bid too low |
| 107 | No active auction |
| 108 | Invalid duration |
| 109 | Invalid rating |
| 110 | Transfer failed |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Roadmap

- [ ] Multi-token support (SIP-010 tokens)
- [ ] Bulk operations for merchants
- [ ] Advanced search and filtering
- [ ] Dispute resolution mechanism
- [ ] Integration with external oracles
- [ ] Mobile-friendly dApp interface

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://book.clarity-lang.org/)
- [Stacks Explorer](https://explorer.stacks.co/)
- [Stacks Community](https://stacks.org/community)

---

**Built for the future of decentralized commerce on Bitcoin's most advanced layer** 🚀

*StacksCommerce - Empowering the next generation of Bitcoin-native commerce*
