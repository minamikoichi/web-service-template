#!/usr/local/bin/sbcl --script
;;;;
;;;; Author: mnmkh
;;;; generate html script
;;;; 

(load #p"~/.sbclrc")

(defun add-libpath! (path)
  (pushnew path asdf:*central-registry*))

(add-libpath! #p"./lib/markup-template-file/")
(let ((*standard-output* (make-string-output-stream)))
  (ql:quickload "markup-template-file"))

(defun usage ()
  (format t "[Usage] gen-html TEMPLATE-DIREDTORY TARGET-DIRECTORY (EVAL_PACKAGE) ~%"))

(defun make-keyword (name) (values (intern name "KEYWORD")))

(when (or (< (length sb-ext:*posix-argv*) 3) 
	  (> (length sb-ext:*posix-argv*) 4))
  (usage)
  (exit))

;; variable
(defvar *template-directory* (second sb-ext:*posix-argv*))
(defvar *target-directory* (third sb-ext:*posix-argv*))

;;
;; main program.
;;
(format t "[template directory]: ~a ~%" *template-directory*)
(format t "[target directory]: ~a ~%" *target-directory*)

;; gennerate html files.
(let ((template-file-list (directory (make-pathname :directory (pathname-directory (parse-namestring *template-directory*))						     
						    :name :wild
						    :type "tmpl"))))
  (when template-file-list 
    (loop for path in template-file-list
       do (let* ((output-path (make-pathname :directory (pathname-directory (parse-namestring *target-directory*))
					     :name (pathname-name path)
					     :type "html"))
		 (output-path-string (file-namestring output-path)))
	    (format t "markup : ~a -> ~a ~%" path output-path)
	    (with-open-file (out (ensure-directories-exist output-path) :direction :output :if-exists :supersede :if-does-not-exist :create)
	      (format out (markup-template-file:markup-template-file path)))))))

;(loop for path in (directory #p"/tmp/*.lock")
;   with output-path = (make-pathname :directory (pathname-directory (directory-namestring path))
;				     :name (file-namestring path)
;				     :type "html")
;  collect (format nil "~a~%" output-path))
