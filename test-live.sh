#!/bin/bash

FUNCTION_NAME=$1
FILTER=$2
find test -type f -name "*$FILTER*"| while read testfile; do
  echo "---:> $testfile"
  aws lambda invoke --function-name $FUNCTION_NAME --payload "fileb://$testfile" /dev/stdout 2>&1
  echo
done
