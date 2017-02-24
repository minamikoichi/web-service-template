# web-service-tmpl
Common Lisp WebAPP Template.

## Sample blog service.
   http://doyoulisp.org/teck/
   
## Setup
```
sudo apt-get install nodejs-legacy
sudo apt-get install npm
npm install -g grunt-cli
```

## Build frontend files. 
```
make -f build.mk
```

## Deploy frontend files.
```
rsync -av dist/ $TARGET
```

## Run web service.
```
make -f run.mk
```

## Dependency
- SBCL (Lisp compiler)
- Wookie (WebServer)
- CLSQL (DB)
- grunt (generate css,js)