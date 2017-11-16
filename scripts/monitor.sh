#!/bin/ash
#copyright by monlor
source base.sh

$userdisk/.monlor.conf
uci commit monlor
uci show monlor | grep install | awk -F "_|=" '{print$2}' | while read line
do
	install=$(uci get monlor.tools.install_$line)
	installed=$(checkuci $line)
	if [ "$install" == 1 ] && [ "$installed" == 1 ]; then
		appmanage.sh add $line
	fi
	if [ "$install"  == 0 ] && [ "$installed" == 0 ]; then
		appmanage.sh del $line
	fi
done

#监控运行状态
