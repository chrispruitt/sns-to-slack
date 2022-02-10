#!/bin/bash

find test -type f -name "*$1*"| while read testfile; do
  echo "---:> $testfile"
  curl --max-time 10 -w "\n" --data-binary "@$testfile" http://localhost:9001/2015-03-31/functions/myfunction/invocations
  echo
done
