FUNCTION_NAME=sns-to-slack
EVENT_FILE=test/sns_event.json
OUPUT_FILE=out.txt
NAME=sns-to-slack

DOCKER_ARGS=--name $(NAME) \
	--rm -d \
	-v "`pwd`/dist":/var/task:ro,delegated \
	--env-file .env \
	-e DOCKER_LAMBDA_STAY_OPEN=1 \
	-p 9001:9001 \
	lambci/lambda:go1.x $(NAME)

.PHONY: test
# test:
# 	SLACK_WEBHOOK=$(SLACK_WEBHOOK) go run main.go sns_event.json

clean:
	rm -rf dist

build: clean
	go mod tidy
	GOOS=linux GOARCH=amd64 go build -o dist/$(NAME) main.go
	cd dist && zip $(NAME).zip $(NAME)
	cp dist/$(NAME).zip tf-module/

start-test-server: build
	docker run --platform linux/amd64 $(DOCKER_ARGS)

stop-test-server:
	docker rm -f $(NAME) || true

test: stop-test-server start-test-server
	sleep 1
	./test.sh $(filter)
	docker logs $(NAME)

push: build
	aws lambda update-function-code --function-name ${FUNCTION_NAME} --zip-file fileb://dist/$(NAME).zip

test-live:
	./test-live.sh $(NAME) $(filter)