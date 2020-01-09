#!/bin/bash

#set -x

function printHelp()
{
	echo 'Traverse a directory and change the things you want.
		-a, change both the name and text
		-n, change the name
		-t, change the text
traverse_change -a dir textYouWantToChange textYouWant'
}

function changeName()
{
	old_name=$1
        shift
        old=$1
        shift ${#old[@]}
        new=$1
        shift ${#old[@]}
	new_name=$old_name

	for i in `seq 0 ${#old[@]}`
	do
		if [ $i == ${#old[@]} ]
		then
			break
		fi
		tmp_old=${old[i]}
		tmp_new=${new[i]}
		new_name=`sudo echo $new_name | sudo sed s/${tmp_old}/${tmp_new}/g`
	done

	if [ ! x$new_name == x$old_name ]
        then 
		echo "mv ${old_name} into ${new_name}"
		sudo mv -f $old_name $new_name
	else
		return 1
	fi

}

function changeText()
{
	name=$1
        shift
        old=$1
        shift ${#old[@]}
        new=$1
        shift ${#old[@]}

	for i in `seq 0 ${#old[@]}`
        do
		if [ $i == ${#old[@]} ]
                then
                        break
                fi
		tmp_old=${old[i]}
                tmp_new=${new[i]}
		sudo sed -i s/${tmp_old}/${tmp_new}/g $name
		echo "Change ${name}'s text from ${tmp_old} into ${tmp_new}"
        done

}

function traverseDir()
{
	if [ ! -d $1 ]
	then
		echo "Not a dir!"
		exit 1
	fi
	echo "Entered $1"

	Dir=$1
	list=`ls $Dir`
	cd $Dir
        shift
	old=$1
	shift ${#old[@]}
	new=$1
	shift ${#old[@]}

	local file=
	for file in $list
	do
		if [ -d $file ]
		then
			traverseDir $file ${old[*]} ${new[*]}
			if [ $func_changeName == 1 ]
                        then
                                changeName $file ${old[*]} ${new[*]}
                        fi
		else
			if [ $func_changeText == 1 ]
                        then
                                changeText $file ${old[*]} ${new[*]}
                        fi

			if [ $func_changeName == 1 ]
			then
				changeName $file ${old[*]} ${new[*]}
			fi
		fi
	done
	cd ../
}

func_changeName=0
func_changeText=0
curDir=`pwd`
old=()
new=()

if [ $# -lt 1 ] || [ x$1 != x"-a" ] && [ x$1 != x"-n" ] && [ x$1 != x"-t" ]
then
	printHelp
	exit 1
else
	if [ x$1 == "-n" ]
	then
		func_changeName=1
	elif [ x$1 == "-t" ]
	then
                func_changeText=1
	else
		func_changeName=1
                func_changeText=1
	fi
	
	shift
	Dir=$1
	shift

	i=0
	while(( $# > 0 ))
	do
		old[i]=$1
		shift

		if [ $# -eq 0 ]
		then
			printHelp
			exit 1
		fi

		new[i]=$1
		shift
		((i++))
	done

	traverseDir $Dir ${old[*]} ${new[*]}
	cd $curDir
fi
