#!/bin/sh
#copyright by monlor

#monlorurl="https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master"
monlorurl="https://raw.githubusercontent.com/monlor/Monlor-Tools/master"
monlorpath="/etc/monlor"
userdisk="/userdisk/data"
monlorconf="$userdisk/.monlor.conf"

model=$(cat /proc/xiaoqiang/model)
[ "$model" != "R2D" ] && logsh "【Tools】" "本工具箱只支持小米路由器R2D!" && exit

checkuci() {
	[ ! -z "$1" ] && uciname="$1" || uciname="$scriptname" 
	uci show monlor.$uciname > /dev/null 2>&1 
	if [ $? -eq 0 ]; then
		echo 0
	else
		echo 1
	fi
}

cutsh() {

    	test1=$1
    	test2=$2
	[ -z "$test2" ] && test2=$test1
	echo `echo $test1 | cut -d, -f$test2`
    
}

logsh() {
	
	logger -s -p 1 -t "$1" "$2"
	
}


