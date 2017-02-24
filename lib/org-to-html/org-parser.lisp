(in-package :org-to-html)

;;
;; support structure
;;
;; Header
;; #+TITLE: TITLE
;; #+TAGS:  :TAG_A:TAG_B:TAG_C:
;;
;; headline
;;    * -> h1
;;    ** -> h2
;;    *** -> h3
;;
;; list
;;    + xxx -> <ol><li>xxx</li><li>yyy</li></ol>
;;    + yyy
;;    - xxx -> <ul><li>xxx</li><li>yyy</li></ul>
;;    - xxx
;;
;; block
;;    #+BEGIN_SRC  -> <div class=XXX> 
;;      (block)        (block)
;;    #+END_SRC       </>
;;
;; link
;;    [[link][discription]]
;;    [[image-link][discription]]
;;
;; option
;;    #+ATTR_HTML: attr=value
;;    [[link][discription]]
;;
;;

(defmacro gands (before after)
  "return before value before set after value"
  (let ((gr (gensym)))
    `(let ((,gr ,before))
	(setf ,before ,after)
	,gr)))

(defclass org-parser ()
  ((in :initarg :in :accessor org-parser-in :initform nil)
   (buf :initarg :buf :accessor org-parser-buf :initform nil)))

(defun make-org-parser (in)
  (make-instance 'org-parser :in in))

(defmethod getline ((r org-parser))
  (with-slots (in buf) r
    (if buf
	(gands buf nil)
	(read-line in nil))))

(defmethod ungetline ((r org-parser) (setline string))
  (setf (org-parser-buf r) setline) nil)

(defmethod read-block ((r org-parser))
  (let ((line (getline r)))
    (when line
      (regex-case line
       ; skip 
       ("^$" () (read-block r))
       ("^#\\+br" () (list :br)) 
       ; one line block
       ("^\\* (.*)" (v) (list :h1 v))
       ("^\\*\\* (.*)" (v) (list :h2 v))
       ("^\\*\\*\\* (.*)" (v) (list :h3 v))
       ; block
       ("^#\\+ATTR_HTML:(.*)" (attr) (append-attr (make-attr-list attr) (read-block r)))
       ; list
       ("^\\+ (.*)" (v) (append (list :ol :li v) (read-list-block r "^\\+ (.*)")))
       ("^\\- (.*)" (v) (append (list :ul :li v) (read-list-block r "^\\- (.*)")))
       ; src block
       ("^#\\+BEGIN_SRC" ()  (list :pre :class "prettyprint" (read-src-block r)))
       ; image
       ("^#\\+IMG:(.*)\\s(.*)\\s(.*)\\s(.*)" (src width height alt) (list :img :src src :width width :height height :alt alt))
       ("^#\\+IMG:(.*)\\s(.*)" (src alt) (list :img :src src :alt alt))
       ("^#\\+AIMG:(.*)\\s(.*)\\s(.*)\\s(.*)\\s(.*)" (link width height alt src) (list :a :href link (list :img :src src :width width :height height :alt alt)))
       ("\\[\\[(.*\\.png)\\]\\[(.*)\\]\\]" (link dsp) (list :img :src link :alt dsp))
       ("\\[\\[(.*\\.jpg)\\]\\[(.*)\\]\\]" (link dsp) (list :img :src link :alt dsp))
       ("\\[\\[(.*)\\]\\[(.*)\\.png\\]\\]" (link thm) (list :a :href link (list :img :src thm)))
       ("\\[\\[(.*)\\]\\[(.*)\\.jpg\\]\\]" (link thm) (list :a :href link (list :img :src thm)))
       ("\\[\\[(.*)\\]\\[(.*)\\]\\]" (link dsp) (list :a :href link dsp))
       ("\\[\\[(.*)\\]\\]" (link) (list :a :href link))
       ; custom 
       ("^#\\+photo-viewer:(.*)" (photos) (make-photo-viewer photos))
       ; other
       (otherwise (list :p line))))))

(defun make-attr-list (attr)
  (lt1 pairs (all-matches-as-strings "(\\w+=\\w+)" attr)
    (when pairs
      (lt1 ret '()
	(dolist (pair pairs)
	  (multiple-value-bind (attr value) (values-list (split "=" pair))
	    (if (and attr value)
		(progn (push (concatenate 'string ":" attr) ret)
		       (push value ret)))))
	(nreverse ret)))))

(defun append-attr (attr-list base)
  (let ((tag (car base))
	(value (cdr base)))
    (append (cons tag attr-list) value)))

(defmethod read-list-block ((r org-parser) (find-token string))
  (let ((line (getline r)))
    (when line
	(regex-case line 
	  (find-token (v) (append (list :li v) (read-list-block r find-token)))
	  (otherwise (ungetline r line))))))

(defparameter CR #\return)
(defparameter LF #\linefeed)
(defun append-crlf (str)
  (format nil "~s~C~C" str CR LF))

;; (defparameter CRLF (flush-with-CRLF nil ""))

(defmethod read-src-block ((r org-parser))
  (let ((line (getline r)))
    (when line
      (regex-case line
	("^#\\+END_SRC" () )
	(otherwise (concatenate 'string (format nil "~a~%" line) (read-src-block r)))))))

; custom
(defun make-photo-viewer (photos)
   `(:div :class "photos"
       (:div :class "trim-frame"
	  (:img :class "photo" :src ,photos))))

(defun parse-org-stream (in)
  (let ((parser (make-org-parser in)))
    (loop for block = (read-block parser)
       while block collect block)))
