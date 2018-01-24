#!/bin/ash
#copyright by monlor
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

logsh "【Tools】" "正在更新工具箱程序... "
if [ "$1" != "-f" ]; then
	#检查更新
	rm -rf /tmp/tools_version.txt
	result=$(curl -skL -w %{http_code} -o /tmp/tools_version.txt $monlorurl/config/version.txt)
	[ "$result" != "200" ] && logsh "【Tools】" "检查更新失败！" && exit
	newver=$(cat /tmp/tools_version.txt)
	oldver=$(cat $monlorpath/config/version.txt)
	logsh "【Tools】" "当前版本$oldver，最新版本$newver"
	[ "$newver" == "$oldver" ] && logsh "【Tools】" "工具箱已经是最新版！" && exit
	logsh "【Tools】" "版本不一致，正在更新工具箱..."
fi
rm -rf /tmp/monlor.tar.gz
rm -rf /tmp/monlor
result=$(wget.sh "/tmp/monlor.tar.gz" "$monlorurl/appstore/monlor.tar.gz")
if [ "$result" == '1' ]; then
	logsh "【Tools】" "工具箱文件下载失败！" 
	exit
elif [ "$result" == '2' ]; then
	logsh "【Tools】" "工具箱文件校验失败！"
	exit
fi
logsh "【Tools】" "解压工具箱文件"
tar -zxvf /tmp/monlor.tar.gz -C /tmp > /dev/null 2>&1
[ $? -ne 0 ] && logsh "【Tools】" "文件解压失败！" && exit
logsh "【Tools】" "更新工具箱脚本文件"
rm -rf /tmp/monlor/scripts/dayjob.sh
rm -rf /tmp/monlor/config/monlor.uci
#更新monlor脚本
ssline1=$(cat $monlorconf | grep -ni "【Tools】" | head -1 | cut -d: -f1)
ssline2=$(cat $monlorconf | grep -ni "【Tools】" | tail -1 | cut -d: -f1)
[ ! -z "$ssline1" -a ! -z "$ssline2" ] && sed -i ""$ssline1","$ssline2"d" $monlorconf > /dev/null 2>&1
result=`cat $monlorconf | grep -i "【Tools】" | wc -l`
if [ "$result" == '0' ]; then
	sed -i '/#monlor-if/d' $monlorconf
	sed -i '1,2d' /tmp/monlor/scripts/monlor
	cat /tmp/monlor/scripts/monlor >> $monlorconf
fi
rm -rf /tmp/monlor/scripts/monlor
rm -rf /tmp/monlor/scripts/userscript.sh
cp /tmp/monlor/scripts/* $monlorpath/scripts
logsh "【Tools】" "更新工具箱配置文件"
cp /tmp/monlor/config/* $monlorpath/config
logsh "【Tools】" "赋予可执行权限"
chmod -R +x $monlorpath/scripts/*
chmod -R +x $monlorpath/config/*

#删除临时文件
rm -rf /tmp/monlor.tar.gz
rm -rf /tmp/monlor
logsh "【Tools】" "工具箱更新完成！"