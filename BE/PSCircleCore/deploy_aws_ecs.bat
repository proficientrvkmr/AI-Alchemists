@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set ECR_REPO=public.ecr.aws/v6r7u1w6/ps-hackathon-25/ps-circle-core-repo
set AWS_REGION=us-east-1
set ECS_CLUSTER=ps-hackathon-25-cluster
set ECS_SERVICE=ps-circle-service
set AWS_PROFILE=ps-hackthon-user
set CONTAINER_ENGINE=podman
set DOCKER_IMAGE_TAG=latest
set SUBNET_IDS=subnet-08865f08947be15c1,subnet-010b1d7b25c26f32d
set SECURITY_GROUPS=sg-0a803328987f87c53

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

REM Step 3: Authenticate the container engine to the ECR registry
echo Authenticating %CONTAINER_ENGINE% to ECR...
aws ecr-public get-login-password --region %AWS_REGION% --profile %AWS_PROFILE% | %CONTAINER_ENGINE% login --username AWS --password-stdin public.ecr.aws || exit /b

REM Step 4: Tag the Docker image for public ECR
echo Tagging the Docker image for public ECR...
call %CONTAINER_ENGINE% tag %APP_NAME%:latest %ECR_REPO%:%DOCKER_IMAGE_TAG% || (
    echo Docker image tagging failed!
    exit /b 1
)

REM Step 5: Push the Docker image to public ECR
echo Pushing the Docker image to public ECR...
call %CONTAINER_ENGINE% push %ECR_REPO%:%DOCKER_IMAGE_TAG% || (
    echo Docker image push failed!
    exit /b 1
)

REM Step 6: Register the latest ECS task definition
echo Registering the latest ECS task definition...
aws ecs register-task-definition --cli-input-json file://ps-circle-task-definition.json --profile %AWS_PROFILE% || exit /b

REM Step 7: Retrieve the latest task definition revision
echo Retrieving the latest task definition revision...
for /f "tokens=*" %%i in ('aws ecs describe-task-definition --task-definition %APP_NAME% --query "taskDefinition.taskDefinitionArn" --output text --profile %AWS_PROFILE%') do set LATEST_TASK_DEF_ARN=%%i

REM Step 8: Check if the ECS service exists
echo Checking if the ECS service exists...
aws ecs describe-services --cluster %ECS_CLUSTER% --services %ECS_SERVICE% --profile %AWS_PROFILE% > nul 2>&1

if %errorlevel% neq 0 (
    echo ECS service does not exist. Creating service...
    aws ecs create-service --cluster %ECS_CLUSTER% --service-name %ECS_SERVICE% --task-definition %LATEST_TASK_DEF_ARN% --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[%SUBNET_IDS%],securityGroups=[%SECURITY_GROUPS%],assignPublicIp=ENABLED}" --profile %AWS_PROFILE% || exit /b
) else (
    echo ECS service exists. Updating service with the latest task definition...
    aws ecs update-service --cluster %ECS_CLUSTER% --service %ECS_SERVICE% --task-definition %LATEST_TASK_DEF_ARN% --force-new-deployment --profile %AWS_PROFILE% || exit /b
)

echo Deployment completed successfully!
exit /b 0
