(in-package :org-to-html)

;;
;; support structure
;;
;; Header
;; #+TITLE: TITLE
;; #+TAGS:  :TAG_A:TAG_B:TAG_C:
;;
;; headline
;;    * -> h1
;;    ** -> h2
;;    *** -> h3
;;
;; list
;;    + xxx -> <ol><li>xxx</li><li>yyy</li></ol>
;;    + yyy
;;    - xxx -> <ul><li>xxx</li><li>yyy</li></ul>
;;    - xxx
;;
;; block
;;    #+BEGIN_SRC  -> <div class=XXX> 
;;      (block)        (block)
;;    #+END_SRC       </>
;;
;; link
;;    [[link][discription]]
;;    [[image-link][discription]]
;;
;; option
;;    #+ATTR_HTML: attr=value
;;    [[link][discription]]
;;
;;

(defun oth-stream (in)
  (with-output-to-string (out)
    (map nil (lambda (s) (write-string (markup* s) out)) (parse-org-stream in))))

(defun oth-strings (lines)
  (with-output-to-string (out)
    (map nil (lambda (s) (write-string (markup* s) out)) (parse-org-stream (make-string-input-stream lines)))))

(defun markup-org-strings (lines)
  (parse-org-stream (make-string-input-stream lines)))

(defun markup-org-stream (in)
  (parse-org-stream in))

;(with-open-file (in "t/input.txt" :direction :input)
;  (oth-stream in))
