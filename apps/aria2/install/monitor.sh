appname=aria2 #monlor-aria2
App_enable=$(uci get monlor.$appname.enable)  #monlor-aria2
result=$(ps | grep aria2 | grep -v grep | wc -l)  #monlor-aria2
if [ "$App_enable" = '1' ];then  #monlor-aria2
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-aria2
		logsh "【Aria2】" "aria2配置已修改，正在重启aria2服务..."  #monlor-aria2
		restartline=$(cat $monlorconf | grep -n aria2restart | cut -d: -f1)  #monlor-aria2
		if [ ! -z $restartline ];then    #monlor-aria2
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-aria2
		else    #monlor-aria2
			logsh "【Aria2】" "aria2配置文件出现问题"    #monlor-aria2
		fi    #monlor-aria2
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-aria2
	elif [ "$result" == '0' ]; then #monlor-aria2
		logsh "【Aria2】" "aria2运行异常，正在重启..."  #monlor-aria2
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-aria2
	fi  #monlor-aria2
elif [ "$App_enable" = '0' ];then  #monlor-aria2
	if [ "$result" != '0' ]; then    #monlor-aria2
		logsh "【Aria2】" "aria2配置已修改，正在停止aria2服务..."    #monlor-aria2
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-aria2
	fi    #monlor-aria2
fi  #monlor-aria2

