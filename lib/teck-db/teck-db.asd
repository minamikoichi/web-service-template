(in-package :cl-user)

(defpackage :teck-db-asd
  (:use :cl :asdf))

(in-package :teck-db-asd)

(defsystem :teck-db
    :description "teck common database libs."
    :version "0.1"
    :author "mnmkh"
    :serial T
    :components ((:static-file "teck-db.asd")
		 (:file "packages")
		 (:file "blog-db")
		 (:file "teck-db"))
    :depends-on (:skip
		 :clsql
		 :clsql-sqlite3
		 :hu.dwim.defclass-star
		 :cl-annot))

(defsystem :teck-db-test
  :components ((:module :t
                        :serial t
                        :components ((:file "packages"))))
  :depends-on (:teck-db :fiveAM))


(defmethod perform ((op asdf:test-op) (c (eql (find-system 'teck-db))))
  (load (merge-pathnames "t/run-test.lisp" (system-source-directory c))))
