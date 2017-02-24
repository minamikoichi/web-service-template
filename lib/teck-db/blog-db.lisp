(in-package :teck-db)

(annot:enable-annot-syntax)

;;;
;;; main contents
;;;
@export-class
(def-view-class <item> ()
  ((itemid :accessor itemid-of
	   :db-kind :key
	   :db-constraints (:not-null :unique)
	   :type integer
	   :initarg :itemid)
   (update-time :accessor update-time-of
	      :db-constraints :not-null
	      :type wall-time
	      :initarg :update-time)
   (date :accessor date-of
	 :db-constraints :not-null
	 :type wall-time
	 :initarg :date)
   (title :accessor title-of
	  :type (string 256)
	  :initarg :title)
   (text :accessor text-of
	 :type (string 65535)
	 :db-constraints :not-null
	 :initarg :text))
  (:base-table <item>))

;;;
;;; tagid , tag
;;;
@export-class
(def-view-class <tag> ()
   ((tagid  :accessor tagid-of
	    :db-kind :key
	    :db-constraints (:not-null :unique)
	    :type integer
	    :initarg :tagid)
    (tag    :accessor tag-of
	    :db-constraints (:not-null)
	    :type (string 64)
	    :initarg :tag))
    (:base-table <tag>))

;;;
;;; itemid , tagid
;;;
@export-class
(def-view-class <item-tag-map> ()
  ((itemid :accessor itemid-of
	   :db-constraints :not-null
	   :type integer
	   :initarg :itemid)
   (tagid  :accessor tagid-of
	   :db-constraints :not-null
	   :type integer
	   :initarg :tagid))
  (:base-table <item-tag-map>))

;;
;; setup
;;
(defvar *db*)

@export
(defun setup-blog-db (db)
  (when db
    (setf *db* db)
    ;; create table
    (unless (table-exists-p '<item> :database db)
      (create-view-from-class '<item> :database db))
    (unless (table-exists-p '<tag> :database db)
      (create-view-from-class '<tag> :database db))
    (unless (table-exists-p '<item-tag-map> :database db)
      (create-view-from-class '<item-tag-map> :database db))
    ;; create sequence
    (unless (sequence-exists-p '<itemid-sequence> :database db)
      (create-sequence '<itemid-sequence> :database db))
    (unless (sequence-exists-p '<tagid-counter> :database db)
      (create-sequence '<tagid-counter> :database db))))

;; writter
@export
(defun push-item (title text tags &optional (db *db*))
  (with-transaction ()
    (let ((id (sequence-next '<itemid-sequence> :database db))
	  (time (get-time))
	  (date (get-time)))
      (update-records-from-instance
       (make-instance '<item>
		      :itemid id
		      :update-time time
		      :date date
		      :title title
		      :text text)
       :database db)
      (map nil (^ (tag) (push-tag id tag db)) tags))))

@export
(defun update-item (item tags &optional (db *db*))
  (let ((id (itemid-of item))
	(time (get-time)))
  (with-transaction ()
    (update-records-from-instance item :database db)
    (update-tags id tags db))
  (cache-table-queries "item" :action :flush)))

@export
(defun remove-item (itemid &optional (db *db*))
  (let ((item (find-item itemid db))
	(item-tag-map-list (find-item-tag-maps itemid)))
    (with-transaction ()
      (when (consp item)
	(delete-instance-records (car item) :database db)
	(map nil (^ (i) (delete-instance-records i :database db)) item-tag-map-list))))) ; なぜか１処理でtag全て消える clsqlのbugの可能性有

@export
(defun pull-item (id &optional (db *db*))
  (when id 
    (awhen (find-item id db) (car it))))

;; tag 
@export
(defun push-tag (itemid tag &optional (db *db*))
  (aif (find-tagid tag db)
       (push-item-tag-map itemid it db)
       (lt1 set-tagid (sequence-next '<tagid-counter> :database db)
	 (update-records-from-instance
	  (make-instance '<tag>
			 :tagid set-tagid
			 :tag tag)
	  :database db)
	 (update-records-from-instance 
	  (make-instance '<item-tag-map>
			 :itemid itemid
			 :tagid set-tagid)
	  :database db))))

@export
(defun update-tags (itemid tags &optional (db *db*))
  (let* ((now (pull-item-tags itemid db))
	 (rtags (set-difference now tags :test #'string=))
	 (itags (set-difference tags now :test #'string=)))
    ; remove tag-map.
    (when rtags
      (map nil (^ (tag) 
		 (lt1 tagid (find-tagid tag db)
		   (remove-item-tag-map itemid tagid db))) rtags))
    ; push new tags.
    (when itags
      (map nil (^ (tag) (push-tag itemid tag db)) itags))))

@export
(defun pull-item-tags (itemid &optional (db *db*))
  (awhen (find-tagid-from-itemid itemid db)
    (map 'list (lambda (tagid) (car (funcall #'find-tagname tagid db))) it)))

; item-tag-map
@export
(defun push-item-tag-map (itemid tagid &optional (db *db*))
  (update-records-from-instance 
   (make-instance '<item-tag-map>
		  :itemid itemid
		  :tagid tagid)
   :database db))

@export
(defun remove-item-tag-map (itemid tagid &optional (db *db*))
  (delete-item-tag-map itemid tagid db))

;; sql 
(locally-enable-sql-reader-syntax)
@export
(defun find-item (id &optional (db *db*))
  (select '<item>
	  :where [= [itemid] id]
	  :flatp t
	  :database db))

@export
(defun find-tagid (findtag &optional (db *db*))
  (lt1 ret (select [tagid]
		   :from [<tag>]
		   :where [= [tag] findtag]
		   :field-names nil
		   :flatp t
		   :database db)
    (when ret (car ret))))

@export
(defun find-tagid-from-itemid (itemid &optional (db *db*))
  (select [tagid]
	  :from [<item-tag-map>]
	  :where [= [itemid] itemid]
	  :field-names nil
	  :flatp t
	  :database db))

@export
(defun find-item-tag-map (itemid tagid &optional (db *db*))
  (select '<item-tag-map>
	  :where [and [= [itemid] itemid] [= [tagid] tagid]]
	  :flatp t
	  :database db))

@export
(defun find-item-tag-maps (itemid &optional (db *db*))
  (select '<item-tag-map>
	  :where [= [itemid] itemid]
	  :flatp t
	  :database db))

@export
(defun find-tagname (tagid &optional (db *db*))
  (select [tag]
	  :from [<tag>]
	  :where [= [tagid] tagid]
	  :field-names nil
	  :flatp t
	  :database db))

@export
(defun delete-item-tag-map (itemid tagid &optional (db *db*))
  (delete-records :from [<item-tag-map>]
		  :where [and [= [itemid] itemid] [= [tagid] tagid]]
		  :database db))

;; custom reader
@export
(defun pull-lately-items (&key (offset 0) (size 5) (db *db*))
  (select '<item>
	  :order-by '(([date] :desc))
	  :offset offset
	  :limit size
	  :flatp t
	  :caching nil
	  :database db))

@export
(defun pull-all-itemids (&key (db *db*))
  (select '[itemid]
	  :from [<item>]
	  :order-by '(([date] :desc))
	  :flatp t
	  :database db))

@export
(defun pull-random-items (&key (size 5) (db *db*))
  (select '<item>
	  :order-by :random
	  :limit size
	  :flatp t
	  :caching nil
	  :database db))

@export
(defun pull-later-items (itemid &key (size 5) (db *db*))
  (select '<item>
	  :where [< [itemid] itemid]
	  :limit size
	  :order-by '(([date] :desc))
	  :flatp t
	  :database db))
(restore-sql-reader-syntax-state)

@export
(defun pull-lately-items-with-tags (&key (offset 0) (size 5) (db *db*))
  (let ((qstr (format nil 
               "SELECT i.itemid, i.title, i.date, i.text, GROUP_CONCAT(vt.tag)
	        FROM '<ITEM>' i LEFT OUTER JOIN 
                  ( SELECT itm.itemid, t.tag 
                    FROM '<ITEM_TAG_MAP>' itm INNER JOIN '<TAG>' t
                      ON itm.tagid == t.tagid ) vt
                  ON i.itemid == vt.itemid
                GROUP BY i.itemid
                ORDER BY i.date DESC
                LIMIT  ~a
                OFFSET ~a;" size offset)))
    (query qstr :database db)))

@export
(defun pull-item-with-tags (itemid &key (db *db*))
  (let ((qstr (format nil
         "SELECT i.itemid, i.title, i.date, i.text, GROUP_CONCAT(vt.tag)
	  FROM '<ITEM>' i LEFT OUTER JOIN 
            ( SELECT itm.itemid, t.tag 
              FROM '<ITEM_TAG_MAP>' itm INNER JOIN '<TAG>' t
                 ON itm.tagid == t.tagid ) vt
            ON i.itemid == vt.itemid
          GROUP BY i.itemid 
          HAVING i.itemid == ~a;" itemid)))
    (car (query qstr :database db))))

; wrapper.
@export
(defun format-item-date (item)
  (multiple-value-bind (u s mi h d mo y) (decode-time (date-of item))
    (format nil "~a-~a-~a" y mo d)))
