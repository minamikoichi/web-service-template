(in-package :cl-user)

(skip:def-in-package :admin
  (:use :skip
	:cl-ws
	:cl-ws-object
	:cl-ws-wookie
;	:cl-ws-object-clsql-interface
	:wookie
	:cl-json
	:cl-markup
	:app-db
	:org-to-html)
  (:shadowing-import-from :app-db :name-of)
  (:export *frontend-config*))
