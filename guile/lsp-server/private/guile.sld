(define-module (lsp-server private guile)

#:export (alist-ref
          alist-ref/default
          current-directory
          create-directory

          absolute-pathname?
          pathname-directory
          pathname-base
          pathname-join
          get-absolute-pathname
          hash-table-join!
          intersperse

          irregex
          irregex-match
          irregex-match-start-index
          irregex-match-substring
          irregex-search

          vector-fold)

#:re-export (uri-decode)

#:use-module ((scheme base) #:select (assoc guard))
#:use-module (srfi srfi-1)
#:use-module (srfi srfi-28)
#:use-module (srfi srfi-69)
#:use-module ((lsp-server private util) #:select (write-log))
#:use-module (web uri)
#:declarative? #f
)