output "task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output "tool_lambda_role_arn" {
    value = aws_iam_role.tool_lambda_role.arn
}

output agent_role_arn {
    value = aws_iam_role.bedrock_role.arn
}