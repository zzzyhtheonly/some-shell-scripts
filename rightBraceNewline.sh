#!/bin/bash

bak=$IFS
IFS=$'\n'

if [ -f ubuntu.css ]
then
	mv -f ubuntu.css ubuntu_bak.css
fi
touch ubuntu.css

if [ ! -f ubuntu_bak.css ]
then
	exit 0
fi

for line in `cat ubuntu_bak.css`
do
	if [ `echo $line | wc -m` -gt 2 ]
	then
		last=`echo $line | awk -F' ' '{print $NF}'`
		if [ "x$last" == "x}" ]
		then
			echo $line | awk -F' ' '{$NF=null;print $0}' >> $1
			echo "}" >> $1
		else
			echo $line >> $1
		fi
	else
		echo $line >> $1
	fi
done

IFS=$bak
