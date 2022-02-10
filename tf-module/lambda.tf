locals {
  lambda_artifact_path = "${path.module}/sns-to-slack.zip"
}

resource "aws_lambda_function" "slack_notifications" {
  //  Funciton should be pushed from repository
  filename         = local.lambda_artifact_path
  function_name    = var.name
  source_code_hash = filebase64sha256(local.lambda_artifact_path)


  role    = aws_iam_role.lambda_slack_notification.arn
  handler = "sns-to-slack"
  runtime = "go1.x"
  publish = true

  environment {
    variables = {
      SLACK_WEBHOOK = var.slack_webhook_url
    }
  }

  tags = {
    Environment = lower(terraform.workspace)
    Stack       = "lambda_slack_notifications"
  }
}

resource "aws_lambda_permission" "slack_notifications" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifications.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.env_alarms.arn
}

resource "aws_sns_topic_subscription" "slack_notifications" {
  topic_arn = data.aws_sns_topic.env_alarms.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifications.arn
}
