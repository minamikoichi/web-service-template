;;;; # :todo refactor. now eval in cl package.
;;;; スクリプトで動作させているので、とりあえずは妥協

(defun attr-value (attr lis)
  (cond ((null lis) nil)
	((atom lis) nil)
	((null (cdr lis)) nil)
	(t (if (equal (car lis) attr)
	       (cadr lis)
	       (attr-value attr (cddr lis))))))

(defun remove-attr (attr lis)
  (let ((rv (attr-value attr lis)))
    (if rv
	(remove rv (remove attr lis))
	(remove attr lis))))
