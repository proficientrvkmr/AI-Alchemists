@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set ECR_REPO=docker.io/proficientrvkmr/%APP_NAME%
set CONTAINER_ENGINE=podman
set SERVER_PORT=8080
set IMAGE_TAG=latest

REM Check if container engine is available
where %CONTAINER_ENGINE% >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: %CONTAINER_ENGINE% is not installed or not in PATH.
    exit /b 1
)

REM Stop and remove the container if it exists
echo Checking if the container %APP_NAME% is running...
call %CONTAINER_ENGINE% inspect --format '{{.State.Running}}' %APP_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    echo Container found, stopping and removing it...
    call %CONTAINER_ENGINE% stop %APP_NAME% || (
        echo Container stop failed!
        exit /b 1
    )
    call %CONTAINER_ENGINE% rm %APP_NAME% || (
        echo Container removal failed!
        exit /b 1
    )
    echo Container is %APP_NAME% stopped and removed successfully!
)

REM Step 1: Pull the Docker image from public ECR
echo Pulling the Docker image from public ECR...
call %CONTAINER_ENGINE% pull %ECR_REPO%:%IMAGE_TAG% || (
    echo Docker image pull failed!
    exit /b 1
)

REM Step 2: Run the Docker image
echo Running the Docker image...
call %CONTAINER_ENGINE% run --name %APP_NAME% -d -p %SERVER_PORT%:%SERVER_PORT% %ECR_REPO%:%IMAGE_TAG%|| (
    echo Docker image run failed!
    exit /b 1
)

echo Running service locally! http://localhost:%SERVER_PORT%
exit /b 0
