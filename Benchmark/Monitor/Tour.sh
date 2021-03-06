#!/bin/bash
#Reads the file queries.txt and starts a tour named $1 with $2 seconds between jumps

MY_PATH="`dirname \"$0\"`"
cd $MY_PATH

usage="USAGE:$0 [IP] [Port] [Jumps] [Timing]"

if [ $# -lt 4 ]  ; then
	echo $usage
	exit 2
fi

myIP=$1
myPORT=$2
myJumps=$3
myTiming=$4

echo ----Starting tour----
#Gets a POI from the $1 tour each $2 seconds and puts it into /tmp/query.txt. This is the file which Google Earth is always reading and tells it to move to that position

#TODO:Doesn't work for 32bits

#: <<'END'
for (( i=1; i<=$myJumps; i++ ))do
	./evdev-emitter $1 $2
	echo "Point $i"
	sleep $myTiming
done
#END

echo ----Tour finished----
