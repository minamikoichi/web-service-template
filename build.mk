## variables
PWD:=`pwd`
DIST_DIR:=$(PWD)/dist
DIST_HTML_DIR:=$(DIST_DIR)/

## boardgame 
BG_SRC_DIR:=$(PWD)/src/boardgame/view
BG_SRC_TMPL_DIR:=$(BG_SRC_DIR)/tmpl/
BG_DIST_DIR:=$(DIST_DIR)/boardgame/

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
html : html-bg html-bga html-tk
grunt: grunt-bg grunt-bga grunt-tk

# boardgame service
bg   : html-bg   grunt-bg
html-bg: 
	# boardgame html components build	
	@echo "> Generate html files from template files..."
	@./bin/gen-html.lisp $(BG_SRC_TMPL_DIR) $(BG_DIST_DIR)
	@echo "> done."

grunt-bg:
	# grunt build
	@echo "> Generate js , css , image files..."
	@cd $(BG_SRC_DIR) ; npm install ; grunt
	@echo "> done."

# boardgame admin service
bga  : html-bga  grunt-bga
html-bga: 
	# boardgame html components build	
	@echo "> Generate html files from template files..."
	@./bin/gen-html.lisp $(ADMIN_SRC_TMPL_DIR) $(ADMIN_DIST_DIR)
	@echo "> done."

grunt-bga:
	# grunt build
	@echo "> Generate js , css , image files..."
	@cd $(ADMIN_SRC_DIR) ; npm install ; grunt
	@echo "> done."

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

