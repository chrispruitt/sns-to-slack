variable "slack_webhook_url" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "name" {
  type    = string
  default = "sns-to-slack"
}
