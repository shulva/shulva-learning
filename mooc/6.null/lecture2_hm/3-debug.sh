#!/bin/bash
count=0

while [ ture ]; do
	((count++))
	./3.sh >./3_log.log 2>>./3_log.log

	if [[ $? -eq 1 ]]; then
		echo "$(cat 3_log.log)"
		echo "loop $count times"
		exit 1
	fi

done
