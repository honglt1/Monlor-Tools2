appname=shadowsocks #monlor-shadowsocks
App_enable=$(uci get monlor.$appname.enable)  #monlor-shadowsocks
if [ "$App_enable" = '1' ];then  #monlor-shadowsocks
	result1=$(ps | grep ss-redir | grep -v grep | wc -l)  #monlor-shadowsocks
	result2=$(iptables -L -t nat  | grep SHADOWSOCKS | wc -l)  #monlor-shadowsocks
	if [ "$result1" == "0" ] || [ "$result2" == "0" ]; then #monlor-shadowsocks
		logger -t "【ShadowSocks】" "ss运行异常，正在重启..."  #monlor-shadowsocks
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-shadowsocks
	fi  #monlor-shadowsocks
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-shadowsocks
		logger -t "【ShadowSocks】" "ss配置已修改，正在重启ss服务..."  #monlor-shadowsocks
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-shadowsocks
		restartline="$(cat $monlorconf | grep ssrestart | awk '{print NR}') + 1"  #monlor-shadowsocks
		sed -i "$restartlines/.*/$uciset.restart=0/" $monlorconf  #monlor-shadowsocks
	fi  #monlor-shadowsocks
elif [ "$App_enable" = '0' ];then  #monlor-shadowsocks
	logger -t "【ShadowSocks】" "ss配置已修改，正在停止ss服务..."  #monlor-shadowsocks
    $monlorpath/apps/$appname/script/$appname.sh stop  #monlor-shadowsocks
fi  #monlor-shadowsocks
