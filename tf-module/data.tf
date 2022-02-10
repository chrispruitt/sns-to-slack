data "aws_sns_topic" "env_alarms" {
  name = "${terraform.workspace}-alarms"
}
