(define-library (lsp-server private parse)

(export generate-meta-data!
        fetch-definition-locations
        fetch-documentation
        fetch-signature
        file-already-parsed?
        list-completions
        parse-library-name-from-file)

(import (only (srfi 1) any every filter find fold append-map)
        (only (srfi 14) char-set)
        (only (srfi 13) string-contains string-trim-right string-prefix?)
        (srfi 28)
        (srfi 69)
        (only (scheme file) with-input-from-file)
        (scheme read)
        (lsp-server private util)
        (lsp-server private trie))

(cond-expand
 (chicken (import (scheme base)
                  (scheme)
                  (chicken irregex)
                  (chicken file)
                  (chicken file posix)
                  (only (chicken keyword) keyword?)
                  (lsp-server private chicken)))
 (gambit (import (scheme base)
                 (only (gambit)
                       caddr
                       file-last-modification-time
                       path-extension
                       time->seconds)
                 (lsp-server private gambit)))
 (guile (import (only (scheme base)
                      define-record-type
                      error-object?
                      error-object-message
                      features
                      guard
                      read-line)
                (only (scheme file) with-input-from-file)
                (scheme read)
                (system vm program)
                (ice-9 ftw)
                (lsp-server private guile))))

(include "parse-impl.scm")

(begin
  (define hash-table-join! hash-table-merge!)
  (define (library-available? x) #t)))