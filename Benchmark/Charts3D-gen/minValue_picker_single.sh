#!/bin/bash
#Pass a dir, lg# tournamee to get an orientative threshold number.
#Automatically picks a value

path="`dirname \"$0\"`"
cd $path
usage="$0 [file] OPTIONAL:[rowsToDisplay]" 

if [ $# -lt 1 ]  ; then
	echo $usage
	exit 2
fi

file=$1
h=$2

if [[ $3 -lt 1 ]];then
	h=15
fi

min=$(cat $file | tail -n +4 | awk -F ',' '{print $2}' | awk '{a[$0]++}END{for(x in a)print x,a[x]}' | sort -g | head -$h | awk 'NR==1 || $2 > 10{line=$1} END{print line+1}')
if [[ $min -gt 80 ]]; then
	min=80
fi
echo $min


