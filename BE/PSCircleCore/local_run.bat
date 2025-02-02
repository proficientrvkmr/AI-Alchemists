@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set ECR_REPO=public.ecr.aws/v6r7u1w6/ps-hackathon-25/ps-circle-core-repo
set CONTAINER_ENGINE=podman
set DOCKER_IMAGE_TAG=latest

REM Check if container engine is available
where %CONTAINER_ENGINE% >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: %CONTAINER_ENGINE% is not installed or not in PATH.
    exit /b 1
)

REM Stop and remove the container if it exists
echo Checking if the container is running...
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
)

REM Step 1: Pull the Docker image from public ECR
echo Pulling the Docker image from public ECR...
call %CONTAINER_ENGINE% pull %ECR_REPO%:%DOCKER_IMAGE_TAG% || (
    echo Docker image pull failed!
    exit /b 1
)

REM Step 2: Run the Docker image
echo Running the Docker image...
call %CONTAINER_ENGINE% run -d -p 8080:8080 %ECR_REPO%:%DOCKER_IMAGE_TAG% -n %APP_NAME% || (
    echo Docker image run failed!
    exit /b 1
)

echo Running service locally! http://localhost:8080/health
exit /b 0
