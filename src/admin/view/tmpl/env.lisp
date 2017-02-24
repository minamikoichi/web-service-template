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

(defun transition-link (&rest rest)  
  (skip:ifbind class-val (attr-value :class rest)
    `(:a :class ,(skip:join (list "TRANSITION" class-val) " ") ,@(remove-attr :class rest))
    `(:a :class "TRANSITION" ,@rest)))

;;; tag 
(defparameter *tag-color-settings* (make-hash-table :test #'equal))
(defun set-tag-color (name color-code)
  (setf (gethash name *tag-color-settings*) color-code))
(defun get-tag-color (name)
  (gethash name *tag-color-settings*))
(defun markup-tag (tag)
  (let ((color (get-tag-color tag)))
    (when color
      (list :span :class "item-title-tag" :style (concatenate 'string "background-color: " color) tag))))
(defun markup-tags (tags)
  (map 'list #'markup-tag tags))
(defun make-tags (tags)
  (when tags
    (loop for tag in tags
       when tag collect (markup-tag tag))))

(set-tag-color "面白い" "orange")
(set-tag-color "お気に入り" "#3A87AD")
