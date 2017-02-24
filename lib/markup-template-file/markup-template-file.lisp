;;;;
;;;; create html file from tmpl file.
;;;;
(skip:def-in-package :markup-template-file
  (:use :cl
	:cl-markup)
  (:nicknames :tmpl)
  (:export #:markup-template-file))

(defvar *view-template-root*)

;; bad code...
;; @todo: create template reader
(defmacro with-progn-in-package (package &body body)
  (let ((gpkg (gensym))
	(ret (gensym)))
    `(let ((,gpkg *package*) (,ret nil))
       (eval-when (:compile-toplevel :load-toplevel :execute)
	 (setq *package* (sb-int:find-undeleted-package-or-lose ,package)))
       (setq ,ret ,@body)
       (eval-when (:compile-toplevel :load-toplevel :execute)
	 (setq *package* (sb-int:find-undeleted-package-or-lose ,gpkg)))
       ,ret)))

;; 
;; tmpl内のvariableを評価する
;; #, variable
;; 
(set-dispatch-macro-character #\# #\,
  (lambda (s c m)
    (eval (read s t nil t))))

;;
;; tmpl内のcomponentを挿入する
;; "#@| component |"
;; 
(set-dispatch-macro-character #\# #\@
  (lambda (s c m)
    (read-from-file (symbol-name (read s t nil t)))))

(defun file-to-string (path)
  (with-open-file (in path)
    (when in
      (with-output-to-string (out)
	(loop for line = (read-line in nil nil)
	   while line
	   do (write-line line out))))))

(defun read-from-file (path)
  (if (probe-file path)
      (read-from-string (file-to-string path))
      (let ((path (make-pathname :directory (pathname-directory *view-template-root*) :name path)))
	(read-from-string (file-to-string path)))))

;; load env file.
(defun load-env (&optional (workdir *view-template-root*))
  (let ((env (make-pathname :directory (pathname-directory (parse-namestring workdir))
			    :name "env"
			    :type "lisp")))
    (when (probe-file env)
      (load env))))

(defun markup-template-file (path &key (eval-package *package*))
  (let ((*view-template-root* (parse-namestring path)))
    (eval-when (:compile-toplevel :load-toplevel :execute)
      (setf cl-markup:*markup-language* :html5)
      (with-progn-in-package (package-name (find-package eval-package))
	(progn (load-env)
	       (constr (cl-markup:doctype :html)
		       (cl-markup:markup* (read-from-file path))))))))

;; override for html5
(defun cl-markup::doctype (lang)
  (case lang
    (:xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    (:html "<!DOCTYPE html>")
    (:xhtml "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
    (t "")))
