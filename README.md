# Monlor-Tools
	插件中心目前支持了以下几种插件(暂时只支持R2D):
		1. ShadowSocks
		2. KoolProxy
		3. Aria2
		4. VsFtpd
		5. Kms
		6. Frpc
		7. WebShell
		8. TinyProxy
		9. Entware
	因为不会js所以没有web界面，完全靠Shell开发，插件的安装、卸载、配置由配置文件完成。配置文件也是一个Shell脚本，请按要求正确的修改配置文件。
		
## 安装方式：  
	1. git clone到本地，解压appstore下的monlor.zip到小米路由器/etc/文件夹  
	2. 运行/etc/monlor/scripts/init.sh初始化插件中心，并source /etc/profile
	3. 在/userdisk/data/.monlor.conf里配置插件，请用notepad++编辑

     	#### 手动安装插件
	1. 离线安装 appmanage.sh add /tmp/kms.zip安装插件 
	2. 在线安装，下载源coding.net，安装命令appmanage.sh add kms

	#### 懒人一键安装命令
	curl -sLo /tmp/install.sh https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/scripts/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh && source /etc/profile

## 目录结构：  
	-/etc  
		-/monlor  
			-/apps    插件安装位置  
			-/appstore    存放插件压缩包  
			-/config    插件中心配置  
			-/scripts    插件中心脚本  

## 更新内容：  
	1. 独立化每个插件，方便插件的安装与卸载。  
	2. 通过配置文件安装，修改，卸载插件，简化插件中心管理方式。  

