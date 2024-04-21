#!/bin/sh

platform="win mac"
idx=0
for p in $platform:
do
	curVersion[$idx]=""
	if [ -f download/$p/version.txt]; then
		curVersion[$idx]=`cat download/win/version.txt`
	fi
	idx=`expr $idx + 1`
done

git pull origin

lastestVer=""
hasUpdate=0

for p in $platform:
do
	lastestVersion[$idx]=""
	if [ -f download/$p/version.txt]; then
		lastestVersion[$idx]=`cat download/win/version.txt`
	fi
	if [ $lastestVersion[$idx] > $lastestVer ]; then
		lastestVer=lastestVersion
	fi
	if [ $lastestVersion[$idx] != $curVersion[$idx] ]; then
		zip -r -x download/$p download/$p/yuny_$lastestVersion.zip download/$p/yuny
		hasUpdate=1
	fi

	idx=`expr $idx + 1`
done

if [ $hasUpdate eq 1 ]; then
	curDate=`date +"%Y-%m-%d"`
	sed -e 's/latest_version = .*/latest_version = "$lastestVer"/' -e 's/update_date = .*/update_date = "$curDate"/' index.html
fi


