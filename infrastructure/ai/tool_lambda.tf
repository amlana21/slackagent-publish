data "aws_ecr_image" "agent_tool_lambda_image" {
  repository_name = var.app_ecr_repo_name
  image_tag       = var.tool_lambda_image_tag
}




resource "aws_lambda_function" "agent_tool_lambda" {
  function_name = "agent-tool-lambda"
  role          = var.tool_lambda_role_arn
  memory_size = 1024
  timeout       = 300
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app_ecr_repo_name}@${data.aws_ecr_image.agent_tool_lambda_image.id}"
  package_type  = "Image"
  tags = {
    Name = "agent-tool-lambda"
  }
}