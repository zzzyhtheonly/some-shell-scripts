#!/bin/bash

#set -x

if [ ! -d $1 ]
then
	echo "Input are not directories!! Please follow the format 
	./compile_tencent_deb_single.sh sourceDirectory targetDirectory format(oldText newText...)"
	exit 1
fi

curDir=`pwd`
mainDir=$1
targetDir=
arr=()
shift

if [ $[${#}%2] -ne 0 ]
then
	targetDir=$1
	shift
fi

i=0
while(( $# > 0 ))
do
        arr[i]=$1
        shift

        ((i++))
        arr[i]=$1
        shift
        ((i++))
done

if [ x$mainDir = x ]
then
	echo "Not a right deb source directory!"
	exit 1
fi

${SOURCE_DIR}/change_all.sh $mainDir ${arr[*]}

cd $mainDir
sudo dpkg-buildpackage -b --no-sign
cd ..

if [ ! x$targetDir == x ] 
then
	sudo mv -f *deb $targetDir
fi

cd $curDir
