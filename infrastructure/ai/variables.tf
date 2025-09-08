

variable agent_instructions {
  description = "Instructions for the agent to follow"
  type        = string
  default     = "You are a helpful agent who answers user question about AWS metrics. You can get the metric details from the tools you have access to.You have multiple tools available."
}

variable agent_role_arn {
  description = "ARN of the IAM role for the Bedrock agent"
  type        = string
}

variable app_ecr_repo_name {
  description = "ECR repository name for the application"
  type        = string
}

variable tool_lambda_image_tag {
  description = "Tag for the tool lambda image in ECR"
  type        = string
}

variable tool_lambda_role_arn {
  description = "ARN of the IAM role for the tool lambda function"
  type        = string
}

variable region {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}