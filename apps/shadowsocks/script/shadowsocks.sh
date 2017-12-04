#!/bin/ash /etc/rc.common
source /etc/monlor/scripts/base.sh

START=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

wan_mode=`ifconfig | grep pppoe-wan | wc -l`
if [ "$wan_mode" = '1' ];then
	wanip=$(ifconfig pppoe-wan | grep "inet addr:" | cut -d: -f2 | awk '{print$1}')
else
	wanip=$(ifconfig eth0.2 | grep "inet addr:" | cut -d: -f2 | awk '{print$1}')
fi
lanip=$(uci get network.lan.ipaddr)
redip=$lanip
service=ShadowSocks
appname=shadowsocks
SER_CONF=$monlorpath/apps/$appname/config/ssserver.conf
CONFIG=$monlorpath/apps/$appname/config/ss.conf
DNSCONF=$monlorpath/apps/$appname/config/dns2socks.conf
SSGCONF=$monlorpath/apps/$appname/config/ssg.conf
chnroute=$monlorpath/apps/$appname/config/chnroute.conf
gfwlist=$monlorpath/apps/$appname/config/gfwlist.conf
customize_black=$monlorpath/apps/$appname/config/customize_black.conf
customize_white=$monlorpath/apps/$appname/config/customize_white.conf
APPPATH=$monlorpath/apps/$appname/bin/ss-redir
SSGBIN=$monlorpath/apps/$appname/bin/ssg-redir
LOCALPATH=$monlorpath/apps/$appname/bin/ss-local
DNSPATH=$monlorpath/apps/$appname/bin/dns2socks
id=`uci get monlor.$appname.id` > /dev/null 2>&1
ssgid=`uci get monlor.$appname.ssgid` > /dev/null 2>&1

get_config() {
    
	logsh "【$service】" "创建ss节点配置文件..."
	local_ip=0.0.0.0
	idinfo=`cat $SER_CONF | grep $id`
	ss_name=`cutsh $idinfo 1`
	ss_server=`cutsh $idinfo 2`
	ss_server_port=`cutsh $idinfo 3`
	ss_password=`cutsh $idinfo 4`
	ss_method=`cutsh $idinfo 5`
	ssr_protocol=`cutsh $idinfo 6`
	ssr_obfs=`cutsh $idinfo 7`
    	
    	ss_server=`resolveip $ss_server` 
    	[ $? -ne 0 ] && logsh "【$service】" "ss服务器地址解析失败" && exit
   	if [ ! -z "$ssr_obfs" ];then
		APPPATH=$monlorpath/apps/$appname/bin/ssr-redir
		LOCALPATH=$monlorpath/apps/$appname/bin/ssr-local
	fi
	#生成配置文件
	echo -e '{\n  "server":"'$ss_server'",\n  "server_port":'$ss_server_port',\n  "local_port":'1081',\n  "local_address":"'$local_ip'",\n  "password":"'$ss_password'",\n  "timeout":600,\n  "method":"'$ss_method'",\n  "protocol":"'$ssr_protocol'",\n  "obfs":"'$ssr_obfs'"\n}' > $CONFIG
	cp $CONFIG $DNSCONF && sed -i 's/1081/1082/g' $DNSCONF
	
	if [ `uci get monlor.$appname.ssgena` == 1 ]; then
		idinfo=`cat $SER_CONF | grep $ssgid`
	    	ssg_name=`cutsh $idinfo 1`
	    	ssg_server=`cutsh $idinfo 2`
	    	ssg_server_port=`cutsh $idinfo 3`
	    	ssg_password=`cutsh $idinfo 4`
	    	ssg_method=`cutsh $idinfo 5`
	    	ssr_protocol=`cutsh $idinfo 6`
		ssr_obfs=`cutsh $idinfo 7`
		if [ ! -z "$ssr_obfs" ]; then
			cp $monlorpath/apps/$appname/bin/ssr-redir $SSGBIN
		else
			cp $monlorpath/apps/$appname/bin/ss-redir $SSGBIN
		fi

		ssg_server=`resolveip $ssg_server` 
    		[ $? -ne 0 ] && logsh "【$service】" "ss游戏服务器地址解析失败" && exit
		echo -e '{\n  "server":"'$ssg_server'",\n  "server_port":'$ssg_server_port',\n  "local_port":'1085',\n  "local_address":"'$local_ip'",\n  "password":"'$ssg_password'",\n  "timeout":600,\n  "method":"'$ssg_method'",\n  "protocol":"'$ssr_protocol'",\n  "obfs":"'$ssr_obfs'"\n}' > $SSGCONF
	fi

}

dnsconfig() {

	insmod ipt_REDIRECT 2>/dev/null
	service_start $LOCALPATH -c $DNSCONF
	killall dns2socks > /dev/null 2>&1
	iptables -t nat -D PREROUTING -s $lanip/24 -p udp --dport 53 -j DNAT --to $redip > /dev/null 2>&1
	logsh "【$service】" "开启dns2socks进程..."
	[ -z "DNS_SERVER" ] && (DNS_SERVER=8.8.8.8;uci set monlor.$appname.dns_server=8.8.8.8)
	[ -z "DNS_SERVER_PORT" ] && (DNS_SERVER_PORT=53;uci set monlor.$appname.dns_port=53)
	DNS_SERVER=$(uci get monlor.$appname.dns_server)
	DNS_SERVER_PORT=$(uci get monlor.$appname.dns_port)
	uci commit monlor
	service_start $DNSPATH 127.0.0.1:1082 $DNS_SERVER:$DNS_SERVER_PORT 127.0.0.1:15353 
	if [ $? -ne 0 ];then
    	logsh "【$service】" "启动失败！"
    	exit
	fi
    
}

get_mode_name() {
	case "$1" in
		0)
			echo "不走代理"
		;;
		1)
			echo "科学上网"
		;;
	esac
}

get_jump_mode(){
	case "$1" in
		0)
			echo "-j"
		;;
		*)
			echo "-g"
		;;
	esac
}

get_action_chain() {
	case "$1" in
		0)
			echo "RETURN"
		;;
		1)
			echo "SHADOWSOCK"
		;;
	esac
}

load_nat() {

    logsh "【$service】" "加载iptables的nat规则..."
    iptables -t nat -N SHADOWSOCKS
    iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d $lanip/24 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d $wanip/16 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d $ss_server -j RETURN
    [ `uci get monlor.$appname.ssgena` == 1 ] && iptables -t nat -A SHADOWSOCKS -d $ssg_server -j RETURN 

    iptables -t nat -N SHADOWSOCK

    #lan access control
    cat $monlorpath/apps/$appname/config/sscontrol.conf | cut -d, -f1 | while read line
    do
    	mac=$line
	proxy_name=$(cat /tmp/dhcp.leases | grep $mac | cut -d' ' -f4)
	proxy_mode=$(cat $monlorpath/apps/$appname/config/sscontrol.conf | grep $mac | cut -d, -f2)
	logsh "【$service】" "加载ACL规则:【$proxy_name】模式为:$(get_mode_name $proxy_mode)"
	iptables -t nat -A SHADOWSOCKS  -m mac --mac-source $mac $(get_jump_mode $proxy_mode) $(get_action_chain $proxy_mode)
    done

    #default alc mode
    ss_acl_default_mode=$(uci get monlor.$appname.ss_acl_default_mode)
	[ -z "$ss_acl_default_mode" ] && ( ss_acl_default_mode=1;uci set monlor.$appname.ss_acl_default_mode=1;uci commit monlor)
	logsh "【$service】" "加载ACL规则:其余主机模式为:$(get_mode_name $ss_acl_default_mode)"
    iptables -t nat -A SHADOWSOCKS -p tcp -j $(get_action_chain $ss_acl_default_mode)
        
	[ ! -f $customize_black ] && touch $customize_black
	[ ! -f $customize_white ] && touch $customize_white

    cat $customize_black | while read line                                                                   
    do                                                                                              
    	echo "server=/.$line/127.0.0.1#15353" >> /etc/dnsmasq.d/customize_black.conf  
        echo "ipset=/.$line/customize_black" >> /etc/dnsmasq.d/customize_black.conf                     
    done
    cat $customize_white | while read line
    do
    	echo "ipset=/.$line/customize_white" >> /etc/dnsmasq.d/customize_white.conf
    done                                                                  
    ipset -N customize_black iphash -!  
    ipset -N customize_white iphash -!	

}

start() {

	[ ! -s $SER_CONF ] && logsh "【$service】" "没有添加ss服务器!" && exit 
	result=$(ps | grep ss-redir | grep -v grep | wc -l)
	if [ "$result" != '0'  ];then
		logsh "【$service】" "SS已经在运行！"	
		exit
	fi

	get_config
	
	dnsconfig            

	load_nat
    	
	logsh "【$service】" "启动ss主进程($id)..."
    ss_mode=$(uci get monlor.$appname.ss_mode)
	case $ss_mode in
    "gfwlist")
        	service_start $APPPATH -b 0.0.0.0 -c $CONFIG   
        	if [ $? -ne 0 ]; then
            	logsh "【$service】" "启动失败！"
            	exit
        	fi
        	ss_gfwlist
        	;;
    "whitelist")
    	service_start $APPPATH -b 0.0.0.0 -c $CONFIG
    	if [ $? -ne 0 ]; then                                                                                                  
                    logsh "【$service】" "启动失败！"                       
                    exit                                
        fi
        ss_whitelist
        ;;
    "wholemode")
        	service_start $APPPATH -b 0.0.0.0 -c $CONFIG 
        	if [ $? -ne 0 ]; then
            	logsh "【$service】" "启动失败！"
            	exit
        	fi
        	ss_wholemode
        	;;
	"empty")
		logsh "【$service】" "未启动ss进程！"
	esac

	if [ `uci get monlor.$appname.ssgena` == 1 ]; then             
        ssg_mode=$(uci get monlor.$appname.ssg_mode)
		logsh "【$service】" "启动ss游戏进程($ssgid)..."
		case $ssg_mode in
		"cngame")
			service_start $SSGBIN -b 0.0.0.0 -u -c $SSGCONF
                	if [ $? -ne 0 ]; then
                       	 	logsh "【$service】" "启动失败！"
                        	exit
                	fi
                	ss_addudp	
                	ss_cngame	
			;;
		"frgame") 
			service_start $SSGBIN -b 0.0.0.0 -u -c $SSGCONF
			if [ $? -ne 0 ]; then
				logsh "【$service】" "启动失败"
				exit
			fi
			ss_addudp
			ss_frgame
			;;
		"empty")
			logsh "【$service】" "未启动ss游戏进程！"
		esac
	fi
	
  	iptablenu=$(iptables -t nat -L PREROUTING | awk '/KOOLPROXY/{print NR}')
	if [ ! -z "$iptablenu" ];then
		iptablenu=`expr $iptablenu - 2`
	else
		iptablenu=2
	fi
    	[ "$ss_mode" == "gfwlist" ] || [ "$ss_mode" == "wholemode" ] || [ "$ss_mode" == "whitelist" ] && iptables -t nat -I PREROUTING $iptablenu -p tcp -j SHADOWSOCKS
	
	/etc/init.d/dnsmasq restart

}


ss_gfwlist() {

	logsh "【$service】" "添加国外黑名单规则..."
	cat $gfwlist $customize_black | while read line                                             
	do                                                                         
		echo "server=/.$line/127.0.0.1#15353" >> /etc/dnsmasq.d/gfwlist_ipset.conf
		echo "ipset=/.$line/gfwlist" >> /etc/dnsmasq.d/gfwlist_ipset.conf  
	done    
	ipset -N gfwlist iphash -!
	iptables -t nat -A SHADOWSOCK -p tcp -m set --match-set customize_white dst -j RETURN
	iptables -t nat -A SHADOWSOCK -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1081

}

ss_whitelist() {

	logsh "【$service】" "添加国外白名单规则..."                                    
	sed -e "s/^/-A nogfwnet &/g" -e "1 i\-N nogfwnet hash:net" $chnroute | ipset -R -!
	iptables -t nat -A SHADOWSOCK -p tcp -m set --match-set customize_black dst -j REDIRECT --to-ports 1081
	iptables -t nat -A SHADOWSOCK -p tcp -m set ! --match-set nogfwnet dst -j REDIRECT --to-ports 1081 
}

ss_addudp() {

	logsh "【$service】" "添加iptables的udp规则..."
	#iptables -t nat -A PREROUTING -s $lanip/24 -p udp --dport 53 -j DNAT --to $lanip
    ip rule add fwmark 0x01/0x01 table 300
    ip route add local 0.0.0.0/0 dev lo table 300
    iptables -t mangle -N SHADOWSOCKS
    iptables -t mangle -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A SHADOWSOCKS -d 127.0.0.1/16 -j RETURN
    iptables -t mangle -A SHADOWSOCKS -d $lanip/16 -j RETURN
    iptables -t mangle -A SHADOWSOCKS -d $wanip/16 -j RETURN
    iptables -t mangle -A SHADOWSOCKS -d $ss_server -j RETURN
    [ `uci get monlor.$appname.ssgena` == 1 ] && iptables -t mangle -A SHADOWSOCKS -d $ssg_server -j RETURN
	iptables -t mangle -A PREROUTING -p udp -j SHADOWSOCKS

	chmod -x /opt/filetunnel/stunserver > /dev/null 2>&1
	killall -9 stunserver > /dev/null 2>&1
}

ss_cngame() {

	logsh "【$service】" "添加国内游戏iptables规则..."
	
	iptables -t mangle -A SHADOWSOCKS -p udp -m set ! --match-set customize_white dst -j TPROXY --on-port 1085 --tproxy-mark 0x01/0x01         

}

ss_frgame() {

	logsh "【$service】" "添加国外游戏iptables规则..."

	[ $ss_mode != "whitelist" ] && sed -e "s/^/-A nogfwnet &/g" -e "1 i\-N nogfwnet hash:net" $chnroute | ipset -R -!
	iptables -t mangle -A SHADOWSOCKS -p udp -m set ! --match-set nogfwnet dst -j TPROXY --on-port 1085 --tproxy-mark 0x01/0x01

}

ss_wholemode() {

	logsh "【$service】" "添加全局模式iptables规则..."
	iptables -t nat -A SHADOWSOCK -p tcp -j REDIRECT --to-ports 1081

}


stop() {
	
	logsh "【$service】" "关闭ss主进程..."
	killall ss-redir > /dev/null 2>&1
	killall ssg-redir > /dev/null 2>&1
	killall ss-local > /dev/null 2>&1
	killall $DNSPATH > /dev/null 2>&1
	#ps | grep dns2socks | grep -v grep | xargs kill -9 > /dev/null 2>&1
	stop_ss_rules

}

stop_ss_rules() {

	logsh "【$service】" "清除iptables规则..."
	cd /tmp
	iptables -t nat -S | grep -E 'SHADOWSOCK|SHADOWSOCKS'| sed 's/-A/iptables -t nat -D/g'|sed 1,2d > clean.sh && chmod 777 clean.sh && ./clean.sh && rm clean.sh
	ip rule del fwmark 0x01/0x01 table 300 &> /dev/null
	ip route del local 0.0.0.0/0 dev lo table 300 &> /dev/null
	iptables -t mangle -D PREROUTING -p udp -j SHADOWSOCKS &> /dev/null
	iptables -t nat -D PREROUTING -p tcp -j SHADOWSOCKS &> /dev/null
	iptables -t mangle -F SHADOWSOCKS &> /dev/null
	iptables -t mangle -X SHADOWSOCKS &> /dev/null
	iptables -t mangle -F SHADOWSOCK &> /dev/null
	iptables -t mangle -X SHADOWSOCK &> /dev/null
	iptables -t nat -F SHADOWSOCK &> /dev/null
	iptables -t nat -X SHADOWSOCK &> /dev/null
	iptables -t nat -F SHADOWSOCKS &> /dev/null
	iptables -t nat -X SHADOWSOCKS &> /dev/null
	ipset destroy nogfwnet &> /dev/null
	ipset destroy gfwlist &> /dev/null
	ipset destroy customize_black &> /dev/null
	ipset destroy customize_white &> /dev/null
	iptables -t nat -D PREROUTING -s $lanip/24 -p udp --dport 53 -j DNAT --to $redip > /dev/null 2>&1
	chmod +x /opt/filetunnel/stunserver > /dev/null 2>&1
	rm -rf $CONFIG
	rm -rf $DNSCONF
	rm -rf $SSGCONF
	rm -rf $SSGBIN
	rm -rf /etc/dnsmasq.d/gfwlist_ipset.conf > /dev/null 2>&1
	rm -rf /etc/dnsmasq.d/customize_*.conf > /dev/null 2>&1
	/etc/init.d/dnsmasq restart
}


restart() 
{
	stop
	
	[ ! -z "$1" ] && uci set monlor.$appname.id="$1"
	[ ! -z "$2" ] && uci set monlor.$appname.ssgid="$2"

	sleep 1
	start

}

