(cond-expand
 (guile (import (except (scheme base)
                        cond-expand
                        include
                        map
                        error)
                (srfi srfi-1)
                (srfi srfi-64)
                (lsp-server guile)))
 (chicken (import (lsp-server chicken)
                  (srfi 64)
                  (srfi 1))))

(import (lsp-server parse))

(include "../src/parse.scm")

(test-begin "cond-expand parsing")

(cond-expand
 (guile (test-assert (cond-expand-clause-satisfied? '(guile #t))))
 (chicken (test-assert (cond-expand-clause-satisfied? '(chicken #t)))))

(cond-expand
 (guile (test-assert (cond-expand-clause-satisfied?
                      '((or gambit guile) #t))))
 (chicken (test-assert (cond-expand-clause-satisfied?
                        '((or chibi chicken) #t)))))

(cond-expand
 (guile (test-assert (cond-expand-clause-satisfied?
                      '((library (srfi srfi-64)) #t))))
 (chicken (test-assert (cond-expand-clause-satisfied?
                        '((library (srfi 64)) #t)))))

(cond-expand
 (guile (test-assert (not (cond-expand-clause-satisfied?
                           '((not guile) #t)))))
 (chicken (test-assert (not (cond-expand-clause-satisfied?
                             '((not chicken) #t))))))

(test-equal (cond-expand (guile '(begin (import (lsp-server guile))))
                         (chicken '(begin (import (lsp-server chicken))))
                         (else))
            (cond-expand-find-satisfied-clause
             '(cond-expand (guile (import (lsp-server guile)))
                           (chicken (import (lsp-server chicken)))
                           (else))))

(test-equal (cond-expand ((or gambit guile) '(begin "gambit or guile"))
                         ((or chibi chicken) '(begin "chicken or chibi"))
                         (else))
            (cond-expand-find-satisfied-clause
             '(cond-expand ((or gambit guile) "gambit or guile")
                           ((or chicken chibi) "chibi or chicken")
                           (else))))
(test-end "cond-expand parsing")

(test-begin "Collecting meta-data")

(test-assert (tagged-expression? '(import ...) 'import))

(test-assert (procedure-definition-form? '(define (f x) x)))

(test-assert (not (procedure-definition-form? '(define f x))))

(test-assert (procedure-definition-form? '(define f (lambda (x) x))))

(test-eq 'f (procedure-definition-name '(define f (lambda (x) x))))

(test-eq 'f (procedure-definition-name '(define (f x) x)))

(test-equal '(x y) (procedure-definition-arguments '(define (f x y) x)))

(test-equal '(x y) (procedure-definition-arguments '(define f (lambda (x y) x))))

(let ((res (collect-meta-data-from-expression
            '(begin (import (srfi 1) (srfi 69))
                    (define (f x) x)
                    (define g (lambda (x y) (+ x y)))))))
  (test-equal '((srfi 1) (srfi 69)) (source-meta-data-imports res))
  (test-equal 2 (length (source-meta-data-procedure-infos res))))

(let ((res (collect-meta-data-from-expression
            '(define-library (my lib)
                (export f g)
                (import (srfi 1) (srfi 69))
                (begin (define (f x) x))
                       (define g (lambda (x y) (+ x y)))))))
  (test-equal '((srfi 1) (srfi 69)) (source-meta-data-imports res))
  (test-equal 2 (length (source-meta-data-procedure-infos res))))

(let ((res (collect-meta-data-from-expression
            '(cond-expand (guile (import (system vm program))
                                 (define (f x) x))
                          (chicken (import (apropos-api))
                                   (define (f x) x)
                                   (define (g x y) x))
                          (else)))))
  (cond-expand
   (chicken (test-equal '((apropos-api)) (source-meta-data-imports res))
            (test-equal 2 (length (source-meta-data-procedure-infos res))))
   (guile (test-equal '((system vm program)) (source-meta-data-imports res))
          (test-equal 1 (length (source-meta-data-procedure-infos res))))))

(let ((res (collect-meta-data-from-file "resources/sample-1.scm")))
  (test-equal 2 (length (source-meta-data-imports res)))
  (test-equal 2 (length (source-meta-data-procedure-infos res))))

(test-end "Collecting meta-data")
