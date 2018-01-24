#!/bin/ash
#copyright by monlor
monlorpath=$(uci -q get monlor.tools.path)
[ $? -eq 0 ] && source "$monlorpath"/scripts/base.sh || exit

wgetfilepath="$1"
wgetfilename=$(basename $1)
wgeturl="$2"

result1=$(curl -skL -w %{http_code} -o /tmp/md5.txt $monlorurl/md5.txt)
result2=$(curl -skL -w %{http_code} -o "$wgetfilepath" "$wgeturl")
if [ "$result1" == "200" ] && [ "$result2" == "200" ]; then
	result1=0
else
	result1=1
fi

local_md5=$(md5sum "$wgetfilepath" | cut -d' ' -f1)
origin_md5=$(cat /tmp/md5.txt | grep "$wgetfilename" | cut -d' ' -f4)
[ ${#origin_md5} -lt 32 ] && origin_md5=$(cat /tmp/md5.txt | grep "$wgetfilename" | cut -d' ' -f1)
if [ "$local_md5" == "$origin_md5" ]; then
	result2=0
else
	rm -rf $wgetfilepath
	result2=1
fi

if [ "$result1" == '0' -a "$result2" == '0' ]; then
	echo -n 0
elif [ "$result1" == '1' ]; then
	echo -n 1
elif [ "$result2" == '1' ]; then
	echo -n 2
fi
