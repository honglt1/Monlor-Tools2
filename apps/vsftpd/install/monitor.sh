appname=vsftpd #monlor-vsftpd
App_enable=$(uci get monlor.$appname.enable)  #monlor-vsftpd
result=$(ps | grep vsftpd | grep -v grep | wc -l)  #monlor-vsftpd
if [ "$App_enable" = '1' ];then  #monlor-vsftpd
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-vsftpd
		logsh "【VsFtpd】" "vsftpd配置已修改，正在重启vsftpd服务..."  #monlor-vsftpd
		restartline=$(cat $monlorconf | grep -n ftprestart | cut -d: -f1)  #monlor-vsftpd
		if [ ! -z $restartline ];then    #monlor-vsftpd
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-vsftpd
		else    #monlor-vsftpd
			logsh "【VsFtpd】" "vsftpd配置文件出现问题"    #monlor-vsftpd
		fi    #monlor-vsftpd
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-vsftpd
	elif [ "$result" == '0' ]; then #monlor-vsftpd
		logsh "【VsFtpd】" "vsftpd运行异常，正在重启..."  #monlor-vsftpd
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-vsftpd
	fi  #monlor-vsftpd
elif [ "$App_enable" = '0' ];then  #monlor-vsftpd
	if [ "$result" != '0' ]; then    #monlor-vsftpd
		logsh "【VsFtpd】" "vsftpd配置已修改，正在停止vsftpd服务..."  #monlor-vsftpd
   		$monlorpath/apps/$appname/script/$appname.sh stop  #monlor-vsftpd
	fi    #monlor-vsftpd
fi  #monlor-vsftpd
