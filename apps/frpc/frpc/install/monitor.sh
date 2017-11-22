appname=frpc #monlor-frpc
App_enable=$(uci get monlor.$appname.enable)  #monlor-frpc
result=$(ps | grep frpc | grep -v grep | wc -l)  #monlor-frpc
if [ "$App_enable" = '1' ];then  #monlor-frpc
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-frpc
		logsh "【Frpc】" "frpc配置已修改，正在重启frpc服务..."  #monlor-frpc
		restartline=$(cat $monlorconf | grep -n frpcrestart | cut -d: -f1)  #monlor-frpc
		if [ ! -z $restartline ];then    #monlor-frpc
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-frpc
		else    #monlor-frpc
			logsh "【Frpc】" "frpc配置文件出现问题"    #monlor-frpc
		fi    #monlor-frpc
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-frpc
	elif [ "$result" == '0' ]; then #monlor-frpc
		logsh "【Frpc】" "frpc运行异常，正在重启..."  #monlor-frpc
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-frpc
	fi  #monlor-frpc
elif [ "$App_enable" = '0' ];then  #monlor-frpc
	if [ "$result" != '0' ]; then    #monlor-frpc
		logsh "【Frpc】" "frpc配置已修改，正在停止frpc服务..."    #monlor-frpc
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-frpc
	fi    #monlor-frpc
fi  #monlor-frpc

