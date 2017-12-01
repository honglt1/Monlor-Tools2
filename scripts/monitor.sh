#!/bin/ash
#copyright by monlor
source /etc/monlor/scripts/base.sh

[ ! -f "$monlorconf" ] && logsh "【Tools】" "找不到配置文件，工具箱异常！" && exit
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
result=$(uci -q get monlor.tools.uninstall)
if [ "$result" == '1' ]; then
	$monlorpath/scripts/uninstall.sh
	exit
fi
result=$(uci -q get monlor.tools.update)
if [ "$result" == '1' ]; then
	$monlorpath/scripts/update.sh
	[ $? -ne 0 ] && logsh "【Tools】" "更新失败！" && exit
fi

#监控运行状态

