#!/bin/bash
#Gets the information from a every DIR inside Data/ to draw the charts with gnuplot
path="`dirname \"$0\"`"
. $path/../../Config/variables.conf
cd $path


usage="$0 [tagname]" 

if [ $# -ne 1 ]  ; then
	echo $usage
	exit 2
fi

tagname=$1

for filen in $dataDir/*/;do
	dirname=`basename $filen`
	
	filecheck=$filen'Summary/lg1/HW/HW_'$tagname'.csv'
	if [ -f $filecheck ] ; then
		echo $dirname
		echo $dirname > current_dir.txt
		./getmax.sh $dirname
		./fixData.sh $dirname
		gnuplot -e "filename='$tagname'" -e "dir='$dataDir/$dirname/Summary/'" charts.gnu
		mkdir -p $chartsDir/$dirname && mv *.png $chartsDir/$dirname
		./getSummary.sh $dirname
		mkdir /var/www/benchmarking/charts/$dirname
		cp $chartsDir/$dirname/* /var/www/benchmarking/charts/$dirname
	else
		echo "Files with tagname \"$tagname\" don't exist"
	fi
done

#Clean temps
rm *.max 2> /dev/null
rm current_dir.txt 2> /dev/null


