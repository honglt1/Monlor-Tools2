#!/bin/bash
path=~/Documents/Monlor-Tools
cd $path
[ $? -ne 0 ] && echo "Change directory failed!" && exit
find  .  -name  '._*'  -type  f  -print  -exec  rm  -rf  {} \;
if [ "`uname -s`" == "Darwin" ]; then
	md5=md5 
else 
	md5=md5sum
fi
# test version
# curl -skLo /tmp/install.sh https://coding.net/u/monlor/p/Monlor-Test/git/raw/master/install_test.sh && chmod +x /tmp/install.sh && /tmp/install.sh && source /etc/profile

pack() {
	rm -rf monlor/
	rm -rf appstore/*
	rm -rf monlor.tar.gz
	mkdir -p monlor/apps/
	cp -rf config/ monlor/config
	cp -rf scripts/ monlor/scripts
	#test
	cp install.sh install_test.sh
	if [ "`uname -s`" == "Darwin" ]; then
		sed -i "" 's/Monlor-Tools/Monlor-Test/' install_test.sh
	else 
		sed -i 's/Monlor-Tools/Monlor-Test/' install_test.sh
	fi
	tar -zcvf monlor.tar.gz monlor/
	mv monlor.tar.gz appstore/
	rm -rf monlor/
	#pack app
	cd apps/
	ls | while read line
	do
		tar -zcvf $line.tar.gz $line/
	done 
	cd ..
	mv apps/*.tar.gz appstore/
	$md5 appstore/* > md5.txt
}

localgit() {
	git add .
	git commit -m "`date +%Y-%m-%d`"
}

github() {
	git remote rm origin
	git remote add origin https://github.com/monlor/Monlor-Tools.git
	git push origin master -f
}

coding() {
	git remote rm origin
	git remote add origin https://git.coding.net/monlor/Monlor-Tools.git
	git push origin master -f
}

test() {
	git remote rm origin
	git remote add origin https://git.coding.net/monlor/Monlor-Test.git
	git push origin master -f
}

reset() {
	
	git checkout --orphan latest_branch
   	git add -A
  	git commit -am "`date +%Y-%m-%d`"
   	git branch -D master
   	git branch -m master
   #	git push -f origin master
	github
	coding

}

case $1 in 
	all) 
		pack
		localgit
		github
		coding
		;;
	github)
		localgit
		github		
		;;
	coding)
		localgit
		coding
		;;
	push)
		localgit
		github
		coding
		;;
	pack) 
		pack
		;;
	test)
		localgit
		test
		;;
	reset)
		reset
		;;
esac
