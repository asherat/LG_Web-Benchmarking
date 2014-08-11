#!/bin/bash
#Allows to copy all scripts to other nodes in order to perform the benchmarking tasks
MY_PATH="`dirname \"$0\"`"
. $MY_PATH/Config/variables.conf

$exeLGslaves "mkdir $configDir -p; scp lg1:$configDir/variables.conf $configDir; scp -r lg1:$benchmarkDir $mainDir && chmod +x $benchmarkDir/Monitor/*.sh && chmod +x $benchmarkDir/Parse/*.sh"

chmod +x $benchmarkDir/Monitor/*.sh
chmod +x $benchmarkDir/Parse/*.sh
chmod +x $toolsDir/*.sh
