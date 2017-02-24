(in-package :skip-test)

;
(regex-case "* a aa" 
  ("^(\\*) b" (h1) h1)
  ("^(\\*) (.+)" (h1 title) (list h1 title))
  (otherwise t))

(regex-case "* aaa" (otherwise :hello))
(regex-case "* aaa" ("^(\\* aaa)" (h1) h1))
(regex-case "* aaa" 
  ("^(aaa)" (h1) h1)
  ("^(\\*) (.+)" (h1 title) (list h1 title)))




(macroexpand-1 '(regex-case "* aaa" 
		 ("^(\\*)" (h1) h1)
		 (otherwise "")))

;(regex-case "* aaa" 
;		 ("^(\\*)" (h1) h1)
;		 (otherwise ""))


