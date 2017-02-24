(in-package :skip)

(defmacro constr (&body args)
  `(concatenate 'string ,@args))

(defmacro scase (keyform &body cases)
  (let ((gseq (gensym)))
    `(let ((,gseq ,keyform))
       (cond  . ,(mapcar (^ (c) `((string= ,gseq ,(car c)) ,(cadr c))) cases)))))

;(macroexpand-1 '(scase "aaa" ("aaa" (+ 1 2 (+ 3 4))) ("bbb" 'bbb)))
;(scase "aaa" ("aaa" (+ 1 2 (+ 3 4))) ("bbb" 'bbb))
;(scase "bbb" ("aaa" 'aaa) ("bbb" 'bbb))

(defmacro regex-case (key &body clauses)
  (cond ((null clauses) nil)
	((equal (caar clauses) 'otherwise) `,(cadar clauses))
	(t (let ((cl1 (car clauses))
		 (match (gensym))
		 (vars (gensym)))
	     `(multiple-value-bind (,match ,vars) (scan-to-strings ,(car cl1) ,key)
		(if (or ,match ,vars)
		    (dbind ,(cadr cl1) ,vars ,(caddr cl1))
		    (regex-case ,key ,@(cdr clauses)))))))) 
;;->
;(multiple-value-bind (match vars) (scan-to-strings "^(\\*) aa" "* aaa")
;  (if (or match var)
;      (dbind (h1) var h1)
;      (multiple-value-bind (match vars) (scan-to-strings "^.*(aa)" "* aaa")
;	(if (or match var)
;	    (dbind (aa) var aa)
;	    (otherwise t)))))

;(macroexpand-1
;	 '(regex-case "* aaa" 
;	   ("^(\\*)" (h1) (h1))
;	   ("^\\* (\w+)$" (title) title)
;	   (otherwise t)))

;(macroexpand
;	 '(regex-case "* aaa" 
;	   ("^(\\*)" (h1) (h1))
;	   ("^\\* (\w+)$" (title) title)
;	   (otherwise t)))

;;
;; join
;; 
(defun join (string-list &optional (connect-char ","))
  (lt1 format-string (concatenate 'string "~{~A~^" connect-char "~}")
    (format nil format-string string-list)))
