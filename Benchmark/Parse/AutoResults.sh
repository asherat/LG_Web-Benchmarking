#!/bin/bash
#Get readable csv from the raw data file ($rawFile) of the benchmark tour

path="`dirname \"$0\"`"
. $path/../../Config/variables.conf

rawFile=$1

echo "$(hostname) |$rawFile|----START AutoResults----"

if [ $# -ne 1 ]  ; then
	echo "USAGE:$0 [Results file]"
	exit 1
fi

# Copying the fps file from downloads default folder
if [ -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs ]; then
	. ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs
	export XDG_DOWNLOAD_DIR;
fi
mv "${XDG_DOWNLOAD_DIR}/$rawFile.fps" "$rawDir/$rawFile.fps"

# Check if the files exist
if [ ! -f "$rawDir/$rawFile.top" ]; then
	echo "'$rawDir/$rawFile.top' doesn't exist"
	exit 1
elif [ ! -f "$rawDir/$rawFile.mem" ]; then
	echo "'$rawDir/$rawFile.mem' doesn't exist"
	exit 1
elif [ ! -f "$rawDir/$rawFile.pcap" ]; then
	echo "'$rawDir/$rawFile.pcap' doesn't exist"
	exit 1
elif [ ! -f "$rawDir/$rawFile.fps" ]; then
	echo "'$rawDir/$rawFile.fps' doesn't exist"
	exit 1
fi

tmpDir="$rawDir/Result_$rawFile"
mkdir $tmpDir
. $parseDir/GetResults.sh $rawFile
. $parseDir/ParseResults.sh $rawFile
. $parseDir/PacketsResults.sh $rawFile
rm $tmpDir -R

echo "$(hostname) |$rawFile|----END AutoResults----"
