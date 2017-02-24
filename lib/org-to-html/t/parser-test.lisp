(in-package :org-to-html-test)

(def-suite oth-test :description "oth-convert-test")
(in-suite oth-test)

(defparameter *parse-org-lines-test-value*
  (with-open-file (in "t/input.txt" :direction :input)
    (markup-org-stream in)))

(test parse-org-lines-test
  (is (equal *parse-org-lines-test-value* 
	     '((:H1 "title1") (:P "hello world") (:H2 "title2") (:P "日本語") (:H3 "title3")
	       (:OL :LI "list1" :LI "list2") (:UL :LI "list1" :LI "list2")
	       (:DIV :CLASS :SRC " (defun hello ()    (hello world))")
	       (:A :HREF "link" (:IMG :SRC "src" :WIDTH "500" :HEIGHT "300" :ALT "alt"))
	       (:IMG :SRC "aaa" :ALT "link test") (:IMG :SRC "bbb" :ALT "link test")
	       (:A :HREF "http://aaaa/") (:A :HREF "http://aaaa/" "aaa")))))

(run! 'oth-test)


