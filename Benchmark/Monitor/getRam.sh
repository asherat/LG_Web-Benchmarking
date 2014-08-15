#!/bin/bash
#Monitorizes RAM for a given PID
THIS_PATH="`dirname \"$0\"`"
#. $THIS_PATH/../../Config/variables.conf
cd $MY_PATH

if [ $# -lt 1 ]  ; then
	echo "USAGE:$0 [output]"
	exit 2
fi

output=$1

peruse=`cat /tmp/Peruse.tmp`
while [ true ]; do
	cat /proc/$peruse/status | grep VmRSS >> $output
	sleep 1;
done
