;; Title: StacksCommerce - Next-Generation Decentralized Commerce Platform
;;
;; Summary: 
;; A comprehensive Bitcoin-native marketplace infrastructure built on Stacks that empowers merchants
;; and consumers through trustless commerce, competitive auctions, and transparent reputation systems.
;;
;; Description:
;; StacksCommerce revolutionizes digital commerce by leveraging Bitcoin's security through Stacks L2
;; to create an autonomous marketplace ecosystem. This smart contract establishes a foundation for
;; peer-to-peer commerce where merchants can build verified brands, showcase products through direct
;; sales or dynamic auctions, while consumers benefit from transparent pricing and community-driven
;; reviews. The platform ensures economic sovereignty through Bitcoin settlements while maintaining
;; the speed and programmability of Stacks smart contracts.
;;
;; Key Innovations:
;;  - Bitcoin-secured transactions with instant finality
;;  - Brand verification system for merchant trust
;;  - Dual-mode commerce: Direct sales & competitive auctions  
;;  - Decentralized reputation through on-chain reviews
;;  - Transparent fee structure with protocol sustainability
;;  - Anti-fraud mechanisms with escrow-like auction settlements
;;
;; Built for the future of decentralized commerce on Bitcoin's most advanced layer.
;;

;; PROTOCOL CONSTANTS & ERROR HANDLING

(define-constant CONTRACT_OWNER tx-sender)

;; Error codes with semantic meaning
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_BRAND_OWNER (err u101))
(define-constant ERR_INVALID_PRICING (err u102))
(define-constant ERR_PRODUCT_NOT_FOUND (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_AUCTION_EXPIRED (err u105))
(define-constant ERR_BID_TOO_LOW (err u106))
(define-constant ERR_NO_ACTIVE_AUCTION (err u107))
(define-constant ERR_INVALID_DURATION (err u108))
(define-constant ERR_INVALID_RATING (err u109))
(define-constant ERR_TRANSFER_FAILED (err u110))

;; PROTOCOL CONFIGURATION

;; Platform fee: 2.5% (25 basis points per 1000)
(define-data-var platform-fee uint u25)

;; Global product identifier counter
(define-data-var product-counter uint u0)

;; DATA STRUCTURES & STORAGE MAPS

;; Brand Registry: Merchant identity and verification status
(define-map Brands
  principal
  {
    name: (string-ascii 50),
    verified: bool,
    created-at: uint,
  }
)

;; Product Catalog: Core product information and availability
(define-map Products
  uint
  {
    brand: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    price: uint,
    available: bool,
    created-at: uint,
    is-auction: bool,
  }
)

;; Auction State: Time-bound competitive bidding mechanism
(define-map Auctions
  uint
  {
    end-block: uint,
    min-price: uint,
    highest-bid: uint,
    highest-bidder: (optional principal),
    is-active: bool,
  }
)

;; Review System: Community-driven reputation and feedback
(define-map Reviews
  {
    product-id: uint,
    reviewer: principal,
  }
  {
    rating: uint,
    comment: (string-ascii 200),
    timestamp: uint,
  }
)