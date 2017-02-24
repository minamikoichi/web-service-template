(in-package :admin)

(def-frontend-config *frontend-config*
  :name "admin"
  :port 4237
  :service '("admin"))

(defservice admin
      name "admin"
      db-contexts '((:name "blog"         :scheme #p"./data/boardgame-blog.db" :type :sqlite3)
		    (:name "bgg-newgames" :scheme #p"./data/bgg-games.db"      :type :sqlite3)))

(defmethod boot ((service admin))
  ; edititem
  (wookie:defroute (:post "/data/admin/edititem/") (req res) (edititem-data req res))
  (wookie:defroute (:post "/data/admin/edititem/preview/") (req res) (preview-edititem-data req res))
  (wookie:defroute (:post "/data/admin/edititem/commit/") (req res) (commit-edititem-data req res))
  (wookie:defroute (:post "/data/admin/deleteitem/") (req res) (delete-edititem-data req res))
  ; postpage
  ; blog item
  (wookie:defroute (:post "/data/admin/newitem/preview/") (req res) (preview-newitem-data req res))
  (wookie:defroute (:post "/data/admin/newitem/post/")    (req res) (post-newitem-data req res))
  ; boardgame
;  ("^boardgame-jp-name" boardgame-jp-name)
;  ("^edit-boardgame-jp-name" edit-boardgame-jp-name)
  (wookie:defroute (:post "/data/admin/gamelist/update/") (req res) (update-gamelist-data req res))
;  (wookie:defroute (:get "/data/boardgame/feed/") (req res) (feed-data req res))
;  (wookie:defroute (:get "/data/boardgame/archive/") (req res) (archive-data req res))
;  (wookie:defroute (:get "/data/boardgame/gamelist/") (req res) (gamelist-data req res))
  ; db settings
  (setup-blog-db (cl-ws-object:get-db service :name "blog"))
  (setup-bgg-db  (cl-ws-object:get-db service :name "bgg-newgames")))

;; (wookie:clear-routes)
;; @todo.frontendへの依存部分は本来はここで収める
;(defmethod route ((service boardgame)))

(defmethod shutdown ((service admin)))
