#!/bin/ash /etc/rc.common
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

service=Aria2
appname=aria2
EXTRA_COMMANDS=" status backup recover"
EXTRA_HELP="        status  Get $appname status"
port=6800
BIN=$monlorpath/apps/$appname/bin/$appname
CONF=$monlorpath/apps/$appname/config/$appname.conf
LOG=/var/log/$appname.log
port=$(uci -q get monlor.$appname.port) || port=6800
user=$(uci -q get monlor.$appname.user)
passwd=$(uci -q get monlor.$appname.passwd)
path=$(uci -q get monlor.$appname.path) || path="$userdisk/下载"

set_config() {

	logsh "【$service】" "加载$appname配置..."
	[ ! -f /etc/aria2.session ] && touch /etc/aria2.session

	portline=`cat $CONF | grep -n rpc-listen-port | cut -d: -f1`
	[ ! -z "$portline" ] && sed -i ""$portline"s/.*/rpc-listen-port=$port/" $CONF

	userline=`cat $CONF | grep -n rpc-user | cut -d: -f1`
	[ ! -z "$userline" ] && sed -i ""$userline"s/.*/rpc-user=$user/" $CONF

	passwdline=`cat $CONF | grep -n rpc-passwd | cut -d: -f1`
	[ ! -z "$passwdline" ] && sed -i ""$passwdline"s/.*/rpc-passwd=$passwd/" $CONF

	dirline=`cat $CONF | grep -n dir | cut -d: -f1 | head -1`
	[ ! -z "$dirline" ] && sed -i ""$dirline"s#.*#dir=$path#" $CONF
	[ ! -d "$path" ] && mkdir -p $path

	if [ "$model" = 'mips' ];then
		mount -o remount,rw /
		# result1=$(md5sum /lib/libstdc\+\+.so  | awk '{print $1}')
		# result2=$(md5sum $monlorpath/apps/$appname/lib/libstdc\+\+.so.6.0.16 | awk '{print $1}')
		# if [ "$result1" != "$result2" ]; then
		# 	rm -rf /lib/libstdc\+\+.so
		# 	ln -s $monlorpath/apps/$appname/lib/libstdc\+\+.so.6.0.16 /lib/libstdc\+\+.so
		# fi
		# result3=$(md5sum /lib/libstdc\+\+.so.6 | awk '{print $1}')
		# if [ "$result3" != "$result2" ]; then
		# 	rm -rf /lib/libstdc\+\+.so.6
		# 	ln -s $monlorpath/apps/$appname/lib/libstdc\+\+.so.6.0.16 /lib/libstdc\+\+.so.6
		# fi
		# ln -s $monlorpath/apps/$appname/lib/libxml2.so /usr/lib/libxml2.so.2
		result1=$(cat /etc/profile | grep -c "LD_LIBRARY_PATH")
		result2=$(cat /etc/profile | grep -c "$appname")
		if [ "$result2" == '0' ]; then
			if [ "$result1" == '0' ]; then
				echo "export LD_LIBRARY_PATH=/usr/lib:/lib:$monlorpath/apps/$appname/lib" >> /etc/profile
				export LD_LIBRARY_PATH=/usr/lib:/lib:$monlorpath/apps/$appname/lib
			else
				sed -i "s#/usr/lib:/lib#/usr/lib:/lib:$monlorpath/apps/$appname/lib#" /etc/profile
				export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$monlorpath/apps/$appname/lib
			fi
			
		fi
	else 
		[ -d $monlorpath/apps/$appname/lib/ ] && rm -rf $monlorpath/apps/$appname/lib
	fi 

}

start () {

	result=$(ps | grep $BIN | grep -v grep | wc -l)
    if [ "$result" != '0' ];then
		logsh "【$service】" "$appname已经在运行！"
		exit 1
	fi
	logsh "【$service】" "正在启动$appname服务... "

	set_config
	
	iptables -I INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT 
	service_start $BIN --conf-path=$CONF -D -l $LOG
	if [ $? -ne 0 ]; then
        logsh "【$service】" "启动$appname服务失败！"
		exit
    fi
    logsh "【$service】" "启动$appname服务完成！"

}

stop () {

	logsh "【$service】" "正在停止$appname服务... "
	service_stop $BIN
	ps | grep $BIN | grep -v grep | awk '{print$1}' | xargs kill -9 > /dev/null 2>&1
	iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1
	result=$(cat /etc/profile | grep -c "$appname")
	[ "$result" != '0' ] && sed -i "s#:$monlorpath/apps/$appname/lib##" /etc/profile 

}

restart () {

	stop
	sleep 1
	start

}

status() {

	result=$(ps | grep $BIN | grep -v grep | wc -l)
	if [ "$result" == '0' ]; then
		echo "未运行"
		echo "0"
	else
		[ ! -z $user ] && flag1=", 用户名: $user"
		flag2=", 下载路径: $path"
		echo "运行端口号: $port$flag1$flag2"
		echo "1"
	fi

}

backup() {

	mkdir -p $monlorbackup/$appname
	cp -rf $CONF $monlorbackup/$appname/$appname.conf

}

recover() {

	cp -rf $monlorbackup/$appname/$appname.conf $CONF

}