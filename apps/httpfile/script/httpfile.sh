#!/bin/ash /etc/rc.common
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

service=HttpFile
appname=httpfile
EXTRA_COMMANDS=" status backup recover"
EXTRA_HELP="        status  Get $appname status"
port=1688
BIN=/opt/sbin/nginx
NGINXCONF=/opt/etc/nginx/nginx.conf
CONF=/opt/etc/nginx/vhost/httpfile.conf
LOG=/var/log/$appname.log
lanip=$(uci get network.lan.ipaddr)
path=$(uci -q get monlor.$appname.path) || path="$userdisk"
port=$(uci -q get monlor.$appname.port) || port=88

set_config() {

	result=$(opkg list-installed | grep -c "^nginx")
	[ "$result" == '0' ] && opkg install nginx
	if [ ! -f "$NGINXCONF".bak ]; then
	 	logsh "【$service】" "检测到nginx未配置, 正在配置..."
		#修改nginx配置文件
		[ ! -x "$BIN" ] && logsh "【$service】" "nginx未安装" && exit
		[ ! -f "$NGINXCONF" ] && logsh "【$service】" "未找到nginx配置文件！" && exit
		cp $NGINXCONF $NGINXCONF.bak
		cat > "$NGINXCONF" <<-\EOF
		user root;
		pid /opt/var/run/nginx.pid;
		worker_processes auto;
		worker_rlimit_nofile 65535;

		events {
		    worker_connections 1024;
		}

		http {

		    include                mime.types;
		    sendfile               on;
		    default_type           application/octet-stream;
		    keepalive_timeout      65;
		    client_max_body_size   4G;
		    include                /opt/etc/nginx/vhost/*.conf;

		}
		EOF
	fi
	# 生成配置文件
	[ ! -d "/opt/etc/nginx/vhost" ] && mkdir -p /opt/etc/nginx/vhost
	rm -rf $CONF
	cat > "$CONF" <<-\EOF
	server {
	        listen  88;
	        server_name  httpfile;
	        charset utf-8;
	        location / {
	            root   directory;
	            index  index.php index.html index.htm;
	            autoindex on;
	            autoindex_exact_size off;
	            autoindex_localtime on;
	        }	     
	}
	EOF
	sed -i "s/88/$port/" $CONF
	sed -i "s#directory#$path#" $CONF

}

start () {

	result=$(ps | grep nginx |  grep -v sysa | grep -v grep | wc -l)
    	if [ "$result" != '0' ] && [ -f "$CONF" ];then
		logsh "【$service】" "$appname已经在运行！"
		exit 1
	fi
	result=$(ps | grep entware.sh | grep -v grep | wc -l)
    	if [ "$result" != '0' ];then
		logsh "【$service】" "检测到【Entware】正在运行，现在启用$appname可能会冲突"
		exit 1
	fi
	logsh "【$service】" "正在启动$appname服务... "
	# 检查entware
	result1=$(uci -q get monlor.entware)
	result2=$(ls /opt | grep etc)
	if [ -z "$result1" ] || [ -z "$result2" ]; then 
		logsh "【$service】" "检测到【Entware】服务未启动或未安装"
		exit
	else
		result3=$(echo $PATH | grep opt)
		[ -z "$result3" ] && export PATH=/opt/bin/:/opt/sbin:$PATH
	fi

	set_config
	
	iptables -I INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT 
	[ ! -f "/opt/etc/init.d/S80nginx" ] && logsh "【$service】" "未找到启动脚本！" && exit
	/opt/etc/init.d/S80nginx start >> /tmp/messages 2>&1
	if [ $? -ne 0 ]; then
        logsh "【$service】" "启动$appname服务失败！"
		exit
    fi
    logsh "【$service】" "启动$appname服务完成！"
    logsh "【$service】" "请在浏览器中访问[http://$lanip:$port]"

}

stop () {

	logsh "【$service】" "正在停止$appname服务... "
	rm -rf $CONF
	result=$(uci -q get monlor.kodexplorer.enable)
	if [ "$result" == '1' ]; then
		/opt/etc/init.d/S80nginx restart >> /tmp/messages 2>&1
	else
		/opt/etc/init.d/S80nginx stop >> /tmp/messages 2>&1
	fi
	iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1

}

restart () {

	stop
	sleep 1
	start

}

status() {

	result=$(ps | grep nginx | grep -v sysa | grep -v grep | wc -l)
	if [ "$result" != '0' ] && [ -f "$CONF" ]; then
		echo "运行端口号: $port, 管理目录: $path"
		echo "1"
	else
		echo "未运行"
		echo "0"
	fi

}

backup() {
	
	mkdir -p $monlorbackup/$appname
	echo -n
}

recover() {
	echo -n
}