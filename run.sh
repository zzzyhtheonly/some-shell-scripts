#!/bin/bash

#set -x

if [ ! -d $1 ]
then
        echo "Input are not directories!! Please follow the format
        ./run.sh sourceDirectory targetDirectory format(oldText newText...)"
        exit 1
fi

curDir=`pwd`
sourceDir="${curDir}/scripts"

sed -i "1c SOURCE_DIR=${sourceDir}/" scripts/defines

source scripts/defines

for var in `cat scripts/defines`
do
	export $var
done

mainDir=$1
targetDir=
arr=()
shift

if [ -d $1 ]
then
        targetDir=$1
        shift
fi

cd $targetDir
targetDir=`pwd`
cd $curDir

i=0
while(( $# > 0 ))
do
        arr[i]=$1
        shift

        if [ $# -eq 0 ]
        then
                echo "No pair to change ${arr[i]}"
                exit 1
        fi

        ((i++))
        arr[i]=$1
        shift
        ((i++))
done

mList=`ls $mainDir`
cd $mainDir
for Dir in $mList
do
	if [ -d $Dir ]
	then
		list=`ls $Dir`
		cd $Dir
		for file in $list
		do
			if [ ! -d $file ]
			then
				continue
			fi

			if [ ! x$targetDir == x ]
			then
				${SOURCE_DIR}/compile_tencent_deb_single.sh $file $targetDir ${arr[*]}
			else
				${SOURCE_DIR}/compile_tencent_deb_single.sh $file ${arr[*]}
			fi
			sleep 5
		done
		cd ../
	fi
done

cd ${curDir}
