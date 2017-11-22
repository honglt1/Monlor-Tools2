#!/bin/ash
#copyright by monlor
source /etc/monlor/scripts/base.sh

addtype=`echo $2 | grep -E "/|\." | wc -l`
apppath=$(dirname $2) 
appname=$(basename $2 | cut -d'.' -f1) 

[ `checkuci tools` -ne 0 ] && logsh "【Tools】" "工具箱配置文件未创建！" && exit

add() {

	[ `checkuci $appname` -eq 0 ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	if [ "$addtype" == '0' ]; then #检查是否安装在线插件
		#下载插件
		logsh "【Tools】" "正在安装【$appname】在线插件..."
		result=`$monlorpath/scripts/wget.sh "/tmp/$appname.zip" "$monlorurl/appstore/$appname.zip"`
		if [ "$result" != '0' ]; then
			logsh "【Tools】" "下载【$appname】文件失败！"
			exit
		fi
	else
		logsh "【Tools】" "正在安装【$appname】离线插件..."
		[ ! -f "$apppath/$appname.zip" ] && logsh "【Tools】" "未找到离线安装包" && exit
		cp $apppath/$appname.zip /tmp > /dev/null 2>&1
		[ `checkuci $appname` -eq 0 ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	fi

	unzip -o /tmp/$appname.zip -d /tmp > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		logsh "【Tools】" "解压【$appname】文件失败！" 
		exit
	fi
	
	if [ "$model" == "arm" ]; then
		rm -rf /tmp/$appname/bin/*_mips
	elif [ "$model" == "mips" ]; then
		ls /tmp/$appname/bin | while read line
		do
			mv /tmp/$appname/bin/$line_mips /tmp/$appname/bin/$line
		done
	else 
		logsh "【Tools】" "不支持你的路由器！"
		exit
	fi
	mv /tmp/$appname $monlorpath/apps
	chmod +x -R $monlorpath/apps/$appname
	#将插件的配置添加到工具箱
	$monlorpath/apps/$appname/install/uciset.sh
	#echo >> $monlorpath/scripts/monitor.sh
	cat $monlorpath/apps/$appname/install/monitor.sh >> $monlorpath/scripts/monitor.sh 
	result=`cat $monlorconf | grep -i "【$appname】" | wc -l`
	if [ "$result" == '0' ]; then
		#echo >> $userdisk/.monlor.conf
		cat $monlorpath/apps/$appname/install/monlor.conf >> $monlorconf
	fi
	echo " [ \`uci get monlor.$appname.enable\` -eq 1 ] && $monlorpath/apps/$appname/script/$appname.sh restart" >> $monlorpath/scripts/dayjob.sh
	install_line=`cat $monlorconf | grep -n install_$appname | cut -d: -f1`
	sed -i ""$install_line"s/0/1/" $monlorconf
	#清除临时文件
	rm -rf $monlorpath/apps/$appname/install/
	# rm -rf /tmp/$appname
	rm -rf /tmp/$appname.zip
	logsh "【Tools】" "插件安装完成"

}

upgrade() {
	
	[ `checkuci $appname` -ne 0 ] && logsh "【Tools】" "【$appname】插件未安装！" && exit
	#检查更新
	curl -sLo /tmp/version.txt $monlorurl/apps/$appname/config/version.txt 
	[ $? -ne 0 ] && logsh "【Tools】" "检查更新失败！" && exit
	newver=$(cat /tmp/version.txt)
	oldver=$(cat $monlorpath/apps/$appname/config/version.txt)
	[ "$newver" == "$oldver" ] && logsh "【Tools】" "【$appname】已经是最新版！" && exit
	logsh "【Tools】" "正在更新$appname插件... "
	logsh "【Tools】" "删除旧文件"
	# uci del monlor.$appname > /dev/null 2>&1
	# uci commit monlor
	rm -rf $monlorpath/apps/$appname
	sed -i "/monlor-$appname/d" $monlorpath/scripts/monitor.sh
	sed -i "/script\/$appname/d" $monlorpath/scripts/dayjob.sh
	add $appname > /dev/null 2>&1
	result=$(uci -q get monlor.$appname.enable)
        [ "$result" == '1' ] && $monlorpath/apps/$appname/script/$appname.sh restart
	logsh "【Tools】" "插件更新完成"
}

del() {

	if [ `checkuci $appname` -ne 0 ]; then
		echo -n "【$appname】插件未安装！继续卸载？[y/n] "
		read answer
		[ "$answer" == "n" ] && exit
	fi
	$monlorpath/apps/$appname/script/$appname.sh stop > /dev/null 2>&1
	#删除插件的配置
	logsh "【Tools】" "正在卸载【$appname】插件..."
	uci del monlor.$appname > /dev/null 2>&1
	uci commit monlor
	rm -rf $monlorpath/apps/$appname > /dev/null 2>&1
	sed -i "/monlor-$appname/d" $monlorpath/scripts/monitor.sh
	sed -i "/script\/$appname/d" $monlorpath/scripts/dayjob.sh
	# ssline1=$(cat $monlorconf | grep -ni "【$appname】" | head -1 | cut -d: -f1)
	# ssline2=$(cat $monlorconf | grep -ni "【$appname】" | tail -1 | cut -d: -f1)
	# sed -i ""$ssline1","$ssline2"d" $monlorconf > /dev/null 2>&1
	install_line=`cat $monlorconf | grep -n install_$appname | cut -d: -f1`           
        sed -i ""$install_line"s/1/0/" $monlorconf 
        logsh "【Tools】" "插件卸载完成"

}
 

case $1 in
	add) add ;;
	upgrade) upgrade ;;
	del) del ;;
	*) echo "Usage: $0 {add|upgrade|del}"
esac
