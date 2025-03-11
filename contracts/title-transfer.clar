;; Title Transfer Contract
;; Manages changes in property ownership

(define-constant contract-owner tx-sender)

(define-map title-transfers
  { transfer-id: uint }
  {
    property-id: uint,
    from: principal,
    to: principal,
    transfer-date: uint
  }
)

(define-data-var last-transfer-id uint u0)

(define-read-only (get-transfer (transfer-id uint))
  (map-get? title-transfers { transfer-id: transfer-id })
)

(define-public (transfer-title (property-id uint) (new-owner principal))
  (let
    (
      (property (unwrap! (contract-call? .property-registration get-property property-id) (err u404)))
      (new-transfer-id (+ (var-get last-transfer-id) u1))
    )
    (asserts! (is-eq (get owner property) tx-sender) (err u403))
    (var-set last-transfer-id new-transfer-id)
    (try! (contract-call? .property-registration update-property-owner property-id new-owner))
    (ok (map-set title-transfers
      { transfer-id: new-transfer-id }
      {
        property-id: property-id,
        from: tx-sender,
        to: new-owner,
        transfer-date: block-height
      }
    ))
  )
)

