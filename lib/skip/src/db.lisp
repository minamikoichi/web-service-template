(in-package #:skip)

(defun make-db (&optional (size 100))
  (make-hash-table :size size))

(defmacro db-query (key db)
  `(gethash ,key ,db))

(defun db-push (key val db)
  (push val (db-query key db)))

(defmacro fact (pred &rest args)
  `(progn (dp-push ',pred ',args) ',args))

