#!/usr/bin/gnuplot

reset
set terminal svg size 960,480 dashed rounded enhanced

set title "Server `hostname` with IP `hostname -i`. Cores: `grep -c ^processor /proc/cpuinfo`. Memory: `grep MemTotal /proc/meminfo | awk '{print $2/1024}'` MB. \nLocal graph date: `date`\nUptime: `uptime`"

set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set format x "%H:%M"

set yrange [ 0 : 130 ]
set ytics 50
set grid lt 8 lw 1 lc rgb "#bbbbbb"
set key under

set style fill solid 0.4 noborder

plot '/var/log/hoststatproc.dat' using 1:4 t 'Apache Procs Num' with filledcurves y1=0 lc rgb "#ffcc00", \
     '/var/log/hoststatproc.dat' using 1:2 t 'Apache CPU Usage %' with lines lt 8 lw 1 lc rgb "#cc0000", \
     '/var/log/hoststatproc.dat' using 1:3 t 'Apache Memory Usage %' with lines lt 1 lw 2 lc rgb "#cc0000", \
     '/var/log/hoststatproc.dat' using 1:5 t 'MariaDB CPU Usage %' with lines lt 8 lw 1 lc rgb "#0000cc", \
     '/var/log/hoststatproc.dat' using 1:6 t 'MariaDB Memory Usage %' with lines lt 1 lw 2 lc rgb "#0000cc"
