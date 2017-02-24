(in-package :cl-user)

(defpackage :skip-asd
  (:use :cl :asdf))

(in-package :skip-asd)

(defsystem :skip
    :name "skip"
    :description "Lisp utility. skip."
    :version "0.1"
    :author "mnmkh"
    :components 
    ((:static-file "skip.asd")
     (:module :src
              :serial t
              :components 
              ((:file "packages")
               (:file "skip")
               (:file "anaphoric")
	       (:file "string")
               (:file "destructuring")
               (:file "match")
	       (:file "mop-util"))))
    :depends-on (:alexandria
		 :cl-ppcre))

(defsystem :skip-test
  :components ((:module :t
                        :serial t
                        :components ((:file "string-t"))))
  :depends-on (:skip :fiveAM))

(defmethod perform ((op asdf:test-op) (system (eql (find-system :skip))))
  (funcall (intern (string :run!) (string :it.bese.FiveAM)) :skip))
