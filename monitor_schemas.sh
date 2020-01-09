#!/bin/bash

if [ ! -d "test/" ];then
	mkdir "test"
fi

m_pid=()
idx=0
change=()
for schema in $(gsettings list-schemas | sort)
do
	gsettings monitor "$schema" > test/"$schema".test & 
	m_pid[idx]=$!
	change[idx]=0
	let idx+=1
done

echo -e "Start monitoring...\nAny modification will be recorded since now."

while [ 1 ]
do
	ss=ss
	read -t 5 ss
	#read -p "The recent changes will be shown in 5 seconds, if you want to stop monitoring, press s." -t 5 ss
	echo ""
	if [ "k$ss" == "ks" ]
	then
		break
	fi
	idx=0
	for file in `ls "test" | sort`
	do
		cur=`cat test/$file | wc -l`
		if [ k$cur != k${change[idx]} ]
		then
			change[idx]=$cur
			echo "$file has been changed:"
			cat test/$file
		fi
		let idx+=1
	done
	echo ""
done

for i in `seq 0 ${#m_pid[@]}`
do
	kill -9 ${m_pid[i]}
done

rm -rf "test/"

