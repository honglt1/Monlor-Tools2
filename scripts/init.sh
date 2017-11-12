#!/bin/ash
#copyright by monlor
source /etc/monlor/scripts/base.sh

mount -o remount,rw /
result=$(cat /etc/crontabs/root | grep monitor.sh | wc -l)
if [ "$result" == "0" ]; then
	echo "* * * * * $monlorpath/scripts/monitor.sh " >> /etc/crontabs/root
fi

result=$(cat /etc/crontabs/root | grep dayjob.sh | wc -l)
if [ "$result" == "0" ]; then
	echo "30 5 * * * $monlorpath/scripts/dayjob.sh " >> /etc/crontabs/root
fi

result=$(cat /etc/firewall.user | grep init.sh | wc -l) > /dev/null 2>&1
if [ "$result" == "0" ]; then
	echo "$monlorpath/scripts/init.sh" > /etc/firewall.user
fi

if [ ! -f "/etc/config/monlor" ]; then
	ln -s $monlorpath/config/monlor /etc/config/monlor
fi

if [ ! -f "$monlorconf" ]; then
	cp $monlorpath/config/monlor.conf $monlorconf
fi

xunlei_enable=$(uci get monlor.tools.xunlei)
if [ "$xunlei_enable" == "1" ]; then
	killall etm
	rm -rf $userdisk/TDDOWNLOAD
	rm -rf $userdisk/ThunderDB
fi

$monlorpath/scripts/userscript.sh

