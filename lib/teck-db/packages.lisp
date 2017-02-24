(in-package :cl-user)

(skip:def-in-package :teck-db
  (:use :skip
	:clsql
	:clsql-sqlite3
	:cl-annot
	:annot.class)
  (:export ; <item>
           :<item>
           :itemid-of
	   :update-time-of
	   :date-of
	   :title-of
	   :text-of
	   ; <tag>
	   :<tag>
	   :tagid-of
	   :tag-of
	   ; <item-tag-map>
	   ; itemid-of
	   ; tagid-of
	   ; <bgg-boardgame>
	   :<bgg-boardgame>
	   :guid-of
	   :update-time-of
	   :yearpublished-of
	   :minplayers-of
	   :maxplayers-of
	   :playingtime-of
	   :age-of
	   :name-of
	   :thumbnail-of
	   :image-of
	   :description-of
	   :boardgamemechanic-of
	   :boardgamecategory-of
	   :boardgameversion-of
	   :boardgamedesigner-of
	   :boardgamedesigner
	   :boardgamepublisher-of
	   ; <bgg-collection>
	   :<bgg-collection>
	   :username-of
	   :guid-of
	   :ownp
	   :rating-of
	   :comment-of
	   ; <bgg-newgame>
	   :<bgg-newgame>
	   :id-of
	   :guids-of
	   ; <bgg-boardgame-jpname>
	   :<bgg-boardgame-jpname>
	   :guid-of
	   :jpname-of
	   ))
