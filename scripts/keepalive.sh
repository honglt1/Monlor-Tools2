#!/bin/ash
source base.sh

while(true) 
do
	sleep 60
	result=$(ps | grep monitor.sh | grep -v grep | wc -l)
	if [ "$result" == '0' ]; then
		$monlorpath/scripts/monitor.sh > /dev/null 2>&1
	fi
done
