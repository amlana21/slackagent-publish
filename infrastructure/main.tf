terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = ""
}


module "security" {
  source = "./security"
}

module "networking" {
  source = "./networking"
}

module "ai_agent" {
  source = "./ai"
  agent_role_arn = module.security.agent_role_arn
  app_ecr_repo_name = "app-repo"
  tool_lambda_image_tag = "agent-tool"
  tool_lambda_role_arn = module.security.tool_lambda_role_arn
  region = "us-east-1"
  depends_on = [ module.security ]
}

module "compute" {
  source = "./compute"
  task_role_arn = module.security.task_execution_role_arn
  subnet_ids    = module.networking.subnet_ids
  task_sg_id    = module.networking.task_sg_id
  slack_oauth_token_ssm_param_name = "/slack/OAUTH_TOKEN"
  slack_signing_secret_ssm_param_name = "/slack/SIGNING_SECRET"
  slack_app_token_ssm_param_name = "/slack/APP_TOKEN"
  app_ecr_repo_name = "app-repo"
  tool_lambda_role_arn = module.security.tool_lambda_role_arn
  agent_invoke_lambda_image_tag = "agent-invoke"
  region = "us-east-1"
  agent_id = module.ai_agent.metrics_agent_id
  agent_alias = module.ai_agent.metrics_agent_dev_alias_id
  depends_on = [ module.ai_agent, module.networking, module.security]
}

