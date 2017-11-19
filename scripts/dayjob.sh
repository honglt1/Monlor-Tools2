#!/bin/ash
#copyright by monlor
source base.sh

#检查重启服务
 [ `uci get monlor.shadowsocks.enable` -eq 1 ] && /etc/monlor/apps/shadowsocks/script/shadowsocks.sh restart
 [ `uci get monlor.koolproxy.enable` -eq 1 ] && /etc/monlor/apps/koolproxy/script/koolproxy.sh restart
 [ `uci get monlor.vsftpd.enable` -eq 1 ] && /etc/monlor/apps/vsftpd/script/vsftpd.sh restart
 [ `uci get monlor.aria2.enable` -eq 1 ] && /etc/monlor/apps/aria2/script/aria2.sh restart
 [ `uci get monlor.webshell.enable` -eq 1 ] && /etc/monlor/apps/webshell/script/webshell.sh restart
 [ `uci get monlor.tinyproxy.enable` -eq 1 ] && /etc/monlor/apps/tinyproxy/script/tinyproxy.sh restart
 [ `uci get monlor.frpc.enable` -eq 1 ] && /etc/monlor/apps/frpc/script/frpc.sh restart
 [ `uci get monlor.kms.enable` -eq 1 ] && /etc/monlor/apps/kms/script/kms.sh restart
