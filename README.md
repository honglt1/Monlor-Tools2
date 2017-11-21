# Monlor-Tools
当前处于2.0版本更新阶段，1.0版本插件移植完毕，放弃nginx和ngrok，添加entware插件支持
## 安装方式：  
	1. git clone到本地，重命名为monlor，移动到小米路由器/etc/文件夹  
	2. 运行/etc/monlor/scripts/init.sh初始化插件中心  
	3. /etc/monlor/scripts/appmanage.sh add /etc/monlor/appstore/shadowsocks.zip安装插件  
	4. 现在安装插件已经支持在线安装，下载源github，安装命令appmanage.sh add shadowsocks
	5. 在/userdisk/data/.monlor.conf里配置插件，请用notepad++编辑配置文件  

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

