#!/bin/bash
THIS_PATH="`dirname \"$0\"`"
. $THIS_PATH/../../Config/variables.conf
cd $MY_PATH

if [ $# -lt 1 ]  ; then
	echo "USAGE:$0 [Tag]" # [time] [Additional Tag]"
	exit 2
fi

tag=$1
tourName="MiCasa"

TsharkOut=$rawDir/$tag.pcap
TopOut=$rawDir/$tag.top
MemOut=$rawDir/$tag.mem
FPSOut=$rawDir/$tag.fps

#-----------Launching Peruse-a-rue----------
serverIP="localhost"
serverPort="8086"

echo "Closing any Chrome instance"
kill `pgrep chromium-browse`

echo "Waiting to close"
sleep 2

chromium-browser "http://$serverIP:$serverPort/display/?master=true" > /dev/null 2>&1 &
chr_PID=$!
echo "New Chrome instance running with PID:$chr_PID"

echo "Giving 2 seconds to start"
sleep 2
#---------------------------------------------

cmd_cpu='top -b -d 1 -p $(cat /tmp/Peruse.tmp) > '$TopOut' &'
cmd_mem_tmp='cat /proc/$(cat /tmp/Peruse.tmp)/status | grep VmRSS'

cmd_cpu='top -b -d 1 -p $($chr_PID) > $TopOut &'
cmd_mem_tmp='cat /proc/'$chrID'/status | grep VmRSS'

function getFPSfile {
if [ -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs ]; then
	. ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs
	export XDG_DOWNLOAD_DIR
fi
mv ${XDG_DOWNLOAD_DIR}/myApp_log.txt $FPSOut
}


if [ -r $tourScript ] ; then

	mkdir -p $rawDir #$exeLG

	#Get Google Earth PID
	echo $chr_PID > /tmp/Peruse.tmp #$exeLG
	#echo "Chrome running, PID: $(cat /tmp/Peruse.tmp)" # $exeLG con comillas simples

	#Empty previous records
	cat /dev/null > $TsharkOut
	cat /dev/null > $TopOut
	cat /dev/null > $MemOut
	#cat /dev/null > $FPSOut #$exeLG
	
	echo "Start monitoring $tourName tour"
	exec tshark -i eth0 -q -w $TsharkOut &
	top -b -d 1 -p $chr_PID > $TopOut &
	#exec $cmd_cpu & #exec $exeLGbg
	exec $monitorDir/getRam.sh $MemOut &

	echo "Starting $tourName tour"
	$tourScript $tourName

	echo "Done monitoring $tourName tour"
	$monitorDir/stopAll.sh #$exeLG

	getFPSfile

	rm /tmp/Peruse.tmp #$exeLG 
else
	echo "$tourScript doesn't exist"
fi


