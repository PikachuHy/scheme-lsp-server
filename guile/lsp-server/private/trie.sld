(define-module (lsp-server private trie)

#:export (make-trie
          trie?
          trie-insert!
          trie-keys
          trie-entries-with-prefix
          trie-words-with-prefix
          trie->alist
          alist->trie)

#:use-module ((scheme base) #:select (define-record-type))
#:use-module ((srfi srfi-1) #:select (every fold))
#:use-module (srfi srfi-69))

