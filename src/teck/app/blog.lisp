(in-package :teck)

;;;;
; blog item utility
;;;;
(defun pick-item-summary (text)
  (with-input-from-string (stream text)
    (loop for line = (read-line stream nil 'eof)
       with firstline = nil
       with firstphoto = nil
       until (or (eq line 'eof) (and firstline firstphoto))
       do (progn
	    (regex-case line
	      ("^#\\+photo-viewer:(.*)" (url) (unless firstphoto (setq firstphoto url)))
	      ("^([\\w-\\W]+)" (l)            (unless firstline  (setq firstline line)))))
       finally 
	 (return (values firstphoto firstline)))))

(defun send-vm-data (response &key type data)
  (send-data response `((:type . ,type) (:data . ,data))))

;;;; 
; blog data
;;;;
(defparameter *number-of-item-in-page* 5)
(defparameter *number-of-item-in-archive* 40)

(defun blog-data (request response &rest args)
  (view-select-page-data request response '("1")))

(defun view-select-id-data (request response args)
  (let ((id (get-integer-parameter (car args) :lower-limit 1 :upper-limit 65535)))
    (ifbind item (pull-item-with-tags id)
	    (send-vm-data response :type "blog-item" :data (list (make-item-data item)))
	    (send-data res ""))))

(defun view-select-page-data (request response args)
  (let ((page-number (get-integer-parameter (car args) :lower-limit 1 :upper-limit 1024)))
    (lt1 items (pull-lately-items-with-tags :offset (* (- page-number 1) *number-of-item-in-page*) :size *number-of-item-in-page*)
      (if items
	  (whenbind itemdata (map 'list #'make-item-data items)
	    (send-vm-data response :type "blog-item-summary" :data itemdata))))))

(defun archive-data (request response)
  (lt1 items (pull-lately-items-with-tags :offset 0 :size *number-of-item-in-archive*)
    (if items
	(whenbind itemdata (map 'list #'make-item-data items)
	  (send-vm-data response :type "blog-archive" :data itemdata)))))

(defun make-item-data (item)
  (multiple-value-bind (thumbnail firstline) (pick-item-summary (fourth item))
    (alexandria:alist-hash-table (map 'list #'(lambda (k v) `(,k . ,v))
				      '(:id :title :date :thumbnail :firstline :text :tags :recommend)
				      `(,(first item) 
					,(second item)
					,(third item)
					,thumbnail
					,firstline
					,(oth-strings (fourth item))
					,(fifth item)
					,(make-recommend-data (first item)))))))

(defun make-recommend-data (id)
  (let ((items (pull-later-items id :size 4)))
    (loop for item in items 
	 collect (multiple-value-bind (thumbnail firstline) (pick-item-summary (text-of item))		   
		   (alexandria:alist-hash-table (map 'list #'(lambda (k v) `(,k . ,v))    
						     '(:id :title :date :thumbnail :firstline)
						     `(,(itemid-of item) 
							,(title-of item)
							,(format-item-date item)
							,thumbnail
							,firstline)))))))
