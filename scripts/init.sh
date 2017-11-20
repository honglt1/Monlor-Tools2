#!/bin/ash
#copyright by monlor
source /etc/monlor/scripts/base.sh

mount -o remount,rw /

result=$(cat /etc/profile | grep monlor | wc -l)
if [ "$result" == 0 ]; then
	sed -i "s#/usr/sbin#/usr/sbin:$monlorpath/scripts#" /etc/profile
fi

#result=$(cat /etc/crontabs/root | grep monitor.sh | wc -l)
#if [ "$result" == '0' ]; then
#	echo "* * * * * $monlorpath/scripts/monitor.sh " >> /etc/crontabs/root
#fi

result=$(cat /etc/crontabs/root | grep dayjob.sh | wc -l)
if [ "$result" == '0' ]; then
	echo "30 5 * * * $monlorpath/scripts/dayjob.sh " >> /etc/crontabs/root
fi

result=$(cat /etc/firewall.user | grep init.sh | wc -l) > /dev/null 2>&1
if [ "$result" == '0' ]; then
	echo "$monlorpath/scripts/init.sh" > /etc/firewall.user
fi

if [ ! -f "/etc/config/monlor" ]; then
	ln -s $monlorpath/config/monlor /etc/config/monlor
fi

if [ ! -f "$monlorconf" ]; then
	cp $monlorpath/config/monlor.conf $monlorconf
fi

result=$(ps | grep keepalive | grep -v grep | wc -l)
if [ "$result" == '0' ]; then
	$monlorpath/scripts/keepalive &
fi	

xunlei_enable=$(uci get monlor.tools.xunlei)
if [ "$xunlei_enable" == '1' ]; then
	[ -f /usr/sbin/xunlei.sh ] && mv /usr/sbin/xunlei.sh /usr/sbin/xunlei.sh.bak
	killall xunlei > /dev/null 2>&1
	killall etm > /dev/null 2>&1
	/etc/init.d/xunlei stop &
	rm -rf $userdisk/TDDOWNLOAD 
	rm -rf $userdisk/ThunderDB
else
	[ ! -f /usr/sbin/xunlei.sh ] && mv /usr/sbin/xunlei.sh.bak /usr/sbin/xunlei.sh
	/etc/init.d/xunlei start &
fi

ssh_enable=$(uci get monlor.tools.ssh_enable)
if [ "$ssh_enable" == '1' ]; then
	iptables -I INPUT -p tcp --dport 22 -m comment --comment "monlor-ssh" -j ACCEPT
else 
	iptables -D INPUT -p tcp --dport 22 -m comment --comment "monlor-ssh" -j ACCEPT
fi

$monlorpath/scripts/monitor.sh
$monlorpath/scripts/userscript.sh

