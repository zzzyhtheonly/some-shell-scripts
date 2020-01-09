#!/bin/bash

#set -x

curDir=`pwd`

Usage()
{
	echo "Usage: $0 [root directory you want to place] [your gpg public key] [the directory stored your deb files]"
	echo "This script is used for creating a new repository for your own ubuntu source repo..."
}

Prework()
{
	apt update
	apt install reprepro
	apt install nginx
}

if [ $# -lt 3 ]
then
	Usage
	exit 1
fi

#parse args
repoDir=$1
shift
key=$1
shift

if [ ! -d $1 ]
then
	Usage
	exit 1
fi

ret=`ls $1 | grep .deb$ | wc -l`
if [ $ret -eq 0 ]
then
	echo "Error: Please make sure that your deb directory containing deb files!"
	exit 1
fi

cd $1
debDir=`pwd`
cd $curDir
shift

if [ $# -gt 0 ]
then
	Usage
	exit 1
fi

Prework

#start creating files for the repo directory
if [ ! -d $repoDir ]
then
	mkdir -p $repoDir
fi

cd $repoDir
if [ -d "conf" ] && [ -d "pool" ] && [ -d "db" ] && [ -d "dists" ]
then
	echo "The repo directory given is already initialized!"
	read -n1 -p "Would you like to continue anyway[Y/N]?" ans
	case $ans in
	Y | y)
		echo "Force to reinitialize!";;
	N | n)
		exit 1;;
	*)
		exit 1;;
        esac
fi
repoDir=`pwd`
cd $curDir

cd $repoDir
mkdir "conf"
cd "conf"
echo "ask-passphrase" > "options"
echo "Codename: trusty" > "distributions"
echo "Components: main" >> "distributions"
echo "Architectures: i386 amd64 source" >> "distributions"
echo "Signwith: $key" >> "distributions"
chmod +r "distributions" "options"
cd "../"

#creating repository
reprepro -b $repoDir includedeb trusty $debDir/*.deb
for file in `ls $debDir/*.dsc`
do
	reprepro -b $repoDir includedsc trusty $file
done

if [ ! -d "pool" ] || [ ! -d "dists" ]
then
	echo "Error: Repo directory failed to initialize! An unexpected error occured while reprepro initializing the repo directory, please check the mode of the repo directory and make sure your reprepro available!"
	rm -rf "$repoDir/*"
	exit 1
fi

cd $curDir

#setup nginx
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
touch /etc/nginx/sites-available/default

echo "server {" >> /etc/nginx/sites-available/default
echo "    root          $repoDir;" >> /etc/nginx/sites-available/default
echo "    access_log    /var/log/nginx/repo.access.log;" >> /etc/nginx/sites-available/default
echo "    error_log     /var/log/nginx/repo.error.log;" >> /etc/nginx/sites-available/default
echo "    location ~ /(db|conf) {" >> /etc/nginx/sites-available/default
echo "        deny      all;" >> /etc/nginx/sites-available/default
echo "        return    404;" >> /etc/nginx/sites-available/default
echo "    }" >> /etc/nginx/sites-available/default
echo "}" >> /etc/nginx/sites-available/default

service nginx restart

#done
echo "The source repository for this machine has been established successfully!"
exit 0
