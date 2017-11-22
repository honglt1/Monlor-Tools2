#!/bin/ash
#copyright by monlor
source base.sh

logsh "【Tools】" "正在更新工具箱程序... "
#检查更新
curl -sLo /tmp/version.txt $monlorurl/config/version.txt 
[ $? -ne 0 ] && logsh "【Tools】" "检查更新失败！" && exit
newver=$(cat /tmp/version.txt)
oldver=$(cat $monlorpath/config/version.txt)
[ "$newver" == "$oldver" ] && logsh "【Tools】" "工具箱已经是最新版！" && exit

rm -rf /tmp/monlor.zip
rm -rf /tmp/monlor
result=$(wget.sh "/tmp/monlor.zip" "$monlorurl/appstore/monlor.zip")
[ "$result" != '0' ] && losh "【Tools】" "文件下载失败！" && exit
logsh "【Tools】" "解压工具箱文件"
unzip /tmp/monlor.zip -d /tmp > /dev/null 2>&1
[ $? -ne 0 ] && logsh "【Tools】" "文件解压失败！" && exit
cp -rf /tmp/monlor /etc
chmod -R +x /etc/monlor/scripts/*
chmod -R +x /etc/monlor/config/*
sed -i "s#||||||#$userdisk#" /etc/monlor/scripts/base.sh
#更新monlor.conf配置文件
if [ -f $monlorconf ]; then
	endline=$(cat $monlorconf | grep -ni "【Tools】" | tail -1 | cut -d: -f1)
	sed -n "/"`expr $endline + 1`",\$/p" $monlorconf > /tmp/monlor.conf
	cat /etc/monlor/config/monlor.conf > $monlorconf
	cat /tmp/monlor.conf >> $monlorconf
	rm -rf /tmp/monlor.conf
fi
#删除临时文件

rm -rf /tmp/monlor.zip
rm -rf /tmp/monlor.conf
rm -rf /tmp/monlor
logsh "【Tools】" "工具箱更新完成！"