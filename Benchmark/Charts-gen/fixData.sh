#!/bin/bash
#Sometimes, when monitoring, at the end of the benchmark, the last rows are ahead of the stop time.
#This script deletes those unnecesary rows
path="`dirname \"$0\"`"
. $path/../../Config/variables.conf
cd $path

dir=`basename $1`

for filename in `ls $dataDir/$dir/Summary/lg?/HW/*.csv -v`; do
	awk -F "," '(NR<=3) {print $0}(NR>3 && NF==4) {print $0}' $filename > $filename"2"
	mv $filename"2" $filename
done

