@echo "Start MongoDB"

set MONGO_INITDB_ROOT_USERNAME=admin
set MONGO_INITDB_ROOT_PASSWORD=admin
set MONGO_INITDB_DATABASE=ps-circle-db

call podman stop mongodb
call podman rm mongodb
call podman run -d --name mongodb -p 27017:27017 -v mongo_data:/data/db -e MONGO_INITDB_ROOT_USERNAME=%MONGO_INITDB_ROOT_USERNAME% -e MONGO_INITDB_ROOT_PASSWORD=%MONGO_INITDB_ROOT_PASSWORD% -e MONGO_INITDB_DATABASE=%MONGO_INITDB_DATABASE% mongo:latest

REM mongosh "mongodb://admin:admin@localhost:27017/ps-circle-db"
