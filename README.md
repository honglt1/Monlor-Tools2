# Monlor-Tools
	工具箱正处于测试状态，更新比较频繁，安装要有一定的动手能力，出问题会用U盘刷固件。
	arm路由: R1D R2D R3D , mips路由: R3 R3P R3G R1CM 
	目前支持了以下几种插件:
	1. ShadowSocks 　　　	影梭
	2. KoolProxy　　　　	去广告
	3. Aria2　		下载神器
	4. VsFtpd　		ftp服务器
	5. kms 			Windows激活工具
	6. Frpc 		内网穿透(占用资源较多，建议arm路由使用)
	7. Ngrok		内网穿透(比较轻量级)
	8. WebShell　		网页ssh
	9. TinyProxy		http代理
	10. Entware　		opkg软件包工具(仅支持arm路由)
	11. KodExplorer　	可道云，在线文档管理器(依赖于Entware，仅支持arm路由)
	12. EasyExplorer　	文件传输同步工具(仅支持arm路由)
	13. HttpFile 		http文件查看工具(依赖于Entware，仅支持arm路由)
	14. VerySync		p2p文件同步工具
	工具箱没有web界面，完全靠Shell开发，插件的安装、卸载、配置由配置文件完成。
	安装完成后执行monlor命令配置工具箱，Ctrl + c或者输入exit可以退出。
	才疏学浅，但有一颗学习和折腾的心！
		
## 安装方式：  
#### 	插件的安装
	1. 离线安装插件，appmanage.sh add /tmp/kms.tar.gz安装插件 
	2. 在线安装插件，下载源coding.net，安装命令appmanage.sh add kms
	3. monlor命令安装插件，一键安装

#### 	懒人一键安装命令
	curl -skLo /tmp/install.sh https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh && source /etc/profile 

## 工具箱命令(命令请勿用大写字母)：
	1. 卸载：uninstall.sh
	2. 更新：update.sh [-f]
	3. 初始化：init.sh 
	4. 插件管理：appmanage.sh add|upgrade|del appname [-f]
	5. 工具箱配置：monlor (任意界面Ctrl + c可以退出配置)

## 目录结构：  
	/
	|--- /etc  
	|--- /monlor
	|    |--- /apps/        --- 插件安装位置  
	|    |--- /config/      --- 工具箱配置文件
	|    |--- /scripts/     --- 工具箱脚本
	|--- /tmp
	|    |--- /messages     --- 系统日志，工具箱日志
	|--- /userdisk
	|    |--- /data/        --- 硬盘目录
	|--- /extdisks/
	|    |--- /sd*/         --- 外接盘目录

## 更新内容：  
	2017-11-22
		1. 已支持小米路由器R3P，有需要的可以测试一下，因为没有测试设备，所以不能保证工具箱的正常运行
		2. 更新了安装卸载脚本
		3. 为R3P路由器添加了相应插件的二进制文件
		4. 添加了工具箱更新脚本
		5. 修复了BUG
		6. 更新内容小米路由R2D已成功测试，R3P无法测试

	2017-12-01
		1. 由于小米路由器R3P不支持unzip，插件安装包改为tar压缩方式
		2. 可能是由于小米路由器R2D新版固件原因，插件可能无法开机自启，开机终端运行init.sh解决
		3. 经测试，无法开机自启为脚本问题，已修复

	2017-12-02
		1. 修复了工具箱多处bug

	2017-12-03
		1. 更新脚本，工具箱卸载备份配置，安装时可以恢复配置
		2. 支持了小米路由器R1D, R2D, R3D, R3, R3G, R3P
		3. R2D运行正常，其他型号无法测试
		4. shadowsocks插件增添ssr功能，理论ssr正常了，没账号未测试
		5. 添加mips机型aria2插件的库文件
	
	2017-12-04
		1. 修复了ss脚本bug, ssr已测试正常, ssr游戏模式测试正常
		2. 增加KodExplorer网页文件管理插件，需配合entware安装nginx+php环境
		3. 可以用update.sh命令或者修改配置文件更新下工具箱脚本

	2017-12-05
		1. 增加EasyKodexplorer插件，一款跨设备、点对点文件传输同步工具，详情：http://koolshare.cn/thread-129199-1-1.html

	2017-12-16
		1. 添加了KoolProxy最新vip规则
		2. 优化KodExplorer安装脚本
		3. 更新Frpc 1.1版本，增加配置添加提示
		4. 优化了所有脚本的提示
		5. 修复安装命令BUG

	2017-12-19
		1. 同步更新EasyExplorer二进制版本到0.1.3，支持DLAN了，详情https://github.com/koolshare/ddnsto
		2. 修改了工具箱插件安装逻辑，配置文件更新，建议使用新的配置文件，或重装工具箱

	2017-12-26
		1. 准备修改工具箱配置文件逻辑，方面各个插件的配置

	2017-12-28
		1. 更新插件的配置方式，配置插件更容易了，按提示一步一步操作。
		2. 去除以前的配置文件，新增命令monlor，执行monlor即可轻松配置工具箱，注意Ctrl + c即可退出monlor命令。
		3. 以前的版本建议重装工具箱或更新工具箱和全部插件

	2017-12-29
		1. 修复了更新造成的bug
		2. 新增插件Ngrok

	2017-01-06
		1. 完成了所有功能的终端提示界面
		2. monlor命令可以管理插件，配置插件，更新卸载工具箱，备份恢复插件配置
		3. R3测试了部分插件
		4. 建议重新安装工具箱，安装完成配置好插件后，建议备份配置
		5. 只要路由器不坏，工具箱会坚持更新到有web界面的版本，重在学习

	2017-01-08
		1. 区分mips路由和arm路由的插件列表显示
		2. 完善备份功能，一键备份恢复

	2017-01-09
		1. 修复工具箱安装脚本BUG

	2017-01-10
		1. 增加插件HttpFile基于http的文件查看工具
		2. 增加了ss游戏模式acl局域网设备控制

	2017-01-12
		1. 更新arm的Frpc版本至0.14.1
		2. 修复插件列表更新bug，更新失败的问题

	2017-01-18
		1. 增加文件同步工具verysync，mips路由可能内存不足。

	2017-01-24
		1. 推送了版本号？