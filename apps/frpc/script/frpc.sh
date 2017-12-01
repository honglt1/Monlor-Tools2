#!/bin/ash /etc/rc.common
source /etc/monlor/scripts/base.sh

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

service=Frpc
appname=frpc
# port=
BIN=$monlorpath/apps/$appname/bin/$appname
CONF=$monlorpath/apps/$appname/config/$appname.conf
LOG=/var/log/$appname.log

set_config() {

	result1=$(uci show monlor.$appname | grep server | wc -l)
	result2=$(ls $monlorpath/apps/$appname/config | grep frplist | wc -l)
	if [ "$result1" == '0' -o "$result2" == '0' ]; then
		logsh "【$service】" "$appname配置出现问题！"
		exit
	fi
	server=$(uci get monlor.$appname.server)
	server_port=$(uci get monlor.$appname.server_port)
	token=$(uci get monlor.$appname.token)
	cat > $CONF <<-EOF
	[common]
	server_addr = $server
	server_port = $server_port
	protocol = kcp
	privilege_token = $token
	log_file = $LOG
	log_level = info
	log_max_days = 1
	EOF
	cat $monlorpath/apps/$appname/config/frplist | while read line
	do
		[ -z "$line" ] || [ ${line:0:1} == "#" ] && continue
		echo >> $CONF
		echo "[`cutsh $line 1`]" >> $CONF
		type=`cutsh $line 2`
		echo "type = $type" >> $CONF
		echo "local_ip = `cutsh $line 3`" >> $CONF
		echo "local_port = `cutsh $line 4`" >> $CONF
		if [ "$type" == "tcp" -o "$type" == "udp" ]; then
			echo "remote_port = `cutsh $line 5`" >> $CONF
		fi
		if [ "$type" == "http" -o "$type" == "https" ]; then
			domain=`cutsh $line 6`
			if [ `echo $domain | grep "\." | wc -l` -ne 0 ]; then
				echo "subdomain = $domain" >> $CONF
			else
				echo "custom_domain = $domain" >> $CONF
			fi
		fi
		echo "use_encryption = true" >> $CONF
		echo "use_gzip = false" >> $CONF
	done

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
	service_start $BIN -c $CONF
	if [ $? -ne 0 ]; then
                logsh "【$service】" "启动$appname服务失败！"
		exit
        fi

}

stop () {

	logsh "【$service】" "正在停止$appname服务... "
	service_stop $BIN
	ps | grep $BIN | grep -v grep | awk '{print$1}' | xargs kill -9 > /dev/null 2>&1
	# iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1
	rm -rf $CONF > /dev/null 2>&1

}

restart () {

	stop
	sleep 1
	start

}

