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

;; BRAND MANAGEMENT SYSTEM

;; Register a new merchant brand in the marketplace
(define-public (register-brand (name (string-ascii 50)))
  (let ((brand-profile {
      name: name,
      verified: false,
      created-at: stacks-block-height,
    }))
    (ok (map-set Brands tx-sender brand-profile))
  )
)

;; Protocol-level brand verification (admin function)
(define-public (verify-brand (brand principal))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (let ((existing-brand (unwrap! (map-get? Brands brand) ERR_INVALID_BRAND_OWNER)))
      (ok (map-set Brands brand (merge existing-brand { verified: true })))
    )
    ERR_UNAUTHORIZED
  )
)

;; DIRECT SALES COMMERCE ENGINE

;; Create a new product listing for immediate purchase
(define-public (list-product
    (name (string-ascii 100))
    (description (string-ascii 500))
    (price uint)
  )
  (let (
      (brand-check (unwrap! (map-get? Brands tx-sender) ERR_INVALID_BRAND_OWNER))
      (product-id (+ (var-get product-counter) u1))
    )
    (if (> price u0)
      (begin
        (var-set product-counter product-id)
        (ok (map-set Products product-id {
          brand: tx-sender,
          name: name,
          description: description,
          price: price,
          available: true,
          created-at: stacks-block-height,
          is-auction: false,
        }))
      )
      ERR_INVALID_PRICING
    )
  )
)

;; Execute instant purchase with automatic fee distribution
(define-public (purchase-product (product-id uint))
  (let (
      (product (unwrap! (map-get? Products product-id) ERR_PRODUCT_NOT_FOUND))
      (total-price (get price product))
      (merchant (get brand product))
      (platform-fee-amount (/ (* total-price (var-get platform-fee)) u1000))
    )
    (if (and
        (get available product)
        (not (get is-auction product))
        (>= (stx-get-balance tx-sender) total-price)
      )

      (let (
          (fee-payment (stx-transfer? platform-fee-amount tx-sender CONTRACT_OWNER))
          (merchant-payment (stx-transfer? (- total-price platform-fee-amount) tx-sender merchant))
        )
        (if (and (is-ok fee-payment) (is-ok merchant-payment))
          (ok (map-set Products product-id (merge product { available: false })))
          ERR_TRANSFER_FAILED
        )
      )
      ERR_INSUFFICIENT_BALANCE
    )
  )
)

;; COMPETITIVE AUCTION SYSTEM

;; Launch a time-bound auction for competitive bidding
(define-public (create-auction
    (name (string-ascii 100))
    (description (string-ascii 500))
    (min-price uint)
    (duration uint)
  )
  (let (
      (brand-verification (unwrap! (map-get? Brands tx-sender) ERR_INVALID_BRAND_OWNER))
      (product-id (+ (var-get product-counter) u1))
      (auction-end (+ stacks-block-height duration))
    )
    (if (and (>= duration u10) (> min-price u0))
      (begin
        (var-set product-counter product-id)
        (map-set Products product-id {
          brand: tx-sender,
          name: name,
          description: description,
          price: min-price,
          available: true,
          created-at: stacks-block-height,
          is-auction: true,
        })
        (ok (map-set Auctions product-id {
          end-block: auction-end,
          min-price: min-price,
          highest-bid: u0,
          highest-bidder: none,
          is-active: true,
        }))
      )
      (if (< duration u10)
        ERR_INVALID_DURATION
        ERR_INVALID_PRICING
      )
    )
  )
)

;; Submit competitive bid with automatic escrow
(define-public (place-bid
    (product-id uint)
    (bid-amount uint)
  )
  (let (
      (product (unwrap! (map-get? Products product-id) ERR_PRODUCT_NOT_FOUND))
      (auction (unwrap! (map-get? Auctions product-id) ERR_NO_ACTIVE_AUCTION))
    )
    (if (and
        (get is-active auction)
        (<= stacks-block-height (get end-block auction))
        (>= bid-amount (get min-price auction))
        (> bid-amount (get highest-bid auction))
        (>= (stx-get-balance tx-sender) bid-amount)
      )

      (let (
          (refund-previous (match (get highest-bidder auction)
            previous-bidder (stx-transfer? (get highest-bid auction) CONTRACT_OWNER
              previous-bidder
            )
            (ok true)
          ))
          (escrow-bid (stx-transfer? bid-amount tx-sender CONTRACT_OWNER))
        )
        (if (and (is-ok refund-previous) (is-ok escrow-bid))
          (ok (map-set Auctions product-id
            (merge auction {
              highest-bid: bid-amount,
              highest-bidder: (some tx-sender),
            })
          ))
          ERR_TRANSFER_FAILED
        )
      )

      ;; Error handling with proper precedence
      (if (not (get is-active auction))
        ERR_AUCTION_EXPIRED
        (if (> stacks-block-height (get end-block auction))
          ERR_AUCTION_EXPIRED
          (if (< bid-amount (get min-price auction))
            ERR_BID_TOO_LOW
            (if (<= bid-amount (get highest-bid auction))
              ERR_BID_TOO_LOW
              ERR_INSUFFICIENT_BALANCE
            )
          )
        )
      )
    )
  )
)

;; Finalize auction with winner settlement
(define-public (end-auction (product-id uint))
  (let (
      (product (unwrap! (map-get? Products product-id) ERR_PRODUCT_NOT_FOUND))
      (auction (unwrap! (map-get? Auctions product-id) ERR_NO_ACTIVE_AUCTION))
      (merchant (get brand product))
    )
    (if (and
        (get is-active auction)
        (>= stacks-block-height (get end-block auction))
      )

      (match (get highest-bidder auction)
        winner (let (
            (winning-bid (get highest-bid auction))
            (platform-fee-amount (/ (* winning-bid (var-get platform-fee)) u1000))
            (fee-collection (stx-transfer? platform-fee-amount CONTRACT_OWNER CONTRACT_OWNER))
            (merchant-settlement (stx-transfer? (- winning-bid platform-fee-amount) CONTRACT_OWNER
              merchant
            ))
          )
          (if (and (is-ok fee-collection) (is-ok merchant-settlement))
            (begin
              (map-set Products product-id (merge product { available: false }))
              (ok (map-set Auctions product-id (merge auction { is-active: false })))
            )
            ERR_TRANSFER_FAILED
          )
        )
        ERR_NO_ACTIVE_AUCTION
      )

      (if (not (get is-active auction))
        ERR_AUCTION_EXPIRED
        ERR_AUCTION_EXPIRED
      )
    )
  )
)

;; COMMUNITY REPUTATION SYSTEM

;; Submit product review and rating
(define-public (add-review
    (product-id uint)
    (rating uint)
    (comment (string-ascii 200))
  )
  (let ((product-validation (unwrap! (map-get? Products product-id) ERR_PRODUCT_NOT_FOUND)))
    (if (<= rating u5)
      (ok (map-set Reviews {
        product-id: product-id,
        reviewer: tx-sender,
      } {
        rating: rating,
        comment: comment,
        timestamp: stacks-block-height,
      }))
      ERR_INVALID_RATING
    )
  )
)

;; PUBLIC DATA ACCESS INTERFACE

;; Retrieve product information
(define-read-only (get-product (product-id uint))
  (ok (map-get? Products product-id))
)

;; Retrieve brand information
(define-read-only (get-brand (brand principal))
  (ok (map-get? Brands brand))
)

;; Retrieve specific review
(define-read-only (get-review
    (product-id uint)
    (reviewer principal)
  )
  (ok (map-get? Reviews {
    product-id: product-id,
    reviewer: reviewer,
  }))
)

;; Retrieve auction state
(define-read-only (get-auction (product-id uint))
  (ok (map-get? Auctions product-id))
)

;; Get current platform fee
(define-read-only (get-platform-fee)
  (ok (var-get platform-fee))
)

;; Get total products listed
(define-read-only (get-product-count)
  (ok (var-get product-counter))
)
