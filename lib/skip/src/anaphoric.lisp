(in-package #:skip)

;
; from on lisp
;
(defmacro alet (arg &body body)
  `(let ((it ,arg)) ,@body))

(defmacro aif (test-form then-form &optional else-form)
  `(let ((it ,test-form))
      (if it ,then-form ,else-form)))

(defmacro awhen (test-form &body body)
  `(whenbind it ,test-form ,@body))

(defmacro aand (&rest args)
  (cond ((null args) t)
	((null (cdr args)) (car args))
	(t `(aif ,(car args) (aand ,@(cdr args))))))

;
; test return multiple-value
; 
(defmacro aifm (test &optional then else)
  (let ((win (gensym)))
    `(multiple-value-bind (it ,win) ,test
       (if (or it ,win) ,then ,else))))


(defmacro acondm (&rest clauses)
  (if (null clauses)
      nil
      (let ((cl1 (car clauses))
	    (val (gensym))
	    (win (gensym)))
	`(multiple-value-bind (,val ,win) ,(car cl1)
	   (if (or ,val ,win)
	       (let ((it ,val)) ,@(cdr cl1))
	       (acondm ,@(cdr clauses)))))))
