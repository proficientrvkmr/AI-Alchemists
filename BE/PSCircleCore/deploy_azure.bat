@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set ACR_NAME=pscirclecorerepo
set RESOURCE_GROUP=ravkushw-hackthon-group
set LOCATION=eastus
set CONTAINER_ENGINE=podman
set DOCKER_IMAGE_TAG=latest
set CONFIG_FILE=docker-compose.yml

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

REM Step 3: Login to ACR
echo Generating ACR access token...
for /f "tokens=*" %%i in ('az acr login --name %ACR_NAME% --expose-token --output tsv --query accessToken') do set ACCESS_TOKEN=%%i

REM Check if ACCESS_TOKEN is set
if "%ACCESS_TOKEN%"=="" (
   echo Failed to retrieve ACR access token.
   exit /b
)

REM Log in to ACR using Podman
echo Logging in to ACR with Podman...
call %CONTAINER_ENGINE% login %ACR_NAME%.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password %ACCESS_TOKEN% || exit /b

REM Step 4: Tag the Docker image for ACR
echo Tagging the Docker image for ACR...
call %CONTAINER_ENGINE% tag %APP_NAME%:latest %ACR_NAME%.azurecr.io/%APP_NAME%:%DOCKER_IMAGE_TAG% || (
    echo Docker image tagging failed!
    exit /b 1
)

REM Step 5: Push the Docker image to ACR
echo Pushing the Docker image to ACR...
call %CONTAINER_ENGINE% push %ACR_NAME%.azurecr.io/%APP_NAME%:%DOCKER_IMAGE_TAG% || (
    echo Docker image push failed!
    exit /b 1
)

call az webapp identity assign --resource-group %RESOURCE_GROUP% --name %APP_NAME%
call az webapp show --resource-group %RESOURCE_GROUP% --name %APP_NAME% --query identity.principalId --output tsv
call az role assignment create --assignee <PRINCIPAL_ID> --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/%RESOURCE_GROUP%/providers/Microsoft.ContainerRegistry/registries/%APP_NAME% --role AcrPull



REM Step 6: Deploy to Azure App Service
echo Checking if Azure App Service exists...
az webapp show --resource-group %RESOURCE_GROUP% --name %APP_NAME% >nul 2>nul
if %errorlevel% neq 0 (
   echo Creating Azure App Service...
   az webapp create --resource-group %RESOURCE_GROUP% --plan ps-circle-service-plan --name %APP_NAME% --multicontainer-config-type compose --multicontainer-config-file %CONFIG_FILE%
   echo Error Level After Create: %errorlevel%
   if %errorlevel% neq 0 (
       echo Azure App Service creation failed!
       exit /b 1
   )
) else (
   echo Updating Azure App Service with new configuration...
   az webapp config container set --name %APP_NAME% --resource-group %RESOURCE_GROUP% --multicontainer-config-type compose --multicontainer-config-file %CONFIG_FILE%
   echo Error Level After Update: %errorlevel%
   if %errorlevel% neq 0 (
       echo Azure App Service update failed!
       exit /b 1
   )
)

echo Deployment completed successfully!
exit /b 0
