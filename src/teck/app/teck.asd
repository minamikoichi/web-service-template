(in-package :cl-user)

(asdf:defsystem :teck
  :serial T
  :encoding :utf-8
  :components ((:file "packages")
	       (:file "blog")	       
	       (:file "data")
	       (:file "feed")
	       (:file "teck"))
  :depends-on (:skip
	       :cl-ws
	       :cl-ws-object
	       :cl-ws-wookie
	       :cl-ws-object-clsql-interface
	       :wookie
	       :cl-json
	       :cl-markup
	       :teck-db
	       :org-to-html
	       :cl-bgg))
