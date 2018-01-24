#!/bin/ash
#copyright by monlor
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

logsh "【Tools】" "定时任务crontab.sh启动..."
logger -s -t "【Tools】" "获取更新插件列表"
rm -rf /tmp/applist.txt
[ "$model" == "arm" ] && applist="applist.txt"
[ "$model" == "mips" ] && applist="applist_mips.txt"
result=$(curl -skL -w %{http_code} -o /tmp/applist.txt $monlorurl/config/"$applist")
if [ "$result" == "200" ]; then
	rm -rf $monlorpath/config/applist*.txt
	mv /tmp/applist.txt $monlorpath/config
else 
	logsh "【Tools】" "获取失败，检查网络问题！"
fi

logger -s -t "【Tools】" "获取插件版本信息"
rm -rf /tmp/tools_version.txt
result=$(curl -skL -w %{http_code} -o /tmp/version.txt $monlorurl/config/version.txt)
[ "$result" == "200" ] && mv /tmp/version.txt /tmp/tools_version.txt
mkdir -p /tmp/version > /dev/null 2>&1
cat $monlorpath/config/applist.txt | while read line
do
	if [ ! -z $line ]; then
		result=$(curl -skL -w %{http_code} -o /tmp/version.txt $monlorurl/apps/$line/config/version.txt)
		[ "$result" == "200" ] && mv /tmp/version.txt /tmp/version/$line.txt
	fi
done