(in-package :cl-user)

(skip:def-in-package :teck
  (:use :skip
	:cl-ws
	:cl-ws-object
	:cl-ws-wookie
	:cl-json
	:cl-markup
	:teck-db
	:wookie
	:org-to-html)
  (:shadowing-import-from :teck-db :name-of)
  (:export *frontend-config*))
