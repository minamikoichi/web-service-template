(in-package :cl-user)

(asdf:defsystem :admin
  :serial T
  :encoding :utf-8
  :components ((:file "packages")
	       (:file "blog")
	       (:file "admin")
	       (:file "gamelist"))
  :depends-on (:skip
	       :cl-ws
	       :cl-ws-object
	       :cl-ws-wookie
	       :cl-ws-object-clsql-interface
	       :wookie
	       :cl-json
	       :cl-markup
	       :app-db
	       :org-to-html))
