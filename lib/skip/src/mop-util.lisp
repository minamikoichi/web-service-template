;;;; Author: mnmkh

;;;; Meta object protocol utility

(defun map-slots (fn instance)
  "map for object"
  (loop for name in (mapcar #'sb-mop:slot-definition-name (sb-mop:class-slots (class-of instance)))
     when (slot-boundp instance name) 
     collect (funcall fn name (slot-value instance name))))
