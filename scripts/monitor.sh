#!/bin/ash
#copyright by monlor
source base.sh

$userdisk/.monlor.conf
uci commit monlor
uci show monlor | grep install | awk -F "_|=" '{print$2}' | while read line
do
	install=$(uci get monlor.tools.install_$line)
	installed=$(checkuci $line)
	if [ "$install" == '1' ] && [ "$installed" == '1' ]; then
		logsh "【Tools】" "$line配置文件已修改，正在安装$line服务..."
		appmanage.sh add $line
	fi
	if [ "$install"  == '0' ] && [ "$installed" == '0' ]; then
		logsh "【Tools】" "$line配置文件已修改，正在卸载$line服务..."
		appmanage.sh del $line
	fi
done

#监控运行状态






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
appname=vsftpd #monlor-vsftpd
App_enable=$(uci get monlor.$appname.enable)  #monlor-vsftpd
result=$(ps | grep vsftpd | grep -v grep | wc -l)  #monlor-vsftpd
if [ "$App_enable" = '1' ];then  #monlor-vsftpd
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-vsftpd
		logsh "【VsFtpd】" "ftp配置已修改，正在重启ftp服务..."  #monlor-vsftpd
		restartline=$(cat $monlorconf | grep -n ftprestart | cut -d: -f1)  #monlor-vsftpd
		if [ ! -z $restartline ];then    #monlor-vsftpd
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-vsftpd
		else    #monlor-vsftpd
			logsh "【VsFtpd】" "ftp配置文件出现问题"    #monlor-vsftpd
		fi    #monlor-vsftpd
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-vsftpd
	elif [ "$result" == '0' ]; then #monlor-vsftpd
		logsh "【VsFtpd】" "ftp运行异常，正在重启..."  #monlor-vsftpd
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-vsftpd
	fi  #monlor-vsftpd
elif [ "$App_enable" = '0' ];then  #monlor-vsftpd
	if [ "$result" != '0' ]; then    #monlor-vsftpd
		logsh "【VsFtpd】" "ftp配置已修改，正在停止ftp服务..."  #monlor-vsftpd
   		$monlorpath/apps/$appname/script/$appname.sh stop  #monlor-vsftpd
	fi    #monlor-vsftpd
fi  #monlor-vsftpd
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


appname=webshell #monlor-webshell
App_enable=$(uci get monlor.$appname.enable)  #monlor-webshell
result=$(ps | grep webshell | grep -v grep | wc -l)  #monlor-webshell
if [ "$App_enable" = '1' ];then  #monlor-webshell
	if [ `uci get monlor.$appname.restart` -eq 1 ]; then  #monlor-webshell
		logsh "【webshell】" "webshell配置已修改，正在重启webshell服务..."  #monlor-webshell
		restartline=$(cat $monlorconf | grep -n webshellrestart | cut -d: -f1)  #monlor-webshell
		if [ ! -z $restartline ];then    #monlor-webshell
			sed -i "`expr $restartline + 1`s/.*/\$uciset\.restart=\"0\"/" $monlorconf  #monlor-webshell
		else    #monlor-webshell
			logsh "【webshell】" "webshell配置文件出现问题"    #monlor-webshell
		fi    #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-webshell
	elif [ "$result" == '0' ]; then #monlor-webshell
		logsh "【webshell】" "webshell运行异常，正在重启..."  #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh restart  #monlor-webshell
	fi  #monlor-webshell
elif [ "$App_enable" = '0' ];then  #monlor-webshell
	if [ "$result" != '0' ]; then    #monlor-webshell
		logsh "【webshell】" "webshell配置已修改，正在停止webshell服务..."    #monlor-webshell
		$monlorpath/apps/$appname/script/$appname.sh stop    #monlor-webshell
	fi    #monlor-webshell
fi  #monlor-webshell

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

