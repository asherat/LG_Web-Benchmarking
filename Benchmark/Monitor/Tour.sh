#!/bin/bash
#Reads the file queries.txt and starts a tour named $1 with $2 seconds between jumps

MY_PATH="`dirname \"$0\"`"
cd $MY_PATH

myIP=$1
myPORT=$2
myTime=$3

echo ----Starting tour----
#Gets a POI from the $1 tour each $2 seconds and puts it into /tmp/query.txt. This is the file which Google Earth is always reading and tells it to move to that position

#TODO:Doesn't work for 32bits
#./evdev-emitter $1 $2

#: <<'END'
for (( i=$myTime; i>0; i-- ))do
	echo "Point $i"
	sleep 1
done
#END

echo ----Tour finished----
