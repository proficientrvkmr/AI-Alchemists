@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set ECR_REPO=proficientrvkmr/%APP_NAME%
set DOCKER_USERNAME=proficientrvkmr
set DOCKER_PASSWORD=a8909206254a
set CONTAINER_ENGINE=podman
set IMAGE_TAG=latest

REM Check if container engine is available
where %CONTAINER_ENGINE% >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: %CONTAINER_ENGINE% is not installed or not in PATH.
    exit /b 1
)

REM Step 1: Build the Spring Boot application using Gradle
echo Building the Spring Boot application...
call gradlew.bat build -x test || (
    echo Gradle build failed!
    exit /b 1
)

REM Step 2: Build the Docker image using the specified container engine
echo Building the Docker image with %CONTAINER_ENGINE%...
call %CONTAINER_ENGINE% build -t %APP_NAME% . || (
    echo Docker image build failed!
    exit /b 1
)

REM Step 3: Authenticate with Docker Hub
echo Authenticating with Docker Hub...
call %CONTAINER_ENGINE% login docker.io --username %DOCKER_USERNAME% --password %DOCKER_PASSWORD% || (
    echo Docker Hub login failed!
    exit /b 1
)

REM Step 4: Tag the Docker image for public ECR
echo Tagging the Docker image for public ECR...
call %CONTAINER_ENGINE% tag %APP_NAME%:latest %ECR_REPO%:%IMAGE_TAG% || (
    echo Docker image tagging failed!
    exit /b 1
)

REM Step 5: Push the Docker image to public ECR
echo Pushing the Docker image to public ECR...
call %CONTAINER_ENGINE% push %ECR_REPO%:%IMAGE_TAG% || (
    echo Docker image push failed!
    exit /b 1
)

echo Docker image pushed successfully!
exit /b 0