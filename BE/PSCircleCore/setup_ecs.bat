@echo off
REM Define variables
set APP_NAME=ps-circle-core-app
set AWS_REGION=us-east-1
set ECS_CLUSTER=ps-hackathon-25-cluster
set ECS_SERVICE=ps-circle-service
set AWS_PROFILE=ps-hackthon-user
set SUBNET_IDS=subnet-08865f08947be15c1,subnet-010b1d7b25c26f32d
set SECURITY_GROUPS=sg-0a803328987f87c53
set TARGET_GROUP_ARN=arn:aws:elasticloadbalancing:us-east-1:487042707842:targetgroup/ps-hackthon-ecs-ip-target-group/135ac2023dbb3de9
set LOAD_BALANCER_NAME=ps-hackthon-lb
set CONTAINER_PORT=8080
set VPC_ID=vpc-0b0fa96228a28e0ef

REM echo Creating ECS cluster...
REM call aws ecs create-cluster --cluster-name %ECS_CLUSTER% --profile %AWS_PROFILE%

REM echo Creating load balancer...
REM call aws elbv2 create-load-balancer --name %LOAD_BALANCER_NAME% --type application --scheme internet-facing --subnets %SUBNET_IDS% --security-groups %SECURITY_GROUPS% --profile %AWS_PROFILE%

REM echo Creating listener...
REM call aws elbv2 create-listener --load-balancer-arn %LOAD_BALANCER_NAME% --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=%TARGET_GROUP_ARN% --profile %AWS_PROFILE%

REM echo Creating target group...
REM call aws elbv2 create-target-group --name ps-hackthon-ecs-ip-target-group --protocol HTTP --port %CONTAINER_PORT% --vpc-id %VPC_ID% --target-type ip

REM Retrieve the latest task definition ARN
echo Retrieving the latest task definition ARN...
for /f "tokens=*" %%i in ('aws ecs describe-task-definition --task-definition %APP_NAME% --query "taskDefinition.taskDefinitionArn" --output text --profile %AWS_PROFILE%') do set LATEST_TASK_DEF_ARN=%%i

REM Check if the ARN was retrieved successfully
if "%LATEST_TASK_DEF_ARN%"=="" (
    echo Failed to retrieve the latest task definition ARN.
    exit /b 1
) else (
    echo Latest task definition ARN: %LATEST_TASK_DEF_ARN%
)

echo Creating service...
call aws ecs create-service --cluster %ECS_CLUSTER% --service-name %ECS_SERVICE% --task-definition %LATEST_TASK_DEF_ARN% --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[%SUBNET_IDS%],securityGroups=[%SECURITY_GROUPS%],assignPublicIp=ENABLED}" --load-balancers targetGroupArn=%TARGET_GROUP_ARN%,containerName=%APP_NAME%,containerPort=%CONTAINER_PORT% --profile %AWS_PROFILE%
