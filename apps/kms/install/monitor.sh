appname=kms #monlor-kms
App_enable=$(uci get monlor.$appname.enable)  #monlor-kms
result=$(ps | grep kms | grep -v grep | wc -l)  #monlor-kms
if [ "$App_enable" = '1' ];then  #monlor-kms
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-kms
		logsh "【Kms】" "kms配置已修改，正在重启kms服务..."  #monlor-kms
		restartline=$(cat $monlorconf | grep -n kmsrestart | cut -d: -f1)  #monlor-kms
		if [ ! -z $restartline ];then    #monlor-kms
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-kms
		else    #monlor-kms
			logsh "【Kms】" "kms配置文件出现问题"    #monlor-kms
		fi    #monlor-kms
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-kms
	elif [ "$result" == '0' ]; then #monlor-kms
		logsh "【Kms】" "kms运行异常，正在重启..."  #monlor-kms
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-kms
	fi  #monlor-kms
elif [ "$App_enable" = '0' ];then  #monlor-kms
	if [ "$result" != '0' ]; then    #monlor-kms
		logsh "【Kms】" "kms配置已修改，正在停止kms服务..."    #monlor-kms
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-kms
	fi    #monlor-kms
fi  #monlor-kms

