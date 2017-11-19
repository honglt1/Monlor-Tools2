#!/bin/ash
#copyright by monlor
source base.sh

wgetfilepath="$1"
wgetfilename=$(basename $1)
wgeturl="$2"

curl -sLo $monlorpath/config/md5.txt $monlorurl/config/md5.txt
curl -sLo "$wgetfilepath" "$wgeturl"
if [ $? -eq 0 ]; then
	echo 0
else
	echo 1
	exit
fi

local_md5=$(md5sum "$wgetfilepath" | cut -d' ' -f1)
origin_md5=$(cat $monlorpath/config/md5.txt | grep "$wgetfilename" | cut -d' ' -f4)

if [ "$local_md5" == "$origin_md5" ]; then
	echo 0
else
	rm -rf $wgetfilepath
	echo 1
fi

