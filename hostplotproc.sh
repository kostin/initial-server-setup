#!/usr/bin/gnuplot

reset
set terminal svg size 960,480 dashed rounded enhanced

set title "Server `hostname` with IP `hostname -i`. Cores: `grep -c ^processor /proc/cpuinfo`. Memory: `grep MemTotal /proc/meminfo | awk '{print $2/1024}'` MB. \nLocal graph date: `date`\nUptime: `uptime`"

set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set format x "%H:%M"

set yrange [ 0 : 130 ]
set ytics 50
set grid lt 8 lw 1 lc rgb "#dddddd"
set key under

set style fill solid 0.4 noborder

plot '/var/log/hoststatproc.dat' using 1:4 t 'httpd Procs Num' with filledcurves y1=0 lc rgb "gold", \
     '/var/log/hoststatproc.dat' using 1:6 t 'mysqld Mem Usage %' with lines lt 1 lw 2 lc rgb "turquoise", \
     '/var/log/hoststatproc.dat' using 1:3 t 'httpd Mem Usage %' with lines lt 1 lw 2 lc rgb "coral", \
     '/var/log/hoststatproc.dat' using 1:5 t 'mysqld CPU Usage %' with lines lt 1 lw 1 lc rgb "blue", \
     '/var/log/hoststatproc.dat' using 1:2:(10.0) t 'httpd CPU Usage %' with lines lt 1 lw 1 lc rgb "magenta", \
     100 t '' with lines lt 3 lw 1 lc rgb "red"
