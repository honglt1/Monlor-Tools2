#!/bin/ash
#copyright by monlor
source /etc/monlor/scripts/base.sh

logsh "【Tools】" "正在更新工具箱程序... "
#检查更新
curl -skLo /tmp/version.txt $monlorurl/config/version.txt 
[ $? -ne 0 ] && logsh "【Tools】" "检查更新失败！" && exit
newver=$(cat /tmp/version.txt)
oldver=$(cat $monlorpath/config/version.txt)
[ "$newver" == "$oldver" ] && logsh "【Tools】" "工具箱已经是最新版！" && exit

rm -rf /tmp/monlor.tar.gz
rm -rf /tmp/monlor
result=$(wget.sh "/tmp/monlor.tar.gz" "$monlorurl/appstore/monlor.tar.gz")
[ "$result" != '0' ] && logsh "【Tools】" "文件下载失败！" && exit
logsh "【Tools】" "解压工具箱文件"
tar -zxvf /tmp/monlor.tar.gz -C /tmp > /dev/null 2>&1
[ $? -ne 0 ] && logsh "【Tools】" "文件解压失败！" && exit
ls /tmp/monlor/scripts | grep -v dayjob | grep -v monitor | while read line
do
	cp /tmp/monlor/scripts/$line $monlorpath/scripts
done
cp /tmp/monlor/config/* $monlorpath/config
chmod -R +x $monlorpath/scripts/*
chmod -R +x $monlorpath/config/*
#更新monlor.conf配置文件
if [ -f $monlorconf ]; then
	# endline=$(cat $monlorconf | grep -ni "【Tools】" | tail -1 | cut -d: -f1)
	# endline=$(expr $endline + 1)
	# sed -n ''"$endline"',$p' $monlorconf > /tmp/monlor.conf
	# cat $monlorpath/config/monlor.conf > $monlorconf
	# cat /tmp/monlor.conf >> $monlorconf
	# rm -rf /tmp/monlor.conf
	cp $monlorpath/config/monlor.conf $monlorconf.new
	chmod +x $monlorconf
fi
#删除临时文件
rm -rf /tmp/monlor.tar.gz
rm -rf /tmp/monlor
logsh "【Tools】" "工具箱更新完成！"