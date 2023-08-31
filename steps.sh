#!/usr/bin/env bash
alias awsl="aws --endpoint-url=http://localhost:4566"
alias awsf="aws stepfunctions --endpoint-url=http://localhost:8083"

function createFunction() {
  awsl lambda create-function --function-name $@ \
  --runtime nodejs16.x \
  --handler handlers/$@.handler \
  --role arn:aws:iam::012345678901:role/DummyRole \
  --zip-file fileb://dist/$@.zip
}

docker-compose up -d

npm run build

cd dist

zip -r ./hello.zip ./handlers/hello.js
zip -r ./goodbye.zip ./handlers/goodbye.js

cd ..

# create lambdas hello & goodby
createFunction hello && createFunction goodbye

awsf create-state-machine \
  --definition file://state-machine.json \
  --name "InvokeLambdaHelloStateMachine" \
  --role-arn "arn:aws:iam::012345678901:role/DummyRole"

awsf start-execution \
  --state-machine arn:aws:states:us-east-1:123456789012:stateMachine:InvokeLambdaHelloStateMachine \
  --name hello \
  --input "{\"name\": \"wagner\"}"

function shutdown() {
  echo $1
  echo $2
  docker-compose down -v
  exit $3
}

while true; do
  output=$(awsf describe-execution \
  --execution-arn arn:aws:states:us-east-1:123456789012:execution:InvokeLambdaHelloStateMachine:hello 2>&1)

  case $output in
  *'SUCCEEDED'*)
    shutdown "${GREEN}***EXECUTION SUCCESSFUL!***${NC}" "$output" "0"
    ;;

  *'FAILED'*)
    shutdown "${RED}***EXECUTION FAILED!***${NC}" "$output" "1"
    ;;
  esac
done




