#!/bin/ash
#copyright by monlor
source base.sh

logsh "【Tools】" "正在卸载工具箱..."

logsh "【Tools】" "停止所有插件"

cat $monlorpath/config/version.txt | grep -v monlor | cut -d, -f1 | while read line
do
	[ `checkuci $line` == 0 ] && $monlorpath/apps/$line/scripts/$line.sh stop
done

logsh "【Tools】" "删除所有工具箱文件"

result=$(cat /etc/profile | grep monlor | wc -l)
if [ "$result" != 0 ]; then
	sed -i "s#:$monlorpath/scripts##" /etc/profile
fi

result=$(cat /etc/crontabs/root | grep dayjob.sh | wc -l)
if [ "$result" != '0' ]; then
	sed -i "/dayjob.sh/d" /etc/crontabs/root
fi

result=$(cat /etc/firewall.user | grep init.sh | wc -l) > /dev/null 2>&1
if [ "$result" != '0' ]; then
	sed -i "/init.sh/d" /etc/firewall.user
fi

if [ -f "$monlorconf" ]; then
	rm -rf $monlorconf
fi

result=$(ps | grep keepalive | grep -v grep | wc -l)
if [ "$result" != '0' ]; then
	killall keepalive.sh
fi

xunlei_enable=$(uci get monlor.tools.xunlei)
if [ "$xunlei_enable" == '1' ]; then
	logsh "【Tools】" "检测到迅雷被关闭，正在开启"
	[ ! -f /usr/sbin/xunlei.sh ] && mv /usr/sbin/xunlei.sh.bak /usr/sbin/xunlei.sh
	/etc/init.d/xunlei start &
fi

ssh_enable=$(uci get monlor.tools.ssh_enable)
if [ "$ssh_enable" == '1' ]; then
	iptables -D INPUT -p tcp --dport 22 -m comment --comment "monlor-ssh" -j ACCEPT
fi

rm -rf /userdisk/data/.monlor.log > /dev/null 2>&1

if [ -f "/etc/config/monlor" ]; then
	rm -rf /etc/config/monlor
fi

logsh "【Tools】" "See You!"

rm -rf $monlorpath
