;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;; (push (make-instance 'delta-logging-handler) *delta-handlers*) ;; enable if delta messages should be logged on terminal
(add-delta-messenger "http://delta-notifier/")
(setf *log-delta-messenger-message-bus-processing* nil) ;; set to t for extra messages for debugging delta messenger

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* nil) ; change nil to t for logging requests to virtuoso (and the response)
(setf *backend* "http://triplestore:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil) ; change nil to t for logging all incoming requests

;;;;;;;;;;;;;;;;
;;; prefix types
(in-package :type-cache)

; This setting isn't strictly necessary as we don't currently access session information outside of
; sudo queries, but is here in case we need it in the future.
(add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session") ; each session URI will be handled for updates as if it had this mussession:Session type

;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

;; these three reset the configuration, they are likely not necessary
(defparameter *access-specifications* nil)
(defparameter *graphs* nil)
(defparameter *rights* nil)

;; Prefixes used in the constraints below (not in the SPARQL queries)
(define-prefixes
  ;; Core
  :mu "http://mu.semte.ch/vocabularies/core/"
  :session "http://mu.semte.ch/vocabularies/session/"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  ;; Custom prefix URIs here, prefix casing is ignored
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :musession "http://mu.semte.ch/vocabularies/session/"
  )


;;;;;;;;;
;; Graphs
;;
;; These are the graph specifications known in the system.  No
;; guarantees are given as to what content is readable from a graph.  If
;; two graphs are nearly identical and have the same name, perhaps the
;; specifications can be folded too.  This could help when building
;; indexes.

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("besluit:Bestuurseenheid" -> _)
)

; We don't define the "http://mu.semte.ch/graphs/private" graph here as there is no non-sudo access
; to that graph

;;;;;;;;;;;;;
;; User roles

(supply-allowed-group "public")

; vendor-login-service puts session information in the same graph as it finds account information,
; so we can't use a separate session graph without modifying that service. This is left here in case
; it is needed in the future.
; (supply-allowed-group "agent"
;   :parameters ()
;   :query "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
;           PREFIX muAccount: <http://mu.semte.ch/vocabularies/account/>
;           SELECT DISTINCT * WHERE {
;             <SESSION_ID> muAccount:account ?account ;
;                          muAccount:canActOnBehalfOf ?adminUnit .
;             ?account a foaf:Agent .
;           }"
; )
; (grant (read)
;        :to-graph session-graph
;        :for-allowed-group "agent")

(grant (read)
       :to-graph public
       :for-allowed-group "public")
