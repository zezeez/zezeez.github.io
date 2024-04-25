#!/bin/sh

platform="win mac"
idx=0
for p in $platform:
do
	if [ -f download/$p/version.txt ]; then
		curVersion[$idx]=`cat download/$p/version.txt`
	fi
	idx=`expr $idx + 1`
done

# require zip, git
requiredTools="zip git "
for tool in $requiredTools:
do
	$tool --help > /dev/null
	if [ $? -ne 0 ]; then
		echo "$tool is require but not found, please install $tool first!"
		exit 127
	fi
done

git stash push . -m 'update job' > /dev/null
updateMsg=`git pull origin`
if [ "x$updateMsg" == "xAlready up to date." ]; then
	git stash pop > /dev/null
	echo "Update done, nothing to do."
	exit 0
fi

lastestVer=""
hasUpdate=0

git stash pop > /dev/null

idx=0
for p in $platform:
do
	if [ -f download/$p/version.txt ]; then
		lastestVersion[$idx]=`cat download/$p/version.txt`
	fi
	if [ -n "${lastestVersion[$idx]}" -a "${lastestVersion[$idx]}" \> "$lastestVer" ]; then
		lastestVer=${lastestVersion[$idx]}
	fi
	if [ -n "${lastestVersion[$idx]}" -a "x${lastestVersion[$idx]}" != "x${curVersion[$idx]}" ]; then
		cd download/$p
		echo "Package download/$p/yuny_${lastestVersion[$idx]}.zip..."
		cp -a yuny yuny_${lastestVersion[$idx]}
		zip -r yuny_${lastestVersion[$idx]}.zip yuny_${lastestVersion[$idx]}
		rm -rf yuny_${lastestVersion[$idx]}
		cd ../..
		sed -i "s/var ${p}_version = .*/var ${p}_version = \"${lastestVersion[$idx]}\"/" index.html
		hasUpdate=1
	fi

	idx=`expr $idx + 1`
done

if [ $hasUpdate -eq 1 -a -n $lastestVer ]; then
	curDate=`date +"%Y-%m-%d"`
	sed -i -e "s/latest_version = .*/latest_version = \"$lastestVer\"/" -e "s/update_date = .*/update_date = \"$curDate\"/" index.html
	echo "Update latest version to $lastestVer, update date to $curDate"
fi


