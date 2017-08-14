#!/bin/ash

[ -f $1 ] && echo "Please input install place!" && exit
curl -Lo /tmp/monlor.zip https://coding.net/u/monlor/p/Monlor-Tools/git/raw/master/monlor.zip
mkdir $1/monlor
unzip /tmp/monlor.zip -d $1/monlor
chmod -R +x $1/monlor
$1/monlor/script/allrun install $1/monlor
