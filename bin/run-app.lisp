#!/usr/local/bin/sbcl --script
;;;;
;;;; Author: mnmkh
;;;; app server start script.
;;;; 

(load #p"~/.sbclrc")

(defun create-abs-path (path)
  (merge-pathnames path *DEFAULT-PATHNAME-DEFAULTS*))

(defun add-libpath! (path)
  (pushnew path asdf:*central-registry*))

(defun usage ()
  (format t "[Usage] run-app APP-DIREDTORY LIB-DIRECTORY ... ~%"))

(when (< (length sb-ext:*posix-argv*) 3) 
  (usage)
  (exit))

(add-libpath! #p"./lib/skip/")

(let ((*standard-output* (make-string-output-stream)))
  (ql:quickload "skip")
  (ql:quickload "cl-fad")
  (ql:quickload "cl-async"))

;;; variable
(defvar *app-directory* (second sb-ext:*posix-argv*))
(defvar *lib-directory* (third sb-ext:*posix-argv*))

;;; add libpath
(map nil (lambda (path) 
	   (when (cl-fad:directory-pathname-p path)
	     (add-libpath! (pathname path))))
     (cl-fad:list-directory *lib-directory*))

(map nil (lambda (path) 
	   (when (cl-fad:directory-pathname-p path)
	     (add-libpath! (pathname path))))
     (map 'list (lambda (path) 
		  (merge-pathnames "app/" path)) 
	  (cl-fad:list-directory *app-directory*)))

;(map nil (lambda (path) 
;	   (when (cl-fad:directory-pathname-p path)
;	     (add-libpath! (pathname path))))
;  (cl-fad:list-directory "./lib/"))

;;; load
;; buildappを使用する方法も検討する。
;; http://xach.com/lisp/buildapp/ 
(ql:quickload "teck")

;;; swank
(ql:quickload :swank)

;;; app run code.
(defparameter *teck-server*
  (cl-ws:launch-instance teck::*frontend-config*))

;(swank:create-server :port 4005 :style :spawn :dont-close t)

; event loop
(as:start-event-loop 
  (lambda ()
    (as:signal-handler 2
		       (lambda (sig)
			 (declare (ignore sig))
			 (as:free-signal-handler 2)
			 (cl-ws-wookie:stop-instance *teck-server*)))))
