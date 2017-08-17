#!/bin/ash

[ -f $1 ] && echo "Please input install place!" && exit
[ -d $1/monlor ] && echo "Monlor-Tools is installed!" && exit
[ `cat /proc/xiaoqiang/model` != "R2D" ] && echo "Only support Miwifi R2D!" && exit
clear
echo -n "Sure to install Monlor-Tools?(y/n) "
read ans
[ "$ans" != "y" ] && exit 
rm -rf /tmp/monlor.zip
curl -Lo /tmp/monlor.zip https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/app/monlor.zip
mkdir $1/monlor
unzip /tmp/monlor.zip -d $1/monlor || exit
chmod -R +x $1/monlor
$1/monlor/script/allrun install $1/monlor
rm -rf /tmp/monlor.zip
