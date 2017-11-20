#!/bin/ash
#copyright by monlor
source base.sh

tail -f /tmp/messages > /userdisk/data/.monlor.log    #日志输出给用户
$userdisk/.monlor.conf
uci commit monlor
uci show monlor | grep install_ | awk -F "_|=" '{print$2}' | while read line
do
	install=$(uci get monlor.tools.install_$line)    #0表示不安装，1表示安装
	installed=$(checkuci $line)    #0表示uci存在，已安装
	if [ "$install" == '1' ] && [ "$installed" == '1' ]; then
		logsh "【Tools】" "$line配置文件已修改，正在安装$line服务..."
		appmanage.sh add $line
	fi
	if [ "$install"  == '0' ] && [ "$installed" == '0' ]; then
		logsh "【Tools】" "$line配置文件已修改，正在卸载$line服务..."
		appmanage.sh del $line
	fi
done
if [ `uci get monlor.tools.uninstall` == '1' ]; then
	$monlorpath/scripts/uninstall.sh
fi

#监控运行状态

