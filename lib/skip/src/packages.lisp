(defpackage :skip
  (:nicknames :skip)
  (:use #:cl
	#:cl-user
	#:alexandria
	#:cl-ppcre
	#:quicklisp
	#:sb-mop)
  (:export :^
	   :def
	   :nlet
	   :alet
	   :slet
	   :ifbind
	   :aif
	   :fncase
	   :scase
	   :awhen
	   :whenbind
	   :lt1
	   :push-to-end
	   :it
	   ; package
	   :def-in-package
	   ; string 
	   :constr
	   :regex-case
	   :join
	   ; match
	   :dbind
	   :if-match
	   ; mop
	   :map-slots
	   ))
