### variables
PWD:=`pwd`

APP_DIR:=$(PWD)/src/
LIB_DIR:=$(PWD)/lib/

### source
all: clean deploy run

run: 
	@./bin/run-app.lisp $(APP_DIR) $(LIB_DIR)

deploy:
	# download libs
	git clone https://github.com/minamikoichi/cl-ws.git lib/cl-ws

clean:
	rm -rf lib/cl-ws
