(in-package :cl-user)

(asdf:defsystem :markup-template-file
  :description "markup-template-file"
  :version "0.1"
  :author "mnmkh"
  :defsystem-depends-on (:cl-markup)
  :serial T
  :encoding :utf-8
  :components ((:static-file "markup-template-file.asd")
	       (:file "markup-template-file"))
  :depends-on (:skip
	       :hu.dwim.defclass-star
	       :cl-markup))

(asdf:defsystem :markup-template-file-test
  :version "0.1"
  :defsystem-depends-on (:markup-template-file)
  :serial T
  :encoding :utf-8
  :pathname "t/"  
;  :components ((:file "packages"))
  :depends-on (:markup-template-file :fiveAM))

;;
;; 
;;
(defmethod perform ((op asdf:test-op) (c (eql (asdf:find-system :markup-template-file))))
  (load (merge-pathnames "t/run-test.lisp" (system-source-directory c))))
