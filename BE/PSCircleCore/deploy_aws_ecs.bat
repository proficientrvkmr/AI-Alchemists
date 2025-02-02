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
set TARGET_GROUP_ARN=arn:aws:elasticloadbalancing:us-east-1:487042707842:targetgroup/ps-hackthon-ecs-ip-target-group/135ac2023dbb3de9
set LOAD_BALANCER_NAME=ps-hackthon-lb
set CONTAINER_PORT=8080



REM Step 3: Authenticate the container engine to the ECR registry
echo Authenticating %CONTAINER_ENGINE% to ECR...
aws ecr-public get-login-password --region %AWS_REGION% --profile %AWS_PROFILE% | %CONTAINER_ENGINE% login --username AWS --password-stdin public.ecr.aws || exit /b

REM Step 6: Register the latest ECS task definition
echo Registering the latest ECS task definition...
call aws ecs register-task-definition --cli-input-json file://ps-circle-task-definition.json --profile %AWS_PROFILE%

REM Step 7: Retrieve the latest task definition revision
echo Retrieving the latest task definition revision...
for /f "tokens=*" %%i in ('aws ecs describe-task-definition --task-definition %APP_NAME% --query "taskDefinition.taskDefinitionArn" --output text --profile %AWS_PROFILE%') do set LATEST_TASK_DEF_ARN=%%i
echo Latest task definition ARN: %LATEST_TASK_DEF_ARN%

REM Step 8: Updating ECS service exists
echo ECS service exists. Updating service with the latest task definition...
call aws ecs update-service --cluster %ECS_CLUSTER% --service %ECS_SERVICE% --task-definition %LATEST_TASK_DEF_ARN% --force-new-deployment --profile %AWS_PROFILE% || exit /b

echo Deployment completed successfully!
exit /b 0
