#!/bin/bash
#Reads the file queries.txt and starts a tour named $1 with $2 seconds between jumps

MY_PATH="`dirname \"$0\"`"
cd $MY_PATH

echo ----Starting tour $1----
#Gets a POI from the $1 tour each $2 seconds and puts it into /tmp/query.txt. This is the file which Google Earth is always reading and tells it to move to that position
for i in {5..1}
do
	echo "Point $i"
	sleep 1
done

echo ----Tour finished----
