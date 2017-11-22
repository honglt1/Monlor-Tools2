appname=entware #monlor-entware
App_enable=$(uci get monlor.$appname.enable)  #monlor-entware
result=$(ls /opt/ | grep etc | grep -v grep | wc -l)  #monlor-entware
if [ "$App_enable" = '1' ];then  #monlor-entware
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-entware
		logsh "【Entware】" "entware配置已修改，正在重启entware服务..."  #monlor-entware
		restartline=$(cat $monlorconf | grep -n entwarerestart | cut -d: -f1)  #monlor-entware
		if [ ! -z $restartline ];then    #monlor-entware
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-entware
		else    #monlor-entware
			logsh "【Entware】" "entware配置文件出现问题"    #monlor-entware
		fi    #monlor-entware
		$monlorpath/apps/$appname/script/$appname.sh start  #monlor-entware
	elif [ "$result" == '0' ]; then #monlor-entware
		logsh "【Entware】" "entware运行异常，正在重启..."  #monlor-entware
		$monlorpath/apps/$appname/script/$appname.sh start  #monlor-entware
	fi  #monlor-entware
elif [ "$App_enable" = '0' ];then  #monlor-entware
	if [ "$result" != '0' ]; then    #monlor-entware
		logsh "【Entware】" "entware配置已修改，正在停止entware服务..."    #monlor-entware
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-entware
	fi    #monlor-entware
fi  #monlor-entware

