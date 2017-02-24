(add-libpath! #p"~/src/sbcl/skip/")
(add-libpath! #p"~/src/sbcl/org-to-html/")
(add-libpath! (merge-pathnames *DEFAULT-PATHNAME-DEFAULTS*))

(ql:quickload "org-to-html")