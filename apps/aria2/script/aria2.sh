#!/bin/ash /etc/rc.common
source base.sh

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

service=Aria2
appname=aria2
port=6800
BIN=$monlorpath/apps/$appname/bin/$appname
CONF=$monlorpath/apps/$appname/config/$appname.conf
LOG=/var/log/$appname.log

set_config() {

	logsh "【$service】" "加载$appname配置..."
	[ ! -f /etc/aria2.session ] && touch /etc/aria2.session
	port=`uci get monlor.$appname.port` || port=6800
	user=`uci get monlor.$appname.user` > /dev/null 2>&1 || user=
	passwd=`uci get monlor.$appname.passwd` > /dev/null 2>&1 || passwd=

	portline=`cat $CONF | grep -n rpc-listen-port | cut -d: -f1`
	sed -i ""$portline"s/.*/rpc-listen-port=$port/" $CONF

	userline=`cat $CONF | grep -n rpc-user | cut -d: -f1`
	sed -i ""$userline"s/.*/rpc-user=$user/" $CONF

	passwdline=`cat $CONF | grep -n rpc-passwd | cut -d: -f1`
	sed -i ""$passwdline"s/.*/rpc-passwd=$passwd/" $CONF

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

}

stop () {

	logsh "【$service】" "正在停止$appname服务... "
	service_stop $BIN
	ps | grep $BIN | grep -v grep | awk '{print$1}' | xargs kill -9 > /dev/null 2>&1
	iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1

}

restart () {

	stop
	sleep 1
	start

}

