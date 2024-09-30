#!/bin/bash
ndomain=`echo $2|cut -d '/' -f 3`;
mirrorurl="ghp.ci";
case $ndomain in 
	"github.com"|"raw.githubusercontent.com")
		url="https://"$mirrorurl/$2;
#		url=$2;
#		echo "$url"
		;;
	*)
		url=$2;
		;;
esac
echo  -e "download from $url\n"
/usr/bin/axel -n 4 -a -o $1 $url
