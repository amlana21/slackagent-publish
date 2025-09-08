

resource "aws_cloudwatch_log_group" "app-logs" {
  name = "/app-logs"

  retention_in_days = 30
}

resource "aws_ecs_task_definition" "app_task_def" {
  family                   = "app-task-def"
  network_mode             = "awsvpc"
  execution_role_arn       = var.task_role_arn
  task_role_arn            = var.task_role_arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

  container_definitions = <<DEFINITION
[
  {
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/app-repo:bot-server",
    "cpu": 2048,
    "memory": 4096,
    "name": "app-task-container",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      },
      {
        "containerPort": 443,
        "hostPort": 443
      }
    ],
    "environment": [      
        {
          "name"      : "LAMBDA_URL",
          "value" : "${aws_lambda_function_url.agent_invoke_lambda.function_url}"
        }
    ],
    "secrets" : [
        {
          "name"      : "SLACK_OAUTH_TOKEN",
          "valueFrom" : "${var.slack_oauth_token_ssm_param_name}"
        },
        {
          "name"      : "SLACK_SIGNING_SECRET",
          "valueFrom" : "${var.slack_signing_secret_ssm_param_name}"
        },
        {
          "name"      : "SLACK_APP_TOKEN",
          "valueFrom" : "${var.slack_app_token_ssm_param_name}"
        }
      ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/app-logs",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "botserver"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "bot_server_service" {
  name            = "bot-server-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_def.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  network_configuration {
    assign_public_ip = true
    security_groups  = [var.task_sg_id]
    subnets          = var.subnet_ids
  }


  enable_ecs_managed_tags = false
}
