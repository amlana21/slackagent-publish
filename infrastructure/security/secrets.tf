

resource "aws_ssm_parameter" "slack_oauth_token" {
  name  = "/slack/OAUTH_TOKEN"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "slack_signing_secret" {
  name  = "/slack/SIGNING_SECRET"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "slack_app_token" {
  name  = "/slack/APP_TOKEN"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [value]
  }
}