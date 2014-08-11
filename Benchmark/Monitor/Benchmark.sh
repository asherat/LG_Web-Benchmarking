#!/bin/bash
THIS_PATH="`dirname \"$0\"`"
. $THIS_PATH/../../Config/variables.conf
cd $MY_PATH



if [ $# -lt 1 ]  ; then
	echo "USAGE:$0 [Tag]" # [time] [Additional Tag]"
	exit 2
fi

tag=$1
tourName='MiCasa'

TsharkOut=$rawDir/$tag.pcap
TopOut=$rawDir/$tag.top
MemOut=$rawDir/$tag.mem
FPSOut=$rawDir/$tag.fps

cmd_cpu='top -b -d 1 -p $(cat /tmp/Peruse.tmp) > '$TopOut' &'
cmd_mem_tmp='cat /proc/$(cat /tmp/Peruse.tmp)/status | grep VmRSS'

if [ -r $tourScript ] ; then
	if [ -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs ]; then
		. ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs
		$exeLG "export XDG_DOWNLOAD_DIR && rm ${XDG_DOWNLOAD_DIR}/myApp_log*" 
	fi
	$exeLG "mkdir -p $rawDir"

	#Get Google Earth PID
	$exeLG "pgrep chromium  | head -1 > /tmp/Peruse.tmp"
	$exeLG 'echo Chrome running, PID: $(cat /tmp/Peruse.tmp)'

	#Empty previous records
	$exeLG "cat /dev/null > $TsharkOut"
	$exeLG "cat /dev/null > $TopOut"
	$exeLG "cat /dev/null > $MemOut"
	$exeLG "cat /dev/null > $FPSOut"
	
	echo "Start monitoring $tourName tour"
	exec $exeLGbg tshark -i eth0 -q -w $TsharkOut &
	exec $exeLGbg $cmd_cpu &
	exec $exeLGbg $monitorDir/getRam.sh $MemOut &

	echo "Starting $tourName tour"
	$tourScript $tourName

	echo "Done monitoring $tourName tour"
	$exeLG $monitorDir/stopAll.sh

	$exeLG mv ${XDG_DOWNLOAD_DIR}/myApp_log* $FPSOut 

	$exeLG rm /tmp/Peruse.tmp
else
	echo "$tourScript doesn't exist"
fi


