;;;; Author: mnmkh

;;;; generate feed
(in-package :teck)

(defparameter *page-title* "土曜Lisp")
(defparameter *about-text* "Lispをメインに技術ネタを記録するページ")

(defclass* <rss-channel> ()
  ; required elements
  ((title "")
   (link "")
   (description "")
   ; optional elements
   (language "ja")
   (copyright)
   (managingEditor)
   (webMaster)
   (pubDate)
   (lastBuildDate)
   (category)
   (generator)
   (docs)
   (cloud)
   (ttl)
   (image)
   (rating)
   (textInput)
   (skipHours)
   (skipDays)))

(defclass* <rss-item> ()
  ; required elements
  ((title)
   (link)
   (description)
   ; optional elements
   (author)
   (category)
   (comments)
   (enclosure)
   (guid)
   (pubDate)
   (source)))

(defmethod print-object ((object <rss-item>) stream)
  (let ((*output-stream* stream))
    (markup (:item
	     (:title (title-of object))
	     (:link  (link-of object))
	     (:description (raw (description-of object)))
	     (:author (author-of object))
	     (:guid (guid-of object))
	     (:pubDate (format nil "~a" (pubDate-of object)))))))


(defun make-rss-item (&key title link description (author "mnmkh") pubDate guid)
  (make-instance '<rss-item>
		 :title title
		 :link link
		 :description description
		 :author author
		 :pubDate pubDate
		 :guid guid))

(defun make-plink (item)
  (constr *base-url* "view?id=" (write-to-string (itemid-of item))))

(defun wrap-cdata (str)
  (constr "<![CDATA[" str "]]>"))

(defun make-rss-item-description (item)
  (multiple-value-bind (photo line) (pick-item-summary item)
    (let ((plink (make-plink item)))
      (wrap-cdata (markup (:p line (:a :href plink "続きを読む → ")) (:img :src photo))))))

(defun make-rss-item-from-item (item)
  (make-rss-item 
   :title         (title-of item)
   :link          (make-plink item)
   :description   (make-rss-item-description item)
   :pubDate       (format nil "~a" (date-of item))
   :guid          (make-plink item)))

;	:sb-mop
(defparameter *base-url* "http://doyoulisp.org/teck/")
(defparameter *rss-channel* 
  (make-instance '<rss-channel>
		 :title *page-title*
		 :link *base-url*
		 :description *about-text*))

(defun markup-object-slots (object)
  (when object
    (map-slots (^ (n v) (list (intern (symbol-name n) :keyword) v)) object)))

(defun make-feed (&optional (rss-channel *rss-channel*))
  (when rss-channel
    (whenbind items (pull-lately-items :size 5)
      (markup (:rss :version "2.0"
		    (:channel 
		     (:title (title-of rss-channel))
		     (:link (link-of rss-channel))
		     (:description (description-of rss-channel))
		     (:language (language-of rss-channel))
		     (:lastBuildDate (format nil "~A" (date-of (car items))))
		     (raw (format nil "~{~A~}" (map 'list #'make-rss-item-from-item items)))))))))

(defun feed-data (request response)
  (let ((*markup-language* :xml))
    (wookie:send-response response
			  :headers '(:content-type "application/xml")
			  :body (make-feed))))
