(in-package :admin)

;;; gamelist 

(defvar *bgg-username*)

(defun update-gamelist-data (req rsp)
  (let* ((*bgg-username* "mnmkh")
	 (collection-sxml (cl-bgg:collection *bgg-username* :result-type :sxml)))
    (when collection-sxml
      (whenbind items (cl-bgg:items-of collection-sxml)
	(loop for item in items
	     do (progn  
		  (app-db:push-collection-to-db *bgg-username* item)
		  (let* ((guid (cl-bgg:item-guid-of item))
			 (bg-foundp (car (app-db:find-boardgame guid))))
		    (format t "GUID : ~a ~a ~%" guid (app-db:find-boardgame guid))
		    (unless bg-foundp
		      (format t "not found  : ~a ~%" guid)
		      (whenbind boardgame-sxml (cl-bgg:boardgame guid :result-type :sxml)
			(app-db:push-boardgame-to-db boardgame-sxml))))))))
    (send-ok rsp)))
