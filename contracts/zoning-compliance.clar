;; Zoning Compliance Contract
;; Ensures adherence to local land use regulations

(define-constant contract-owner tx-sender)

(define-map zoning-rules
  { zone-id: uint }
  {
    zone-type: (string-ascii 50),
    allowed-uses: (list 10 (string-ascii 50)),
    max-height: uint,
    max-lot-coverage: uint
  }
)

(define-map property-zoning
  { property-id: uint }
  { zone-id: uint }
)

(define-data-var last-zone-id uint u0)

(define-read-only (get-zoning-rule (zone-id uint))
  (map-get? zoning-rules { zone-id: zone-id })
)

(define-read-only (get-property-zone (property-id uint))
  (map-get? property-zoning { property-id: property-id })
)

(define-public (create-zoning-rule (zone-type (string-ascii 50)) (allowed-uses (list 10 (string-ascii 50))) (max-height uint) (max-lot-coverage uint))
  (let
    (
      (new-zone-id (+ (var-get last-zone-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set last-zone-id new-zone-id)
    (ok (map-set zoning-rules
      { zone-id: new-zone-id }
      {
        zone-type: zone-type,
        allowed-uses: allowed-uses,
        max-height: max-height,
        max-lot-coverage: max-lot-coverage
      }
    ))
  )
)

(define-public (assign-property-zoning (property-id uint) (zone-id uint))
  (let
    (
      (property (unwrap! (contract-call? .property-registration get-property property-id) (err u404)))
      (zone (unwrap! (get-zoning-rule zone-id) (err u405)))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (ok (map-set property-zoning
      { property-id: property-id }
      { zone-id: zone-id }
    ))
  )
)

(define-public (check-zoning-compliance (property-id uint) (proposed-use (string-ascii 50)) (proposed-height uint) (proposed-lot-coverage uint))
  (let
    (
      (property-zone (unwrap! (get-property-zone property-id) (err u404)))
      (zone-rule (unwrap! (get-zoning-rule (get zone-id property-zone)) (err u405)))
    )
    (asserts! (is-some (index-of (get allowed-uses zone-rule) proposed-use)) (err u406))
    (asserts! (<= proposed-height (get max-height zone-rule)) (err u407))
    (asserts! (<= proposed-lot-coverage (get max-lot-coverage zone-rule)) (err u408))
    (ok true)
  )
)

