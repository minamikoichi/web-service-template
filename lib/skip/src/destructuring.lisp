(in-package #:skip)

;;
;; from on lisp.
;;
(defmacro dbind (pat seq &body body)
  (let ((gseq (gensym)))
    `(let ((,gseq ,seq))
       ,(dbind-ex (destruc pat gseq #'atom) body))))

(defun destruc (pat seq &optional (atom? #'atom) (n 0))
  (if (null pat)
      nil
      (let ((rest (cond ((funcall atom? pat) pat)
			((eq (car pat) '&rest) (cadr pat))
			((eq (car pat) '&body) (cadr pat))
			(t nil))))
	(if rest `((,rest (subseq ,seq ,n)))
	    (let ((p (car pat))
		  (rec (destruc (cdr pat) seq atom? (1+ n))))
	      (if (funcall atom? p)
		  (cons `(,p (elt ,seq ,n)) rec)
		  (let ((var (gensym)))
		    (cons (cons `(,var (elt ,seq ,n))
				(destruc p var atom?))
			  rec))))))))

(defun dbind-ex (binds body)
  (if (null binds)
      `(progn ,@body)
      `(let ,(mapcar #'(lambda (b) (if (consp (car b))
				       (car b)
				       b))
		     binds)
	 ,(dbind-ex (mapcan #'(lambda (b) (if (consp (car b)) (cdr b))) binds) body))))

;;
;(destruc 'a 'seq #'atom)
;(destruc '(a) 'seq #'atom)
;(destruc '(&rest a) 'seq #'atom)
;(destruc '(&body a) 'seq #'atom)
;(destruc '(a b c) 'seq #'atom)
;(destruc '(a ( b . c ) &rest d) 'seq)

;(dbind-ex (destruc '(a ( b . c ) &rest d) 'seq) '(body))
;(dbind-ex (destruc '(a ( b . ( c . cc ) ) ( e . ee )  &rest d) 'seq) '(body))

;(dbind  (a b c) '(1 2 3) '(a b c))

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))

(defmacro with-struct ((name . fields) struct &body body)
  (let ((gs (gensym)))
    `(let ((,gs ,struct))
       (let ,(mapcar #'(lambda (f) `(,f (,(symb name f) ,gs))) fields)
	 ,@body))))

;(defstruct visitor name title firm)
;(setq theo (make-visitor :name "test" :title 'king :firm 'franks))
;(macroexpand-1 (with-struct (visitor- name title firm) theo))


(defmacro with-places (pat seq &body body)
  (let ((gseq (gensym)))
    `(ret ((,gseq ,seq))
      ,(wplac-ex (destruc pat gseq #'atom) body))))

(defun wplac-ex (binds body)
  (if (null binds)
      `(progn ,@body)
      `(symbol-macrolet ,(mapcar #'(lambda (b) (if (consp (car b))
						   (car b)
						   b)) binds)
	 ,(wplac-ex (mapcan #'(lambda (b) (if (consp (car b)) 
					      (cdr b)))
			    binds) 
		    body))))
