#!/bin/sh
#copyright by monlor

monlorurl=$(uci -q get monlor.tools.url)
monlorurl_coding="https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master"
monlorurl_github="https://raw.githubusercontent.com/monlor/Monlor-Tools/master"
monlorurl_test="https://coding.net/u/monlor/p/Monlor-Test/git/raw/master"
monlorpath=$(uci -q get monlor.tools.path)
userdisk=$(uci -q get monlor.tools.userdisk)
monlorconf="$monlorpath/scripts/monlor"
monlorbackup="/etc/monlorbackup"

result=$(cat /proc/xiaoqiang/model)
if [ "$result" == "R1D" -o "$result" == "R2D" -o "$result" == "R3D"  ]; then
	model=arm
elif [ "$result" == "R3" -o "$result" == "R3P" -o "$result" == "R3G" -o "$result" == "R1CM" ]; then
	model=mips
fi

checkuci() {
	result=$(uci -q get monlor.$1)
	if [ ! -z "$result" -a -d $monlorpath/apps/$1 ]; then
		echo 0
	else
		echo 1
	fi
}

checkread() {
	if [ "$1" == '1' -o "$1" == '0' ]; then
		echo -n '0'
	else
		echo -n '1'
	fi
}

cutsh() {

	if [ ! -z "$1" -a ! -z "$2" ]; then
		echo `echo $1 | cut -d',' -f$2`
	elif [ ! -z "$1" -a -z "$2" ]; then
		echo `xargs | cut -d',' -f$1`
	else
		echo -n
	fi

}

logsh() {
	
	logger -s -p 1 -t "$1" "$2"
	
}

monitor() {
	appname=$1
	[ `checkuci $appname` -eq 1 ] && return
	service=`uci -q get monlor.$1.service`
	if [ -z $appname ] || [ -z $service ]; then
		logsh "【Tools】" "uci配置出现问题！"
		return
	fi
	App_enable=$(uci -q get monlor.$appname.enable) 
	result=$($monlorpath/apps/$appname/script/$appname.sh status | tail -1) 
	process=$(ps | grep {$appname} | grep -v grep | wc -l)
	
	#检查插件运行异常情况
	if [ "$process" == '0' ]; then
		if [ "$App_enable" == '1' -a "$result" == '0' ]; then
			logsh "【$service】" "$appname运行异常，正在重启..." 
			$monlorpath/apps/$appname/script/$appname.sh restart 
		elif [ "$App_enable" == '0' -a "$result" == '1' ]; then
			logsh "【$service】" "$appname配置已修改，正在停止$appname服务..."   
			$monlorpath/apps/$appname/script/$appname.sh stop
		fi
	fi

}
