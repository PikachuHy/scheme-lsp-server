(define-library (lsp-server private compat)

(export $apropos-list
        $compute-diagnostics
        $open-file!
        $save-file!
        $fetch-documentation
        $fetch-signature
        $get-definition-locations
        $initialize-lsp-server!
        $server-capabilities
        $server-name
        $tcp-accept
        $tcp-close
        $tcp-connect
        $tcp-listen
        $tcp-read-timeout)

(import (lsp-server private util)
        (lsp-server private adapter)
        (lsp-server private diagnostics)
        (lsp-server private document)
        (lsp-server private file)
        (lsp-server private parse)
        (json-rpc lolevel)
        (json-rpc))

(import (scheme write)
        (srfi 28)
        (srfi 69))

(cond-expand
 (chicken
  (import (apropos)
          (chicken base)
          (chicken condition)
          (chicken file)
          (chicken format)
          (chicken io)
          (chicken irregex)
          (chicken pathname)
          (chicken port)
          (chicken process)
          (chicken process-context)
          (chicken random)
          (only (chicken string) string-intersperse)
          (chicken tcp)
          nrepl
          chicken-doc
          r7rs
          scheme
          (srfi 1)
          (only (srfi 13) string-join string-concatenate)
          (srfi 18)
          (srfi 28)
          (srfi 69)
          (srfi 130)
          (srfi 180)
          (uri-generic)

          (geiser)
          (lsp-server private chicken))
  (include "compat-chicken-impl.scm"))
 (gambit
  (import (rename (only (gambit)
                        apropos
                        continuation-capture
                        display-exception
                        display-continuation-backtrace
                        eval
                        filter
                        load
                        module-search-order-add!
                        open-tcp-server
                        with-exception-catcher
                        with-input-from-string
                        with-output-to-file
                        with-output-to-string)
                  (with-exception-catcher with-exception-handler))
          (except (scheme base)
                  with-exception-handler)
          (scheme read)
          (only (srfi 1) find)
          (only (srfi 13) string-prefix? string-tokenize)
          (only (srfi 14) char-set char-set-complement)
          (srfi 28)
          (lsp-server private adapter)
          (lsp-server private gambit)
          (github.com/ashinn/irregex))
  (include "compat-gambit-impl.scm"))
 (guile
  (import (only (scheme base)
                define-record-type
                let-values
                read-line
                guard)
          (lsp-server geiser modules)
          (ice-9 documentation)
          (ice-9 ftw)
          (ice-9 optargs)
          (ice-9 popen)
          (ice-9 session)
          (srfi 1)
          (only (srfi 13) string-join string-concatenate)
          (system vm program)
          (system repl server))
  (include "compat-guile-impl.scm"))
 (else)))
