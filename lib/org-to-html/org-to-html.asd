(in-package :cl-user)

(defpackage :org-to-html-asd
  (:use :cl :asdf))

(in-package :org-to-html-asd)

(defsystem :org-to-html
    :description "convert org-format-text to html"
    :version "0.1"
    :author "mnmkh"
    :components ((:file "packages")
                 (:file "org-parser" :depends-on ("packages"))
                 (:file "org-to-html" :depends-on ("packages")))
    :depends-on (:skip
		 :cl-ppcre
		 :cl-markup))

(defsystem :org-to-html-test
  :components ((:module :t
                        :serial t
                        :components ((:file "packages")
				     (:file "parser-test"))))
  :depends-on (:org-to-html :fiveAM))

(defmethod perform ((op asdf:test-op) (c (eql (find-system 'org-to-html))))
  (load (merge-pathnames "run-test.lisp" (system-source-directory c))))