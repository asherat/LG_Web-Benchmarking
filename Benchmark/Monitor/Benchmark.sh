#!/bin/bash
THIS_PATH="`dirname \"$0\"`"
. $THIS_PATH/../../Config/variables.conf
cd $MY_PATH



if [ $# -lt 5 ]  ; then
	echo "USAGE:$0 [Tag] [Node.js IP] [Node.js Port] [Jumps] [Timing]" # [time] [Additional Tag]"
	exit 2
fi

tag=$1
IP=$2
PORT=$3
myJumps=$4
myTiming=$5

TsharkOut=$rawDir/$tag.pcap
TopOut=$rawDir/$tag.top
MemOut=$rawDir/$tag.mem

cmd_cpu='top -b -d 1 -p $(cat /tmp/Peruse.tmp) > '$TopOut' &'
cmd_mem_tmp='cat /proc/$(cat /tmp/Peruse.tmp)/status | grep VmRSS'

if [ -r $tourScript ] ; then
	$exeLG "mkdir -p $rawDir"

	#Get Google Earth PID
	$exeLG "pgrep chromium  | head -1 > /tmp/Peruse.tmp"
	$exeLG 'echo Chrome running, PID: $(cat /tmp/Peruse.tmp)'

	#Empty previous records
	$exeLG "cat /dev/null > $TsharkOut"
	$exeLG "cat /dev/null > $TopOut"
	$exeLG "cat /dev/null > $MemOut"
	#$exeLG "cat /dev/null > $FPSOut"
	
	echo "Start monitoring $tag tour"
	exec $exeLGbg tshark -i eth0 -q -w $TsharkOut &
	exec $exeLGbg $cmd_cpu &
	exec $exeLGbg $monitorDir/getRam.sh $MemOut &

	echo "Starting $tag tour"
	$tourScript $IP $PORT $myJumps $myTiming

	echo "Done monitoring $tag tour"
	$exeLG $monitorDir/stopAll.sh

	$exeLG rm /tmp/Peruse.tmp
else
	echo "$tourScript doesn't exist"
fi


