#!/bin/sh
#copyright by monlor

monlorurl="https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master"
#monlorurl="https://raw.githubusercontent.com/monlor/Monlor-Tools/master"
monlorpath="/etc/monlor"
userdisk="||||||"
monlorconf="$userdisk/.monlor.conf"

result=$(cat /proc/xiaoqiang/model)
case "$result" in
	"R2D") model="arm" ;;
	"R3P") model="mips" ;;
esac

checkuci() {
	[ ! -z "$1" ] && uciname="$1" || uciname="$scriptname" 
	uci -q show monlor.$uciname
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


