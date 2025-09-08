

variable task_role_arn {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable subnet_ids {
  default=""
}

variable task_sg_id {
  default=""
}

variable slack_oauth_token_ssm_param_name {
  description = "SSM parameter name for Slack OAuth token"
  type        = string
}

variable slack_signing_secret_ssm_param_name {
  description = "SSM parameter name for Slack signing secret"
  type        = string
}

variable slack_app_token_ssm_param_name {
  description = "SSM parameter name for Slack app token"
  type        = string
}

variable app_ecr_repo_name {
  description = "ECR repository name for the application"
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


variable agent_invoke_lambda_image_tag {
  description = "Tag for the agent invoke lambda image in ECR"
  type        = string
}

variable agent_id {
  description = "ID of the agent to invoke"
  type        = string
  default     = ""
}

variable agent_alias {
  description = "Alias of the agent to invoke"
  type        = string
  default     = ""
}