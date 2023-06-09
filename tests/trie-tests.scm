(import (scheme base))

(cond-expand
 (guile (import (only (srfi srfi-1) every fold)
                (srfi srfi-64)
                (srfi srfi-69)
                (lsp-server guile util)))
 (else (import (only (srfi 1) every fold)
               (srfi 64)
               (srfi 69))))

(include "../lsp-server/trie.scm")

(test-begin "trie tests")

(let ((trie (make-trie)))
  (trie-insert! trie "abcd" #f)
  (trie-insert! trie "bla" #f)
  (trie-insert! trie "abc" #f)
  (test-equal '("abc" "abcd" "bla") (trie-keys trie))
  (test-equal '("abc" "abcd") (trie-words-with-prefix trie "ab"))
  (test-equal '() (trie-words-with-prefix trie "ga"))

  (let* ((alist (trie->alist trie))
         (trie2 (alist->trie alist))
         (keys (trie-keys trie2)))
    (test-assert (every (lambda (entry)
                          (member entry keys))
                        '("abc" "abcd" "bla")))
    (test-equal 3 (length keys))))

(test-end "trie tests")
