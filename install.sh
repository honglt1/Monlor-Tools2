#!/bin/ash

[ -f $1 ] && echo "Please input install place!" && exit
[ -d $1/monlor ] && echo "Monlor-Tools is installed!" && exit
[ `cat /proc/xiaoqiang/model` != "R2D" ] && echo "Only support Miwifi R2D!" && exit
clear
echo -n "Sure to install Monlor-Tools?(y/n) "
read ans
[ "$ans" != "y" ] && exit 
curl -Lo /tmp/monlor.tar.gz https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/monlor.tar.gz
mkdir $1/monlor
tar zxvf /tmp/monlor.tar.gz -C $1/monlor
chmod -R +x $1/monlor
$1/monlor/script/allrun install $1/monlor
rm -rf /tmp/monlor.zip
