# Create a policy for the lambda functions
resource "aws_iam_policy" "policy" {
  name        = "${terraform.workspace}_lambda_slack_notification"
  path        = "/"
  description = "Policty for lambda slack notifications"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "logs:CreateLogStream",
                "ec2:DescribeNetworkInterfaces",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "ec2:DeleteNetworkInterface",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_slack_notification" {
  name               = "${terraform.workspace}_lambda_slack"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//# Attach IAM policies
resource "aws_iam_role_policy_attachment" "lambda_notifications" {
  role       = aws_iam_role.lambda_slack_notification.name
  policy_arn = aws_iam_policy.policy.arn
}
