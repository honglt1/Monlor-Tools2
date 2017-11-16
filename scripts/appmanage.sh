#!/bin/ash
#copyright by monlor
source base.sh

addtype=$(echo $2 | grep -E "/|\." | wc -l) 
apppath=$(dirname $2) 
appname=$(basename $2 | cut -d'.' -f1) 

[ `checkuci tools` -ne 0 ] && logsh "【Tools】" "工具箱配置文件未创建！" && exit

add() {

	[ `checkuci $appname` -eq 0 ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	if [ "$apptype" == "0" ]; then #检查是否安装在线插件
		#下载插件
		logsh "【Tools】" "正在安装在线插件"
		result=`wget.sh /tmp/$appname.zip $monlorurl/appstore/$appname.zip`
		if [ "$result" -ne 0 ]; then
			logsh "【Tools】" "下载【$appname】文件失败！"
			exit
		fi
	else
		logsh "【Tools】" "正在安装离线插件..."
		[ ! -f "$apppath/$appname.zip" ] && logsh "【Tools】" "未找到离线安装包" && exit
		cp $apppath/$appname.zip /tmp > /dev/null 2>&1
		[ `checkuci $appname` -eq 0 ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	fi

	unzip -o /tmp/$appname.zip -d /tmp > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		logsh "【Tools】" "解压【$appname】文件失败！" 
		exit
	fi
	
	cp -rf /tmp/$appname $monlorpath/apps
	chmod +x -R $monlorpath/apps/$appname
	#将插件的配置添加到工具箱
	$monlorpath/apps/$appname/install/uciset.sh
	echo >> $monlorpath/scripts/monitor.sh
	cat $monlorpath/apps/$appname/install/monitor.sh >> $monlorpath/scripts/monitor.sh 
	result=`cat $monlorconf | grep -i "【$appname】" | wc -l`
	if [ "$result" -eq 0 ]; then
		echo >> $userdisk/.monlor.conf
		cat $monlorpath/apps/$appname/install/monlor.conf >> $monlorconf
	fi
	echo " [ \`uci get monlor.$appname.enable\` -eq 1 ] && $monlorpath/apps/$appname/script/$appname.sh restart" >> $monlorpath/scripts/dayjob.sh
	#清除临时文件
	rm -rf $monlorpath/apps/$appname/install/
	rm -rf /tmp/$appname
	#rm -rf /tmp/$appname.zip

}

upgrade() {

	[ `checkuci $appname` -ne 0 ] && logsh "【Tools】" "【$appname】插件未安装！" && exit
	rm -rf $monlorpath/apps/$appname
	sed -i "/monlor-$appname/d" $monlorpath/scripts/monitor.sh
	#sed -i "/monlor-$appname/d" $userdisk/.monlor.conf
	sed -i "/script\/$appname/d" $monlorpath/scripts/dayjob.sh
	add $appname
	$monlorpath/apps/$appname/script/$appname.sh restart
}

del() {

	if [ `checkuci $appname` -ne 0 ]; then
		echo -n "【$appname】插件未安装！继续卸载？(y/n) "
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
	ssline1=$(cat $monlorconf | grep -ni "【$appname】" | head -1 | cut -d: -f1)
	ssline2=$(cat $monlorconf | grep -ni "【$appname】" | tail -1 | cut -d: -f1)
	sed -i ""$ssline1","$ssline2"d" $monlorconf > /dev/null 2>&1

}
 

case $1 in
	add) add ;;
	upgrade) upgrade ;;
	del) del ;;
esac
