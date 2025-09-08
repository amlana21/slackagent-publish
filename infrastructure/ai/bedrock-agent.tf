
data "aws_caller_identity" "current" {}


resource "aws_bedrockagent_agent" "metrics_agent" {
  agent_name                  = "metrics-agent"
  agent_resource_role_arn     = var.agent_role_arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = "anthropic.claude-3-5-sonnet-20240620-v1:0"
  instruction                 = var.agent_instructions
  prepare_agent               = true
  skip_resource_in_use_check  = true
}



resource "aws_bedrockagent_agent_action_group" "agent_action_grp" {
  action_group_name          = "agent-action-group"
  agent_id                   = aws_bedrockagent_agent.metrics_agent.id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  action_group_state         = "ENABLED"
  prepare_agent              = true
  action_group_executor {
    lambda = aws_lambda_function.agent_tool_lambda.arn
  }
  function_schema {
    member_functions {
      functions {
        name        = "get_s3_metrics"
        description = "Function to get S3 metrics"
      }
      functions {
        name        = "get_ec2_metrics"
        description = "Function to get EC2 metrics"
      }
    }
  }
}

resource "aws_lambda_permission" "bedrock_permission" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.agent_tool_lambda.function_name
  principal     = "bedrock.amazonaws.com"
  source_arn    = aws_bedrockagent_agent.metrics_agent.agent_arn
}

resource "aws_bedrockagent_agent_alias" "ephemeral" {
  agent_id         = aws_bedrockagent_agent.metrics_agent.id
  agent_alias_name = "agent-ephemeral"

  description = "Ephemeral alias used as a hack to trigger new agent version creation."

  depends_on = [aws_bedrockagent_agent.metrics_agent, aws_bedrockagent_agent_action_group.agent_action_grp]

  lifecycle {
    replace_triggered_by = [
      aws_bedrockagent_agent.metrics_agent
    ]
  }
}


resource "aws_bedrockagent_agent_alias" "metrics_agent_dev_alias" {
  agent_alias_name = "dev"
  agent_id         = aws_bedrockagent_agent.metrics_agent.id
  description      = "Dev Alias"
  routing_configuration {
    agent_version = aws_bedrockagent_agent_alias.ephemeral.routing_configuration[0].agent_version
  }

  depends_on = [aws_bedrockagent_agent.metrics_agent, aws_bedrockagent_agent_action_group.agent_action_grp,
  aws_bedrockagent_agent_alias.ephemeral]

}
