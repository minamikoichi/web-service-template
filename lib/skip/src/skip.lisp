(in-package #:skip)

;;; ailas
(defmacro ^ ((&rest lambda-list) &body body)
  `(lambda ,lambda-list ,@body))

(defmacro def (name args &body body)
  `(defun ,name ,args ,@body))

;;;
(defmacro fncase (fn keyform &body cases)
  (let ((gseq (gensym)))
    `(let ((,gseq ,keyform))
       (cond  . ,(mapcar (^ (c) (if (equal (car c) 'otherwise)
				    `(t ,(cadr c))
				    `((funcall ,fn ,(car c) ,gseq) ,(cadr c)))) cases)))))

;(macroexpand-1 '(fncase string= "aaa" ("aaa" (+ 1 2 (+ 3 4))) ("bbb" 'bbb)))q
;(scase "mmm" ("aaa" (+ 1 2 (+ 3 4))) ("bbb" 'bbb))

;;;
;(defmacro regex-case (fn keyform &body cases)
;  (let ((gseq (gensym)))
;    `(let ((,gseq ,keyform))
;       (cond  . ,(mapcar (^ (c) (if (equal (car c) 'otherwise)
;				    `(t ,(cadr c))
;				    `((funcall ,fn ,(car c) ,gseq) ,(cadr c)))) cases)))))

;;; define user macros.
;; named-let
(defmacro nlet (n letargs &rest body)
  `(labels ((,n ,(mapcar #'car letargs) ,@body))
     (,n ,@(mapcar #'cadr letargs))))

(defmacro ifbind (var test-form then-form &optional else-form)
  `(let ((,var ,test-form))
     (if ,var ,then-form ,else-form)))

(defmacro whenbind (var test-form &body body)
  `(ifbind ,var ,test-form (progn ,@body)))

(defmacro lt1 (name arg &body body)
  `(let ((,name ,arg)) ,@body))

(defmacro slet (binds &rest body)
  `(let ,binds
     ,@(mapcar #'(lambda (b) `(declare (special ,(car b)))) binds)
     ,@body))

;(macroexpand '(with-gensyms (x y) (values x y)))

; (fl nil) -> nil
; (fl fn1) -> fn1
; (fl fn1 fn2) -> (whenbind it fn1 (whenbind fn2 it))
; (fl fn1 fn2 fn3 ...) = (whenbind it fn1 (whenbind it fn2  (whenbind it fn3)))
;(defmacro fl (fn1 &rest fns)
;  (cond ((null fn1) nil)
;	((null fns) (funcall fn1))
;	((null (cdr fns)) fn1)
;	(t `(awhen ,fn1 (fl (funcall (lambda (x) ,(car fns)) it) ,@(cdr fns))))))
;(macroexpand (fl (lambda (x) x)))

; (ct nil) -> nil
; (ct fn1) -> (when fn1)
; (ct fn1 fn2) -> (whenbind it fn1 (whenbind fn2 it))
; (ct fn1 fn2 fn3 ...) = (whenbind it fn1 (whenbind it fn2  (whenbind it fn3)))

;;; list utility
;; function util 
(defmacro push-to-end (item place)
  `(setf ,place (nconc ,place (list ,item))))

;;; tests.
(defmacro test (proc args ret)
  `(equal (,proc ,args) ,ret))

;;; package utils
(defvar *def-in-use-packages* 
  '((:use :cl
          :alexandria
          :cl-ppcre
          :skip
          :quicklisp
          :hu.dwim.defclass-star)))

(defmacro def-in-package (package-keyword &body options)
  "指定されたパッケージ内に移動する。存在しない場合は作成する"
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (unless (cl:find-package ,package-keyword)
       (defpackage ,package-keyword ,@(merge-options *def-in-use-packages* options)))
     (in-package ,package-keyword)))

(defun merge-options (push-options target-options)
  "defpackageのオプションを要素が重複しない方法でmergeする。"
  (cond ((and (null push-options) (null target-options)) nil)
	((null push-options) target-options)
	((null target-options) push-options)
	(:otherwise
	 (let ((result (copy-list target-options)))
	   (loop for push-option in push-options
	      for option-name = (car push-option)
	      do (ifbind match-option (find-if #'(lambda (option) (eql option-name (car option))) result)
			 (nsubstitute-if (remove-duplicates (merge 'list push-option match-option #'eql))
					 #'(lambda (option) (eql option-name (car option)))
					 result
					 :count 1)
			 (push-to-end push-option result)))
	   result))))
