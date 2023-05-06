(define-library (lsp-server private guile)

(export alist-ref
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

(import (guile)
        (only (scheme base) guard)
        (srfi 1)
        (srfi 28)
        (srfi 69)

        (only (lsp-server private) write-log)
        (web uri)))