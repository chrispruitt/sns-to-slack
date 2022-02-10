package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type SlackMessage struct {
	Text        string       `json:"text"`
	Attachments []Attachment `json:"attachments"`
}

type Attachment struct {
	Text  string `json:"text"`
	Color string `json:"color"`
	Title string `json:"title"`
}

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, event events.SNSEvent) (resp string, err error) {

	for _, record := range event.Records {
		var slackMessage SlackMessage
		var cloudwatchAlarm events.CloudWatchAlarmSNSPayload

		err = json.Unmarshal([]byte(record.SNS.Message), &cloudwatchAlarm)
		if err != nil || cloudwatchAlarm.NewStateValue == "" {
			slackMessage = buildMiscSlackMessage(record.SNS.Message)
		} else {
			slackMessage = buildCloudwatchSlackMessage(cloudwatchAlarm)
		}

		err = postToSlack(slackMessage)
		if err != nil {
			return "", err
		}
	}
	return "Success", nil
}

func buildCloudwatchSlackMessage(cwa events.CloudWatchAlarmSNSPayload) SlackMessage {

	var attachments []Attachment
	var icon string
	var alertColor string

	if cwa.NewStateValue == "OK" {
		icon = ":white_check_mark:"
		alertColor = "#2eb886"
	} else if cwa.NewStateValue == "ALARM" {
		icon = ":rotating_light:"
		alertColor = "danger"
	} else {
		icon = ":warning:"
		alertColor = "#f5a742"
	}

	attachments = append(attachments, Attachment{
		Text:  fmt.Sprintf("%s %s\n*Reason*\n%s\n*Alarm State*\n%s", icon, cwa.AlarmName, cwa.NewStateReason, cwa.NewStateValue),
		Color: alertColor,
	})

	return SlackMessage{
		Text:        "",
		Attachments: attachments,
	}
}

func buildMiscSlackMessage(message string) SlackMessage {

	var attachments []Attachment
	var icon string
	var alertColor string

	icon = ":warning:"
	alertColor = "#f5a742"

	attachments = append(attachments, Attachment{
		Text:  fmt.Sprintf("%s *Misc Message Posted to SNS*\n%s", icon, message),
		Color: alertColor,
	})

	return SlackMessage{
		Text:        "",
		Attachments: attachments,
	}
}

func postToSlack(message SlackMessage) error {
	client := &http.Client{}
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", os.Getenv("SLACK_WEBHOOK"), bytes.NewBuffer(data))
	if err != nil {
		return err
	}

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		fmt.Println(resp.StatusCode)
		return err
	}

	return nil
}
