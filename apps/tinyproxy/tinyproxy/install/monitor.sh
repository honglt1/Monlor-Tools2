appname=tinyproxy #monlor-tinyproxy
App_enable=$(uci get monlor.$appname.enable)  #monlor-tinyproxy
result=$(ps | grep tinyproxy | grep -v grep | wc -l)  #monlor-tinyproxy
if [ "$App_enable" = '1' ];then  #monlor-tinyproxy
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-tinyproxy
		logsh "【TinyProxy】" "tinyproxy配置已修改，正在重启tinyproxy服务..."  #monlor-tinyproxy
		restartline=$(cat $monlorconf | grep -n tinyproxyrestart | cut -d: -f1)  #monlor-tinyproxy
		if [ ! -z $restartline ];then    #monlor-tinyproxy
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-tinyproxy
		else    #monlor-tinyproxy
			logsh "【TinyProxy】" "tinyproxy配置文件出现问题"    #monlor-tinyproxy
		fi    #monlor-tinyproxy
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-tinyproxy
	elif [ "$result" == '0' ]; then #monlor-tinyproxy
		logsh "【TinyProxy】" "tinyproxy运行异常，正在重启..."  #monlor-tinyproxy
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-tinyproxy
	fi  #monlor-tinyproxy
elif [ "$App_enable" = '0' ];then  #monlor-tinyproxy
	if [ "$result" != '0' ]; then    #monlor-tinyproxy
		logsh "【TinyProxy】" "tinyproxy配置已修改，正在停止tinyproxy服务..."    #monlor-tinyproxy
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-tinyproxy
	fi    #monlor-tinyproxy
fi  #monlor-tinyproxy

