appname=koolproxy #monlor-koolproxy
App_enable=$(uci get monlor.$appname.enable)  #monlor-koolproxy
result1=$(ps | grep koolproxy | grep -v grep | wc -l)  #monlor-koolproxy
result2=$(iptables -L -t nat  | grep KOOLPROXY | wc -l)  #monlor-koolproxy
if [ "$App_enable" = '1' ];then  #monlor-koolproxy
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-koolproxy
		logsh "【KoolProxy】" "kp配置已修改，正在重启kp服务..."  #monlor-koolproxy
		restartline=$(cat $monlorconf | grep -n kprestart | cut -d: -f1)  #monlor-koolproxy
		if [ ! -z $restartline ];then    #monlor-koolproxy
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-koolproxy
		else    #monlor-koolproxy
			logsh "【KoolProxy】" "kp配置文件出现问题"    #monlor-koolproxy
		fi    #monlor-koolproxy
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-koolproxy
	elif [ "$result1" == '0' ] || [ "$result2" == '0' ]; then #monlor-koolproxy
		logsh "【KoolProxy】" "kp运行异常，正在重启..."  #monlor-koolproxy
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-koolproxy
	fi  #monlor-koolproxy
elif [ "$App_enable" = '0' ];then  #monlor-koolproxy
	if [ "$result1" != '0' ] || [ "$result2" != '0' ]; then    #monlor-koolproxy
		logsh "【KoolProxy】" "kp配置已修改，正在停止kp服务..."  #monlor-koolproxy
   		$monlorpath/apps/$appname/script/$appname.sh stop  #monlor-koolproxy
	fi    #monlor-koolproxy
fi  #monlor-koolproxy
