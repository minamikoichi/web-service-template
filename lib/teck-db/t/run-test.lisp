(in-package :cl-user)

(defpackage :app-db-test
  (:use :cl
	:skip
	:clsql
	:clsql-sqlite3
	:it.bese.FiveAM
	:app-db))

(in-package :app-db-test)

(def-suite app-db-test :description "function test suite.")
(in-suite app-db-test)

(defparameter *connection*
  (connect '("../../data/boardgame-blog.db")
	   :if-exists :old :database-type :sqlite3))

(app-db:pull-lately-items-with-tags :db *connection*)
(app-db:pull-item-with-tags  29 :db *connection*)

(run! 'app-db-test)
