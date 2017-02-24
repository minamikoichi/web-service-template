(ql:quickload "asdf")

(defun add-libpath! (path)
  (pushnew path asdf:*central-registry*))

(add-libpath! #p"~/src/sbcl/web-service-deploy/lib/app-db/")
;(setf ql:*local-project-directories* (list (merge-pathnames *DEFAULT-PATHNAME-DEFAULTS*)))

(ql:quickload "fiveam")
(ql:quickload "clsql")
(ql:quickload "clsql-sqlite3")
(ql:quickload "hu.dwim.defclass-star")
(ql:quickload "app-db")
(asdf:test-system "app-db")
