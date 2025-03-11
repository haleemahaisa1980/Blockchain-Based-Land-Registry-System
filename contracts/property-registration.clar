;; Property Registration Contract
;; Records land ownership and boundaries

(define-constant contract-owner tx-sender)

(define-map properties
  { property-id: uint }
  {
    owner: principal,
    boundaries: (string-ascii 256),
    registration-date: uint,
    last-updated: uint
  }
)

(define-data-var last-property-id uint u0)

(define-read-only (get-property (property-id uint))
  (map-get? properties { property-id: property-id })
)

(define-public (register-property (boundaries (string-ascii 256)))
  (let
    (
      (new-property-id (+ (var-get last-property-id) u1))
    )
    (var-set last-property-id new-property-id)
    (ok (map-set properties
      { property-id: new-property-id }
      {
        owner: tx-sender,
        boundaries: boundaries,
        registration-date: block-height,
        last-updated: block-height
      }
    ))
  )
)

(define-public (update-property-boundaries (property-id uint) (new-boundaries (string-ascii 256)))
  (let
    (
      (property (unwrap! (get-property property-id) (err u404)))
    )
    (asserts! (is-eq (get owner property) tx-sender) (err u403))
    (ok (map-set properties
      { property-id: property-id }
      (merge property
        {
          boundaries: new-boundaries,
          last-updated: block-height
        }
      )
    ))
  )
)

