(in-package #:skip)

(defun match (x y &optional binds)
  (acondm
   ((or (eql x y) (eql x '_) (eql y '_)) (values binds t))
   ((binding x binds) (match it y binds))
   ((binding y binds) (match x it binds))
   ((varsym? x) (values (cons (cons x y) binds) t))
   ((varsym? y) (values (cons (cons y x) binds) t))
   ((and (consp x) (consp y) (match (car x) (car y) binds))
    (match (cdr x) (cdr y) it))
   (t (values nil nil))))

(defun varsym? (x)
  (and (symbolp x) (eq (char (symbol-name x) 0) #\?)))

(defun binding (x binds)
  (labels ((recbind (x binds)
	     (aif (assoc x binds)
		  (or (recbind (cdr it) binds) it))))
    (let ((b (recbind x binds)))
      (values (cdr b) b))))

;(match  '(p a b ?y d) '(p ?z ?y ?x _))
;(match  '(p a b d) '(p a b d))

(defmacro if-match (pat seq then &optional else)
  `(let ,(mapcar #'(lambda (v) `(,v ',(gensym))) (vars-in pat #'simple?))
     (pat-match ,pat ,seq ,then ,else)))

;(defmacro if-match (pat seq then &optional else)
;  `(aifm (match ',pat ,seq)
;	 (let ,(mapcar #'(lambda (v) `(,v (binding ',v it))) (vars-in then #'atom)) 
;	   ,then)
;	 ,else))

(defmacro pat-match (pat seq then else)
  (if (simple? pat)
      (match1 `((,pat ,seq)) then else)
      (with-gensyms (gseq gelse)
	`(labels ((,gelse () ,else))
	   ,(gen-match (cons (list gseq seq)
			     (destruc pat gseq #'simple?))
		       then
		       `(,gelse))))))

(defun simple? (x) (or (atom x) (eq (car x) 'quote)))

(defun gen-match (refs then else)
  (if (null refs)
      then
      (let ((then (gen-match (cdr refs) then else)))
	(if (simple? (caar refs))
	    (match1 refs then else)
	    (gen-match (car refs) then else)))))

(defun match1 (refs then else)
  (dbind ((pat expr) . rest) refs
    (cond ((gensym? pat)
	   `(let ((,pat ,expr))
	     (if (and (typep ,pat `sequence)
		      ,(length-test pat rest))
		 ,then
		 ,else)))
	  ((eq pat '_) then)
	  ((var? pat)
	   (let  ((ge (gensym)))
	     `(let ((,ge ,expr))
		(if (or (gensym? ,pat) (equal ,pat ,ge))
		    (let ((,pat ,ge)) ,then)
		    ,else))))
	  (t `(if (equal ,pat ,expr) ,then ,else)))))

(defun gensym? (s)
  (and (symbolp s) (not (symbol-package s))))

(defun length-test (pat rest)
  (let ((fin (caadar (last rest))))
    (if (or (consp fin) (eq fin 'elt))
	`(= (length ,pat) ,(length rest))
	`(> (length ,pat) ,(- (length rest) 2)))))

(defun vars-in (expr &optional (atom? #'atom))
  (if (funcall atom? expr)
      (if (var? expr) (list expr))
      (union (vars-in (car expr) atom?)
	     (vars-in (cdr expr) atom?))))

(defun var? (x)
  (and (symbolp x) (eq (char (symbol-name x) 0) #\?)))

;(macroexpand (if-match (?x 2) '(1 2) ?x))
;(if-match (?x ?y) '(1 2 3) (values ?x ?y))
;(lt1 n 3 (if-match (?x n 'n '(a b)) '(1 3 n (a b)) ?x)) -> 1
