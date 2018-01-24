#!/bin/ash
#copyright by monlor
logger -p 1 -t "【Tools】" "插件管理脚本appmanage.sh启动..."
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

[ -z "$1" -o -z "$2" ] && echo "Usage: $0 {add|upgrade|del} appname" && exit
addtype=`echo $2 | grep -E "/|\." | wc -l`
apppath=$(dirname $2) 
appname=$(basename $2 | cut -d'.' -f1) 
[ "$3" == "-f" ] && force=1 || force=0
[ -z "`uci -q get monlor.tools`" ] && logsh "【Tools】" "工具箱配置文件未创建！" && exit

add() {

	[ $(checkuci $appname) == '0' -a "$force" == '0' ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	if [ "$addtype" == '0' ]; then #检查是否安装在线插件
		#下载插件
		logsh "【Tools】" "正在安装【$appname】在线插件..."
		logsh "【Tools】" "下载【$appname】安装文件"
		result=`$monlorpath/scripts/wget.sh "/tmp/$appname.tar.gz" "$monlorurl/appstore/$appname.tar.gz"`
		if [ "$result" == '1' ]; then
			logsh "【Tools】" "下载【$appname】文件失败！"
			exit
		elif [ "$result" == '2' ]; then
			logsh "【Tools】" "校验【$appname】文件md5失败！"
			exit
		fi
	else
		logsh "【Tools】" "正在安装【$appname】离线插件..."
		[ ! -f "$apppath/$appname.tar.gz" ] && logsh "【Tools】" "未找到离线安装包" && exit
		cp $apppath/$appname.tar.gz /tmp > /dev/null 2>&1
		[ `checkuci $appname` -eq 0 ] && logsh "【Tools】" "插件【$appname】已经安装！" && exit
	fi

	tar -zxvf /tmp/$appname.tar.gz -C /tmp > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		logsh "【Tools】" "解压【$appname】文件失败！" 
		exit
	fi
	
	if [ "$model" == "arm" ]; then
		rm -rf /tmp/$appname/bin/*_mips
	elif [ "$model" == "mips" ]; then
		ls /tmp/$appname/bin | grep -v mips | while read line
		do
			mv /tmp/$appname/bin/"$line"_mips /tmp/$appname/bin/"$line"
		done
	else 
		logsh "【Tools】" "不支持你的路由器！"
		exit
	fi
	
	
	#配置添加到工具箱配置文件
	result=`cat $monlorconf | grep -i "【$appname】" | wc -l`
	if [ "$result" == '0' ]; then
		sed -i '/#monlor-if/d' $monlorconf
		cat /tmp/$appname/install/monlor.conf >> $monlorconf
		echo >> $monlorconf
		echo "if [ ! -z \$param ]; then \$param; else menu; fi #monlor-if" >> $monlorconf
	fi
	#初始化uci配置	
	uci set monlor.$appname=config
	echo " [ \`uci get monlor.$appname.enable\` -eq 1 ] && $monlorpath/apps/$appname/script/$appname.sh restart" >> $monlorpath/scripts/dayjob.sh
	#添加版本信息
	[ ! -d /tmp/version ] && mkdir -p /tmp/version
	cp -rf /tmp/$appname/config/version.txt /tmp/version/$appname.txt
	#安装插件
	rm -rf /tmp/$appname/install
	chmod +x -R /tmp/$appname/
	cp -rf /tmp/$appname $monlorpath/apps
	#清除临时文件
	rm -rf /tmp/$appname
	rm -rf /tmp/$appname.tar.gz
	logsh "【Tools】" "插件【$appname】安装完成"
 
}

upgrade() {
	
	[ $(checkuci $appname) != '0' -a "$force" == '0' ] && logsh "【Tools】" "【$appname】插件未安装！" && exit
	if [ "$force" == '0' ]; then 
		#检查更新
		rm -rf /tmp/version.txt
		result=$(curl -skL -w %{http_code} -o /tmp/version.txt $monlorurl/apps/$appname/config/version.txt)
		[ "$result" != "200" ] && logsh "【Tools】" "检查更新失败！" && exit
		newver=$(cat /tmp/version.txt)
		oldver=$(cat $monlorpath/apps/$appname/config/version.txt) > /dev/null 2>&1
		[ $? -ne 0 ] && logsh "【Tools】" "$appname文件出现问题，请卸载后重新安装" && exit
		logsh "【Tools】" "当前版本$oldver，最新版本$newver"
		[ "$newver" == "$oldver" ] && logsh "【Tools】" "【$appname】已经是最新版！" && exit
		logsh "【Tools】" "版本不一致，正在更新$appname插件... "
	fi
	#卸载插件
	$monlorpath/apps/$appname/script/$appname.sh stop
	#删除插件的配置
	logsh "【Tools】" "正在卸载【$appname】插件..."
	# uci -q del monlor.$appname
	# uci commit monlor
	# rm -rf $monlorpath/apps/$appname > /dev/null 2>&1
	sed -i "/script\/$appname/d" $monlorpath/scripts/dayjob.sh
	ssline1=$(cat $monlorconf | grep -ni "【$appname】" | head -1 | cut -d: -f1)
	ssline2=$(cat $monlorconf | grep -ni "【$appname】" | tail -1 | cut -d: -f1)
	[ ! -z "$ssline1" -a ! -z "$ssline2" ] && sed -i ""$ssline1","$ssline2"d" $monlorconf > /dev/null 2>&1
	#安装服务
	force=1 && add $appname
	logsh "【Tools】" "插件【$appname】更新完成"
	# result=$(uci -q get monlor.$appname.enable)
	# if [ "$result" == '1' ]; then
	# 	logsh "【Tools】" "正在启动【$appname】服务"
	# 	$monlorpath/apps/$appname/script/$appname.sh start
	# fi
}

del() {

	if [ $(checkuci $appname) != '0' -a "$force" == '0' ]; then
		echo -n "【$appname】插件未安装！继续卸载？[y/n] "
		read answer
		[ "$answer" == "n" ] && exit
	fi
	$monlorpath/apps/$appname/script/$appname.sh stop > /dev/null 2>&1
	#删除插件的配置
	logsh "【Tools】" "正在卸载【$appname】插件..."
	uci -q del monlor.$appname
	uci commit monlor
	rm -rf $monlorpath/apps/$appname > /dev/null 2>&1
	sed -i "/script\/$appname/d" $monlorpath/scripts/dayjob.sh
	ssline1=$(cat $monlorconf | grep -ni "【$appname】" | head -1 | cut -d: -f1)
	ssline2=$(cat $monlorconf | grep -ni "【$appname】" | tail -1 | cut -d: -f1)
	[ ! -z "$ssline1" -a ! -z "$ssline2" ] && sed -i ""$ssline1","$ssline2"d" $monlorconf > /dev/null 2>&1
	# install_line=`cat $monlorconf | grep -n install_$appname | cut -d: -f1`           
 	# [ ! -z "$install_line" ] && sed -i ""$install_line"s/1/0/" $monlorconf 
        logsh "【Tools】" "插件【$appname】卸载完成"

}
 

case $1 in
	add) add ;;
	upgrade) upgrade ;;
	del) del ;;
	*) echo "Usage: $0 {add|upgrade|del} appname"
esac
