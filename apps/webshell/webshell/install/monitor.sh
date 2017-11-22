appname=webshell #monlor-webshell
App_enable=$(uci get monlor.$appname.enable)  #monlor-webshell
result=$(ps | grep webshell | grep -v grep | wc -l)  #monlor-webshell
if [ "$App_enable" = '1' ];then  #monlor-webshell
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-webshell
		logsh "【WebShell】" "webshell配置已修改，正在重启webshell服务..."  #monlor-webshell
		restartline=$(cat $monlorconf | grep -n webshellrestart | cut -d: -f1)  #monlor-webshell
		if [ ! -z $restartline ];then    #monlor-webshell
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-webshell
		else    #monlor-webshell
			logsh "【WebShell】" "webshell配置文件出现问题"    #monlor-webshell
		fi    #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-webshell
	elif [ "$result" == '0' ]; then #monlor-webshell
		logsh "【WebShell】" "webshell运行异常，正在重启..."  #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-webshell
	fi  #monlor-webshell
elif [ "$App_enable" = '0' ];then  #monlor-webshell
	if [ "$result" != '0' ]; then    #monlor-webshell
		logsh "【WebShell】" "webshell配置已修改，正在停止webshell服务..."    #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-webshell
	fi    #monlor-webshell
fi  #monlor-webshell

