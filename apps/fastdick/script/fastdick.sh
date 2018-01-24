#!/bin/ash /etc/rc.common
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1
service=FastDick
appname=fastdick
EXTRA_COMMANDS=" status backup recover"
EXTRA_HELP="        status  Get $appname status"
# port=
BIN=$monlorpath/apps/$appname/bin/$appname
CONF=$monlorpath/apps/$appname/config/$appname.conf
LOG=/var/log/$appname.log

set_config() {

    logsh "【$service】" "检查$appname配置"
    uid=$(uci -q get monlor.$appname.uid)
    pwd=$(uci -q get monlor.$appname.pwd)
    peerid=$(uci -q get monlor.$appname.peerid)
    if [ -z "$uid" ] || [ -z "pwd" ] || [ -z "peerid" ]; then
        logsh "【$service】" "$appname用户名或密码为空"
        exit
    fi
    uidline=$(cat $BIN | grep -n uid | head -1 | cut -d: -f1)
    pwdline=$(cat $BIN | grep -n pwd | head -1 | cut -d: -f1)
    peerline=$(cat $BIN | grep -n peerid | head -1 | cut -d: -f1)
    #设置用户名密码
    sed -i ""$uidline"s#.*#uid=$uid#" $BIN
    sed -i ""$pwdline"s#.*#pwd=$pwd#" $BIN
    sed -i ""$peerline"s#.*#peerid=$peerid#" $BIN

}

start () {
    
    result=$(ps | grep $BIN | grep -v grep | wc -l)
   	if [ "$result" != '0' ];then
        logsh "【$service】" "$appname已经在运行！"
        exit 1
    fi
    logsh "【$service】" "正在启动$appname服务... "
    set_config
    
    # iptables -I INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT 
    service_start $BIN
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
    # iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1

}

restart () {

    stop
    sleep 1
    start

}

status() {

    result=$(ps | grep $BIN | grep -v grep | wc -l)
    if [ "$result" == '0' ]; then
        echo -e "0\c"
    else
        echo -e "1\c"
    fi

}

backup() {
    echo -n
}

recover() {
    echo -n
}