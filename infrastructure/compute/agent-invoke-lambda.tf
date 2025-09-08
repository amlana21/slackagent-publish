data "aws_ecr_image" "agent_invoke_lambda_image" {
  repository_name = var.app_ecr_repo_name
  image_tag       = var.agent_invoke_lambda_image_tag
}




resource "aws_lambda_function" "agent_invoke_lambda" {
  function_name = "agent-invoke-lambda"
  role          = var.tool_lambda_role_arn
  memory_size = 1024
  timeout       = 300
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app_ecr_repo_name}@${data.aws_ecr_image.agent_invoke_lambda_image.id}"
  package_type  = "Image"
  environment {
    variables = {
      AGENT_ID = var.agent_id
      AGENT_ALIAS = var.agent_alias
      AWS_REGION_NAME = var.region
      RUN_MODE = "remote"
    }
  }
  tags = {
    Name = "agent-tool-lambda"
  }
}

resource "aws_lambda_function_url" "agent_invoke_lambda" {
  function_name      = aws_lambda_function.agent_invoke_lambda.function_name
  authorization_type = "NONE"
}
