#!/bin/ash
#copyright by monlor

clear
echo -n "是否要安装Monlor Tools工具箱? 按任意键继续(Ctrl + C 退出)."
read answer
mount -o remount,rw /
echo "下载工具箱文件..."
curl -Lo /tmp/monlor.zip https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/appstore/monlor.zip
[ $? -ne 0 ] && echo "文件下载失败！" && exit
echo "解压工具箱文件"
unzip /tmp/monlor.zip -d /etc
[ $? -ne 0 ] && echo "文件解压失败！" && exit
chmod -R +x /etc/monlor/scripts/*
echo "初始化工具箱"
/etc/monlor/scripts/init.sh
echo "工具箱安装完成!"
echo "前往小米路由器硬盘根目录隐藏文件.monlor.conf配置工具箱."
