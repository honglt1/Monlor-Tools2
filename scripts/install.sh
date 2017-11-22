#!/bin/ash
#copyright by monlor

clear
echo -n "是否要安装Monlor Tools工具箱? 按任意键继续(Ctrl + C 退出)."
read answer
model=$(cat /proc/xiaoqiang/model)
if [ "$model" == "R2D" ]; then
	userdisk="/userdisk/data"
elif [ "$model" == "R3P" ]; then
	if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?') -eq 0 ]; then
		echo "没有检测到外置储存，是否将配置文件将放在/etc目录?[y/n] "
		read answer
		[ "$answer" == 'y' ] && userdisk=/etc || exit
	else
		userdisk=$(df|awk '/\/extdisks\/sd[a-z][0-9]?/{print $6;exit}')
	fi
else
	echo "不支持你的路由器！"
	exit
fi

mount -o remount,rw /
echo "下载工具箱文件..."
rm -rf /tmp/monlor.zip > /dev/null 2>&1
curl -skLo /tmp/monlor.zip https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/appstore/monlor.zip
[ $? -ne 0 ] && echo "文件下载失败！" && exit
echo "解压工具箱文件"
unzip /tmp/monlor.zip -d /tmp > /dev/null 2>&1
[ $? -ne 0 ] && echo "文件解压失败！" && exit
mv /tmp/monlor /etc
chmod -R +x /etc/monlor/scripts/*
echo "初始化工具箱"
if [ ! -f "/etc/config/monlor" ]; then
	touch /etc/config/monlor
	uci set monlor.tools=config
	uci set monlor.tools.userdisk="$userdisk"
	uci set monlor.tools.xunlei=0
	uci set monlor.tools.ssh_enable=0
	uci commit monlor
fi
/etc/monlor/scripts/init.sh
rm -rf /tmp/monlor.zip
rm -rf /tmp/monlor
echo "工具箱安装完成!"

echo "请前往小米路由器$userdisk目录，编辑隐藏文件.monlor.conf配置工具箱."
