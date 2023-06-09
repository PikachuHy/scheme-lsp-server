(define-library (lsp-server private gambit)

(export absolute-pathname?
        alist-ref
        alist-ref/default
        condition->string
        prefix-identifier
        vector-fold
        with-input-from-string
        regular-file?
        directory?

        tcp-read-timeout
        tcp-accept
        tcp-close
        tcp-connect
        tcp-listen
        get-absolute-pathname
        get-module-path
        find-files
        pathname-directory
        pathname-base
        pathname-strip-extension
        pathname-join
        string-split)

(import (gambit)
        (only (srfi 1) any append-map drop-right find)
        (only (srfi 13) string-join)
        (srfi 28))

(begin
  ;;; copied over from srfi-133
  (define (vector-fold kons knil vec1 . o)
    (let ((len (vector-length vec1)))
      (if (null? o)
          (let lp ((i 0)
                   (acc knil))
            (if (>= i len)
                acc
                (lp (+ i 1)
                    (kons acc (vector-ref vec1 i)))))
          (let lp ((i 0)
                   (acc knil))
            (if (>= i len)
                acc
                (lp (+ i 1)
                    (apply kons acc (vector-ref vec1 i)
                           (map (lambda (v)
                                  (vector-ref v i))
                                o))))))))

  (define (with-input-from-string str thunk)
    (define p (open-input-string str))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (parameterize ((current-input-port p))
            (thunk)))
        (lambda () (close-input-port p))))

  (define (absolute-pathname? pathname)
    (and (not (string=? pathname ""))
         (let ((c (string-ref pathname 0)))
           (or (char=? c #\\)
               (char=? c #\/)))))

  (define (alist-ref key lst)
    (define res (assoc key lst))
    (if res
        (cdr res)
        #f))

  (define (alist-ref/default key lst default)
    (define res (assoc key lst))
    (if res
        (cdr res)
        default))

  (define (prefix-identifier mod-name identifier)
    (string->symbol
     (format "~a#~a"
             (canonicalize-module-name mod-name)
             identifier)))

  (define (canonicalize-module-name mod-name)
    (cond ((symbol? mod-name)
           mod-name)
          ((list? mod-name)
           (string->symbol
            (string-join (map symbol->string mod-name)
                         "/")))
          (else (error "expecting a valid module name" mod-name))))

  (define tcp-read-timeout (make-parameter #f))

  (define (tcp-listen port-number)
    (open-tcp-server port-number))

  (define (tcp-accept listener)
    (let ((p (read listener)))
      (values p p)))

  (define (tcp-close listener)
    (close-port listener))

  (define (tcp-connect tcp-address tcp-port-number)
    (let ((p (open-tcp-client tcp-port-number)))
      (values p p)))

  (define (get-absolute-pathname p)
    (path-expand (path-normalize p)))

  (define (get-module-path mod)
    (let* ((parts (if (list? mod)
                      (map (lambda (f) (format "~a" f)) mod)
                      (list (format "~a" mod))))
           (dir-part (if (null? (cdr parts))
                         (list ".")
                         (drop-right parts 1)))
           (filename (last parts))
           (sld-filename (string-append (last parts) ".sld"))
           (scm-filename (string-append (last parts) ".scm"))
           (ss-filename (string-append (last parts) ".ss")))
      (let loop ((roots (list (path-expand "~~lib")
                              (path-expand "~~userlib"))))
        (if (null? roots)
            #f
            (let ((dir (apply pathname-join (cons (car roots) dir-part))))

              (or (find file-exists?
                        (list (pathname-join dir filename)
                              (pathname-join dir sld-filename)
                              (pathname-join dir scm-filename)
                              (pathname-join dir ss-filename)))
                  (loop (cdr roots))))))))

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
                               result)))))))

  (define (pathname-join . paths)
    (apply string-append (intersperse paths "/")))

  (define pathname-directory ##path-directory)

  (define pathname-base ##path-strip-directory)

  (define pathname-strip-extension ##path-strip-extension)

  (define (directory? f)
    (and (file-exists? f)
         (eq? (file-type f) 'directory)))

  (define (regular-file? f)
    (and (file-exists? f)
         (eq? (file-type f) 'regular)))

  (define (find-files path test)
    (cond ((and (regular-file? path)
                (test path))
           (list path))
          ((directory? path)
           (let ((files (map (lambda (f) (pathname-join path f))
                             (directory-files path))))
             (append (filter (lambda (f)
                               (and (regular-file? f)
                                    (test f)))
                             files)
                     (append-map (lambda (d) (find-files d test))
                                 (filter directory? files)))))
          (else '())))

  (define (string-split s #!optional (delim " \r\n"))
    (define len (string-length s))
    (let loop ((i 0)
               (cur-word "")
               (res '()))
      (if (or (>= i len)
              (eof-object? (string-ref s i)))
          (reverse (cons cur-word res))
          (let ((c (string-ref s i)))
            (cond ((string-contains delim (string c))
                   (if (string=? cur-word "")
                       (loop (+ i 1)
                             ""
                             res)
                       (loop (+ i 1)
                             ""
                             (cons cur-word res))))
                  (else
                   (loop (+ i 1)
                         (string-append cur-word (string c))
                         res)))))))

  (define (condition->string exc)
    (with-output-to-string (lambda ()
                             (display-exception exc))))

))
