#!/usr/bin/env gnuplot
max_ram="`cat ram.max`"
max_tcp="`cat tcp.max`"

#filename

#Filenames
hw='/HW/HW_'
external='/NW/NW_ext-'
squid='/NW/NW_squid-'
internal='/NW/NW_internal-'


#------------------------------------------------------
#-----------------------Start--------------------------
#------------------------------------------------------

#CPU
file_tour=hw.filename.'.csv'

set yrange [0:100]
set output 'cpu.png'
load "config.gnu"
set ylabel 'CPU Usage %'
graph_type="cpu"
load "plotting.gnu"

#-----------------------------------------
#RAM
set yrange [0:max_ram]
set output 'ram.png'
load "config.gnu"
set ylabel 'RAM Usage MB'
graph_type="ram_tcp"
load "plotting.gnu"

#-----------------------------------------
#FPS
set yrange [0:60]
set output 'fps.png'
load "config.gnu"
set ylabel 'Frames per second'
graph_type="fps"
load "plotting.gnu"


#-----------------------------------------
#External
file_tour=external.filename.'.csv'

set yrange [0:max_tcp]
#set yrange [0:3000]
set output 'tcp_ext.png'
load "config.gnu"
set ylabel 'External KB/s'
graph_type="ram_tcp"
load "plotting.gnu"

#-----------------------------------------
#Internal
file_tour=internal.filename.'.csv'

set yrange [0:max_tcp]
#set yrange [0:3000]
set output 'tcp_internal.png'
load "config.gnu"
set ylabel 'Internal KB/s'
graph_type="ram_tcp"
load "plotting.gnu"

#-----------------------------------------
#Squid
file_tour=squid.filename.'.csv'

#set yrange [0:3000]
set output 'tcp_squid.png'
load "config.gnu"
set ylabel 'Squid KB/s'
graph_type="ram_tcp"
load "plotting.gnu"
