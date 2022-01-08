(define-library (lsp-server private)

(export make-apropos-info
        apropos-info-module
        apropos-info-name
        apropos-info-type
        apropos-info-object

        make-editor-word
        editor-word-text
        editor-word-end-char
        editor-word-end-line
        editor-word-start-char
        editor-word-start-line

        intersperse
        
        join-module-name
        split-module-name

        alist-ref*
        get-root-path
        get-uri-path
        parse-uri

        identifier-char?
        symbols->string
        hash-table-merge-updating!

        write-log
        log-level

        $string-split)

(import (scheme base)
        (scheme char)
        (scheme write))

(cond-expand
 (guile (import
         (srfi srfi-1)
         (srfi srfi-28)
         (srfi srfi-69)
         (srfi srfi-13)))
 (else (import
        (srfi 1)
        (srfi 28)
        (srfi 69)
        (srfi 130))))

(cond-expand
 (chicken (import (only (chicken base) intersperse)
                  r7rs)))

(begin
  ;;; Guile's string-split uses char for delim-str. Redefining it
  ;;; leads to strange behavior (i.e. string-prefix? is not found
  ;;; anymore. So we export a generic one.
  (cond-expand
   (guile
    (define ($string-split str delim-str . args)
      (define len (string-length str))
      (define dem-len (string-length delim-str))
      (let loop ((i 0)
                 (cur-word "")
                 (res '()))
        (cond ((>= i len)
               (reverse (cons cur-word res)))
              (else
               (let ((c (string-ref str i)))
                 (if (and (>= (- len i)
                              dem-len)
                          (string-prefix? delim-str
                                          str
                                          0
                                          dem-len
                                          i
                                          len))
                     (loop (+ i dem-len)
                           ""
                           (cons cur-word res))
                     (loop (+ i 1)
                           (string-append cur-word (string c))
                           res))))))))
     (else
      (define $string-split string-split)))
  
  (define-record-type <apropos-info>
    (make-apropos-info module name type object)
    apropos-info?
    (module apropos-info-module)
    (name apropos-info-name)
    (type apropos-info-type)
    (object apropos-info-object))

  (define-record-type <editor-word>
    (make-editor-word text start-line end-line start-char end-char)
    editor-word?
    (text editor-word-text)
    (start-line editor-word-start-line)
    (end-line editor-word-end-line)
    (start-char editor-word-start-char)
    (end-char editor-word-end-char))

  
  
  (define (delete-lines lines start end)
    (define len (length lines))
    (append (take lines start)
            (take-right lines (- len end 1))))

  (define (string-split-keeping str sep)
    (define lst (string->list str))
    (let loop ((rem lst)
               (cur-str '())
               (result '()))
      (cond ((null? rem)
             (if (null? cur-str)
                 (reverse result)
                 (reverse (cons (list->string (reverse cur-str))
                                result))))
            ((char=? (car rem) sep)
             (loop (cdr rem)
                   '()
                   (cons (list->string (reverse (cons sep cur-str)))
                         result)))
            (else (loop (cdr rem)
                        (cons (car rem) cur-str)
                        result)))))

  (cond-expand
   (guile
    (define (intersperse lst delim)
      (let loop ((remaining lst)
                 (result '()))
        (cond ((null? remaining)
               (reverse result))
              ((null? (cdr remaining))
               (reverse (cons (car remaining) result)))
              (else
               (loop (cdr remaining)
                     (cons delim
                           (cons (car remaining)
                                 result))))))))
   (else))

  (define (join-module-name mod)
    (if mod
        (apply string-append (append '("(")
                                     (intersperse (map symbol->string mod)
                                                  " ")
                                     '(")")))
        #f))

  (define (split-module-name mod)
    (map string->symbol
         ($string-split
          (substring mod
                     1
                     (- (string-length mod) 1))
          " ")))

  (define (alist-ref key alist)
    (let ((p (assoc key alist)))
      (if p
          (cdr p)
          #f)))

  (define (alist-ref* keys alist)
    (let loop ((keys keys)
               (alist alist))
      (cond ((null? keys) #f)
            ((null? (cdr keys))
             (alist-ref (car keys) alist))
            (else
             (let ((sub-alist (alist-ref (car keys) alist)))
               (if sub-alist
                   (loop (cdr keys) sub-alist)
                   #f))))))

  (define (get-uri-path params)
    (define uri (alist-ref* '(textDocument uri)
                            params))
    (if uri
        (parse-uri uri)
        #f))

  (define (get-root-path params)
    (alist-ref* '(rootPath) params))

  (define (parse-uri uri)
    (define file-prefix "file://")
    (define file-prefix-length 7)
    (define uri-length (string-length uri))
    (if (<= uri-length file-prefix-length)
        #f
        (let ((prefix (substring uri 0 file-prefix-length)))
          (if (equal? prefix file-prefix)
              (substring uri file-prefix-length uri-length)
              (error "invalid uri" uri)))))

  (define (identifier-char? char)
    (or (char-alphabetic? char)
        (char-numeric? char)
        (memq char '(#\! #\$ #\% #\& #\* #\+ #\- #\. #\/ #\: #\<
                     #\= #\> #\? #\@ #\^ #\_ #\~))))

  (define (char-bracket? char)
    (memq char '(#\( #\) #\{ #\} #\[ #\])))


  (cond-expand
   (guile (define (alist-ref key alist)
            (define match (assoc key alist))
            (if match
                (cdr match)
                #f)))
   (else))

  (define (symbols->string sl)
    (string-append "(" (string-join (map symbol->string sl)) ")"))

  (define (hash-table-merge-updating! target source)
    (for-each (lambda (k)
                (hash-table-set! target
                                 k
                                 (hash-table-ref source k)))
              (hash-table-keys source))
    target)

  (define log-level (make-parameter 3))

  (define (get-log-level symb)
    (cond ((eqv? symb 'error) 0)
          ((eqv? symb 'warning) 1)
          ((eqv? symb 'info) 2)
          ((eqv? symb 'debug) 3)
          (else (error "invalid log level" symb))))

  (define (write-log type msg . args)
    (define level (get-log-level type))
    (define error-port (current-error-port))
    (when (<= level (log-level))
      (display (format "[~a] ~a"
                       (string-upcase (symbol->string type))
                       msg)
               error-port)
      (when (not (null? args))
        (display ": " error-port)
        (map (lambda (s)
               (display (format "~a    " s) error-port))
             args))
      (newline error-port)
      (flush-output-port error-port)))))

