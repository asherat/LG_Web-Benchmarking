#!/bin/bash
#Gets Networking Results
rawFile=$1

echo "$(hostname) |$rawFile|----START PacketResults----"
if [ $# -ne 1 ]  ; then
	echo "USAGE:$0 [Results file]"
	exit 2
fi

inFile="$rawDir/$rawFile.pcap"
outDir=$rawDir/"Result_$rawFile"

tempDir="$rawDir/TShark_$rawFile"

mkdir $tempDir

lgIPs="ip.addr==10.42.42.0/24"
nodePort="8086"
echo "Chopping '$inFile' file"
tshark -r $inFile -R "tcp && !tcp.port==22 && !tcp.port==$nodePort" -w $tempDir/external.pcap 
tshark -r $inFile -R "$lgIPs" -w $tempDir/squid.pcap 
tshark -r $inFile -R "tcp.port==$nodePort" -w $tempDir/internal.pcap 
echo "Done Chopping '$inFile' file"

echo "Generating tshark reports"
tshark -q -nr $tempDir/external.pcap -z io,stat,1 | tail -n +8 | head -n -1 | awk 'BEGIN { print "\n,TCP,\ninterval,frames,Bytes" } { print NR","$2","$3}' > $net/NW_ext-$rawFile.csv
echo "Generated '$net/NW_$rawFile.csv'"
tshark -q -nr $tempDir/squid.pcap -z io,stat,1 | tail -n +8 | head -n -1 | awk 'BEGIN { print "\n,TCP,\ninterval,frames,Bytes" } { print NR","$2","$3}' > $net/NW_squid-$rawFile.csv
echo "Generated '$net/NW_squid-$rawFile.csv'"
tshark -q -nr $tempDir/internal.pcap -z io,stat,1 | tail -n +8 | head -n -1 | awk 'BEGIN { print "\n,TCP,\ninterval,frames,Bytes" } { print NR","$2","$3}' > $net/NW_internal-$rawFile.csv
echo "Generated '$net/NW_int-$rawFile.csv'"
echo "tshark reports generated"

echo "Generating Capinfos summary"
echo EXTERNAL > $net/NW-Summary_ext-$rawFile.txt
capinfos -xyzm $tempDir/external.pcap | tail -n +2 >> $net/NW-Summary_ext-$rawFile.txt
echo SQUID > $net/NW-Summary_squid-$rawFile.txt
capinfos -xyzm $tempDir/squid.pcap | tail -n +2 >> $net/NW-Summary_squid-$rawFile.txt
echo INTERNAL > $net/NW-Summary_internal-$rawFile.txt
capinfos -xyzm $tempDir/internal.pcap | tail -n +2 >> $net/NW-Summary_internal-$rawFile.txt
echo "Generated capinfos reports"

rm $tempDir -R

echo "$(hostname) |$rawFile|----END PacketResults----"
