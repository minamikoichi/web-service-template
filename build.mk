## variables
PWD:=`pwd`
DIST_DIR:=$(PWD)/dist
DIST_HTML_DIR:=$(DIST_DIR)/

## admin
ADMIN_SRC_DIR:=$(PWD)/src/admin/view
ADMIN_SRC_TMPL_DIR:=$(ADMIN_SRC_DIR)/tmpl/
ADMIN_DIST_DIR:=$(DIST_DIR)/admin/

## teck
TECK_SRC_DIR:=$(PWD)/src/teck/view
TECK_SRC_TMPL_DIR:=$(TECK_SRC_DIR)/tmpl/
TECK_DIST_DIR:=$(DIST_DIR)/teck/

## source
all: build
build: html grunt
html : html-tk
grunt: grunt-tk

# teck service
tk   : html-tk grunt-tk
html-tk: 
	# teck html components build	
	@echo "> Generate html files from template files..."
	@./bin/gen-html.lisp $(TECK_SRC_TMPL_DIR) $(TECK_DIST_DIR)
	@echo "> done."

grunt-tk:
	# grunt build
	@echo "> Generate js , css , image files..."
	@cd $(TECK_SRC_DIR) ; npm install ; grunt
	@echo "> done."

