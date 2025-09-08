

output metrics_agent_id {
    value = aws_bedrockagent_agent.metrics_agent.id
}

output metrics_agent_dev_alias_id {
    value = aws_bedrockagent_agent_alias.metrics_agent_dev_alias.agent_alias_id
}