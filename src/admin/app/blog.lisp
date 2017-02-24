(in-package :admin)

(eval-when (:load-toplevel :compile-toplevel)
  (wookie:load-plugins)
  (import 'wookie-plugin-export::post-var))

;; function
(defun parse-tag-parameter (param)
  (cl-ppcre:split "," param))

(defun send-data (response data)
  (wookie:send-response response
			:headers '(:content-type "application/json; charset=utf-8" )
			:body (json:encode-json-to-string data)))

(defun send-ok (response) (send-data response ""))

;;; common
(defun preview-item-data (req res)
  (let ((text     (post-var req "text")))
    (unless (string= text "")
      (send-data res (oth-strings text)))))

;;; edititem
(defun edititem-data (req res)
  (let ((id    (post-var req "id")))
    (lt1 item (pull-item (parse-integer id))
      (send-data res (text-of item)))))
  
(defun preview-edititem-data (req res)
  (preview-item-data req res))

(defun commit-edititem-data (req res)
  (let ((id       (post-var req "id"))
	(title    (post-var req "title"))
	(text     (post-var req "text"))
	(tags     (parse-tag-parameter (post-var req "tags"))))
    (when (stringp id)
      (lt1 item (pull-item (parse-integer id))
	(when item
	  (setf (title-of item) title)
	  (setf (text-of  item) text)
	  (update-item item tags)
	  (send-ok res))))))

(defun delete-edititem-data (req res)
  (let ((id    (post-var req "id")))
    (when (stringp id)
      (remove-item (parse-integer id))
      (send-ok res))))

;;; newitem
;; preview post item
(defun preview-newitem-data (req res)
  (preview-item-data req res))

; post-item
(defun push-item-error (&rest reason)  :error)
(defun post-newitem-data (req rsp)
  (let ((title    (post-var req "title"))
	(text     (post-var req "text"))
	(tags     (parse-tag-parameter (post-var req "tags"))))
    (unless  (string= title "")
      (handler-bind ((sql-error #'push-item-error))
	(push-item title text tags)
	(send-data rsp "")))))
