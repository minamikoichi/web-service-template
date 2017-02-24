(in-package :teck)

(def-frontend-config *frontend-config*
  :name "teck"
  :port 4238
  :service '("teck"))

(defservice teck
      name "teck"
      db-contexts '((:name "blog"         :scheme #p"./data/teck-blog.db" :type :sqlite3)))

(defmethod boot ((service teck))
  ; rooting
  (wookie:defroute (:get "/data/teck/") (req res) (blog-data req res))
  (wookie:defroute (:get "/data/teck/view/id/([0-9]+)/") (req res args) (view-select-id-data req res args))
  (wookie:defroute (:get "/data/teck/view/page/([0-9]+)/") (req res args) (view-select-page-data req res args))
  (wookie:defroute (:get "/data/teck/feed/") (req res) (feed-data req res))
  ; db settings
  (setup-blog-db (cl-ws-object:get-db service :name "blog")))

;; (wookie:clear-routes)
;; @todo.frontendへの依存部分は本来はここで収める
;(defmethod route ((service teck)))

(defmethod shutdown ((service teck)))
