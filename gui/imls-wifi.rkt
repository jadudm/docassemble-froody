#lang racket
(require racket/gui/base
         net/http-easy
         json
         net/base64
         net/uri-codec)

(define the-key "Zd3dojw1xppBrDv7sTR7JIRX8ozZVbBr")

(define states '("Alabama"
                 "Alaska"
                 "Arizona"
                 "Arkansas"
                 "California"
                 "Colorado"
                 "Connecticut"
                 "Delaware"
                 "Florida"
                 "Georgia"
                 "Hawaii"
                 "Idaho"
                 "Illinois"
                 "Indiana"
                 "Iowa"
                 "Kansas"
                 "Kentucky"
                 "Louisiana"
                 "Maine"
                 "Maryland"
                 "Massachusetts"
                 "Michigan"
                 "Minnesota"
                 "Mississippi"
                 "Missouri"
                 "Montana"
                 "Nebraska"
                 "Nevada"
                 "New Hampshire"
                 "New Jersey"
                 "New Mexico"
                 "New York"
                 "North Carolina"
                 "North Dakota"
                 "Ohio"
                 "Oklahoma"
                 "Oregon"
                 "Pennsylvania"
                 "Rhode Island"
                 "South Carolina"
                 "South Dakota"
                 "Tennessee"
                 "Texas"
                 "Utah"
                 "Vermont"
                 "Virginia"
                 "Washington"
                 "West Virginia"
                 "Wisconsin"
                 "Wyoming"
                 "American Samoa"
                 "Guam"
                 "Northern Mariana Islands"
                 "Puerto Rico"
                 "U.S. Virgin Islands"))

(define (get-session-id)
  (define res
    (get "http://localhost:8000/api/session/new"
         #:params (list (cons 'key (send api-field get-value))
                        (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                        )))
  (printf "status: ~a~n" (response-status-code res))
  (printf "body: ~a~n" (response-body res))
  (values (hash-ref (response-json res) 'secret)
          (hash-ref (response-json res) 'session)))

(define (submit-counts state count secret session-id)
  (define res
    (post "http://localhost:8000/api/session"
          #:headers (make-immutable-hash (list (cons 'Content-Type "application/json")))
          #:json (jsexpr->string
                  (make-immutable-hash
                   (list (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                         (cons 'key (send api-field get-value))
                         (cons 'session session-id)
                         (cons 'secret secret)
                         (cons 'question 0)
                         (cons 'variables
                               #;(bytes->string/utf-8
                                  (base64-encode #"state" #""))
                               (make-hash (list
                                           (cons 'intro_screen true)
                                           (cons 'state state)
                                           #;(bytes->string/utf-8
                                              (base64-encode #"wifi_sessions" #""))
                                           (cons 'wifi_sessions count))))
                         )))))
  (printf "post status: ~a~n" (response-status-code res))
  (printf "post response: ~a~n" (response-status-message res))
  (printf "post body: ~a~n" (response-body res))
  res)

(define submit-callback
  (λ (b e)
    (define count (send text-field get-value))
    (define state (send combo-field get-value))
    (define-values (secret session-id) (get-session-id))
    (printf "session-id: ~a~n" session-id)
    (submit-counts state count secret session-id)
    (printf "Submitted ~a : ~a~n" state count)))

(define frame (new frame%
                   [label "WiFi Sessions"]
                   [width 400]
                   [height 120]
                   ))

(define a-panel (new vertical-panel%
                     [parent frame]
                     [style '(border)]
                     [vert-margin 5]
                     [horiz-margin 5]
                     [stretchable-width true]
                     [stretchable-height true]))

(define api-field (new text-field%
                       [label "API Key"]
                       [parent a-panel]
                       [init-value the-key]))

(define text-field (new text-field%
                        [label "Session Count"]
                        [parent a-panel]
                        [init-value "0"]
                        ))

(define combo-field (new combo-field%
                         [label "Combo"]
                         [parent a-panel]
                         [choices states]
                         [init-value "Maine"]))

(define submit (new button%
                    [label "Submit"]
                    [parent a-panel]
                    [callback submit-callback]))

;; Uncomment to show the GUI.
;;(send frame show true)

(define count (send text-field get-value))
(define state (send combo-field get-value))
(define-values (secret session-id) (get-session-id))
(printf "session-id: ~a~n" session-id)
(define r1
  (get "http://localhost:8000/api/session"
       #:params (list (cons 'key (send api-field get-value))
                      (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                      (cons 'session session-id)
                      (cons 'secret secret))
       ))
(printf "r1 ~a: ~a~n"
        (response-status-code r1)
        (response-body r1))
(sleep 2)

(define r2
  (get "http://localhost:8000/api/session"
       #:params (list (cons 'key (send api-field get-value))
                      (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                      (cons 'session session-id)
                      (cons 'secret secret))
       ))
(printf "r2 ~a: ~a~n"
        (response-status-code r2)
        (response-body r2))
(sleep 2)

(define r3
  (post "http://localhost:8000/api/session"
        #:headers (make-immutable-hash (list
                                        (cons 'Content-Type "application/json")
                                        (cons 'X-API-Key (send api-field get-value))))
        #:json ((λ (x) x)
                (make-immutable-hash
                 (list (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                       (cons 'key (send api-field get-value))
                       (cons 'session session-id)
                       (cons 'secret secret)
                       (cons 'variables
                             (make-hash (list
                                         (cons 'intro_screen true)
                                         (cons 'state state)
                                         (cons 'wifi_sessions (string->number count))
                                         )))
                       )))))
(printf "r3 ~a: ~a~n~a~n"
        (response-status-code r3)
        (response-status-message r3)
        (response-body r3)
        )
(sleep 2)


(define r4
  (get "http://localhost:8000/api/session"
       #:params (list (cons 'key (send api-field get-value))
                      (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                      (cons 'session session-id)
                      (cons 'secret secret))
       ))
(printf "r4 ~a: ~a~n"
        (response-status-code r4)
        (response-body r4))
(sleep 2)

(printf "ACTION~n")
(define r5
  (post "http://localhost:8000/api/session/action"
        #:headers (make-immutable-hash (list
                                        (cons 'Content-Type "application/json")
                                        (cons 'X-API-Key (send api-field get-value))))
       #:json (make-immutable-hash
               (list (cons 'key (send api-field get-value))
                     (cons 'i "docassemble.imlswirelessinterview:data/questions/wireless.yml")
                     (cons 'session session-id)
                     (cons 'secret secret)
                     (cons 'action "final")))
       ))
(printf "r5 ~a: ~a~n~a~n"
        (response-status-code r5)
        "blah" ;(response-body r5)
        )
(sleep 2)
(printf "ACTION END~n")