#!/bin/sh
#copyright by monlor

monlorurl="https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master"
#monlorurl="https://raw.githubusercontent.com/monlor/Monlor-Tools/master"
monlorpath="/etc/monlor"
userdisk=$(uci get monlor.tools.userdisk)
monlorconf="$userdisk/.monlor.conf"

result=$(cat /proc/xiaoqiang/model)
if [ "$result" == "R1D" -o "$result" == "R2D" -o "$result" == "R3D"  ]; then
	model=arm
elif [ "$result" == "R3" -o "$result" == "R3P" -o "$result" == "R3G" ]; then
	model=mips
fi

checkuci() {
	if [ -z $(uci -q get monlor.$1) ]; then
		echo 1
	else
		echo 0
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


