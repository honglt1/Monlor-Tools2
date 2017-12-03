# Monlor-Tools
	工具箱正处于测试状态，需要安装的注意一下，要有一定的动手能力，出问题会用U盘刷固件。
	目前支持了以下几种插件(暂时只支持R2D, R3P):
		1. ShadowSocks
		2. KoolProxy
		3. Aria2
		4. VsFtpd
		5. Kms
		6. Frpc
		7. WebShell
		8. TinyProxy
		9. Entware
	因为不会js所以没有web界面，完全靠Shell开发，插件的安装、卸载、配置由配置文件完成。
	配置文件也是一个Shell脚本，请按要求正确的修改配置文件。
		
## 安装方式：  
#### 	手动安装插件
	1. 下载install.sh文件到路由器的/tmp目录
	2. 执行chmod +x /tmp/install.sh && /tmp/install.sh安装
	3. 执行source /etc/profile 使环境变量生效
	4. 在/userdisk/data/.monlor.conf里配置插件，请用notepad++编辑
	5. 离线安装插件，appmanage.sh add /tmp/kms.tar.gz安装插件 
	6. 在线安装插件，下载源coding.net，安装命令appmanage.sh add kms

#### 	懒人一键安装命令
	curl -skLo /tmp/install.sh https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh && source /etc/profile

## 工具箱命令：
	1. 卸载：uninstall.sh
	2. 更新：update.sh
	3. 初始化：init.sh 
	4. 插件管理：appmanage.sh add|upgrade|del appname

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

