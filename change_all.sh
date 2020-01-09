#!/bin/bash
  
#set -x

if [ ! -d $1 ]
then
        echo "Input are not directories!! Please follow the format 
        ./change_all.sh sourceDirectory format(oldText newText...)"
        exit 1
fi

curDir=`pwd`
mainDir=$1
arr=()
shift

control=
cd $mainDir
if [ -f "debian/control.in" ]
then
	control="debian/control.in"
elif [ -f "debian/control" ]
then
	control="debian/control"
else
	echo "Not a debian source directory!"
	exit 1
fi

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

bak=$IFS
IFS=$'\n'

i=0
j=0
idx=()
text=()
for line in `cat $control`
do
	((i++))
	first=`echo $line | awk -F':' '{print $1}'`
	if [[ $first =~ "Maintainer" ]] || \
		[ $first == "Homepage" ] || \
		[[ $first =~ "Vcs" ]] || \
		[ $first == "Uploaders" ] 
        then
		idx[j]=$i
		text[j]=$line
		((j++))
	fi

done

cd $curDir
${SOURCE_DIR}/traverse_change.sh -a $mainDir ${arr[*]}

cd $curDir
cd $mainDir

for i in `seq 0 ${#idx[@]}`
do
	if [ $i == ${#idx[@]} ]
	then
 		break
	fi
	sudo sed -i "${idx[i]}c ${text[i]}" $control
done

IFS=$bak
cd $curDir
