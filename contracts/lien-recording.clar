;; Lien Recording Contract
;; Tracks financial claims against properties

(define-constant contract-owner tx-sender)

(define-map liens
  { lien-id: uint }
  {
    property-id: uint,
    lien-holder: principal,
    amount: uint,
    filing-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var last-lien-id uint u0)

(define-read-only (get-lien (lien-id uint))
  (map-get? liens { lien-id: lien-id })
)

(define-public (record-lien (property-id uint) (amount uint))
  (let
    (
      (new-lien-id (+ (var-get last-lien-id) u1))
    )
    (var-set last-lien-id new-lien-id)
    (ok (map-set liens
      { lien-id: new-lien-id }
      {
        property-id: property-id,
        lien-holder: tx-sender,
        amount: amount,
        filing-date: block-height,
        status: "active"
      }
    ))
  )
)

(define-public (release-lien (lien-id uint))
  (let
    (
      (lien (unwrap! (get-lien lien-id) (err u404)))
    )
    (asserts! (is-eq (get lien-holder lien) tx-sender) (err u403))
    (ok (map-set liens
      { lien-id: lien-id }
      (merge lien { status: "released" })
    ))
  )
)

