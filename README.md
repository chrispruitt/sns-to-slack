# slack-notifications

![alt text](https://github.com/chrispruitt/sns-to-slack/image.jpg?raw=true)

## Deploy with terraform 

```terraform
module "sns-to-slack" {
  source = "github.com/chrispruitt/sns-to-slack//tf-module?ref=v0.1.0"

  slack_webhook_url = "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXXXXX/XXXXXXXX"
  sns_topic_arn     = data.aws_sns_topic.alarms.arn
}

data "aws_sns_topic" "alarms" {
  name = "some-sns-topic"
}
```

## Development

 - Create a slack app with a webhook
 - Copy .env-example to .env and update the env vars
 - Checkout the `Makefile`

```bash
# test locally in a dockerized lambda environment
make test
```
