(in-package :teck)

;;; getter utility.
(eval-when (:load-toplevel :compile-toplevel)
  (wookie:load-plugins))

(defun get-integer-parameter (value &key lower-limit upper-limit)
  (check-type lower-limit integer)
  (check-type upper-limit integer) 
  (when value
    (skip:whenbind integer-value (parse-integer value :junk-allowed t)
      (when (and (>= integer-value lower-limit) (<= integer-value upper-limit)) integer-value))))

;;; send 
(defun send-data (response data)
  (wookie:send-response response
			:headers '(:content-type "application/json; charset=utf-8" )
			:body (json:encode-json-to-string data)))
