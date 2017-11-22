appname=shadowsocks #monlor-shadowsocks
App_enable=$(uci get monlor.$appname.enable)  #monlor-shadowsocks
result1=$(ps | grep ss-redir | grep -v grep | wc -l)  #monlor-shadowsocks
result2=$(iptables -L -t nat  | grep SHADOWSOCKS | wc -l)  #monlor-shadowsocks
if [ "$App_enable" = '1' ];then  #monlor-shadowsocks
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-shadowsocks
		logsh "【ShadowSocks】" "ss配置已修改，正在重启ss服务..."  #monlor-shadowsocks
		restartline=$(cat $monlorconf | grep -n ssrestart | cut -d: -f1)  #monlor-shadowsocks
		if [ ! -z $restartline ];then    #monlor-shadowsocks
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-shadowsocks
		else    #monlor-shadowsocks
			logsh "【ShadowSocks】" "ss配置文件出现问题"    #monlor-shadowsocks
		fi    #monlor-shadowsocks
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-shadowsocks
	elif [ "$result1" == '0' ] || [ "$result2" == '0' ]; then #monlor-shadowsocks
		logsh "【ShadowSocks】" "ss运行异常，正在重启..."  #monlor-shadowsocks
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-shadowsocks
	fi  #monlor-shadowsocks
elif [ "$App_enable" = '0' ];then  #monlor-shadowsocks
	if [ "$result1" != '0' ] || [ "$result2" != '0' ]; then    #monlor-shadowsocks
		logsh "【ShadowSocks】" "ss配置已修改，正在停止ss服务..."      #monlor-shadowsocks
   		 $monlorpath/apps/$appname/script/$appname.sh stop    #monlor-shadowsocks
	fi    #monlor-shadowsocks
fi    #monlor-shadowsocks
