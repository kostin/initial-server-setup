#!/usr/bin/gnuplot

reset
set terminal svg size 960,480 dashed rounded enhanced

set title "Server `hostname` with IP `hostname -i`. Cores: `grep -c ^processor /proc/cpuinfo`. Memory: `grep MemTotal /proc/meminfo | awk '{print $2/1024}'` MB. \nLocal graph date: `date`\nUptime: `uptime`"

set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set format x "%H:%M"
#set xlabel "Time"
#set ylabel "Percents %"

set yrange [ 0 : 130 ]
set ytics 50
set grid lt 8 lw 1 lc rgb "#bbbbbb"
#set grid
set key under

set style fill solid 0.4 noborder

plot '/var/log/hoststat.dat' using 1:10 t 'PHP mail queue' with filledcurves y1=0 lc rgb "#cc0066", \
#     '/var/log/hoststat.dat' using 1:8 t 'RX, Kb/s' with filledcurves y1=0 lc rgb "#eecc66", \
#     '/var/log/hoststat.dat' using 1:9 t 'TX, Kb/s' with filledcurves y1=0 lc rgb "#99eeee", \
     '/var/log/hoststat.dat' using 1:2 t 'Cpu usage %' with lines lt 1 lw 1 lc rgb "#ff0000", \
     '/var/log/hoststat.dat' using 1:3 t 'Load Average x 100' with lines lt 8 lw 1 lc rgb "#ff0000", \
     '/var/log/hoststat.dat' using 1:4 t 'Memory usage %' with lines lt 8 lw 1 lc rgb "#0000ff", \
     '/var/log/hoststat.dat' using 1:5 t 'Swap usage %' with lines lt 1 lw 1 lc rgb "#0000ff", \
     '/var/log/hoststat.dat' using 1:6 t 'Disk space usage %' with lines lt 1 lw 2 lc rgb "#ff9900", \
     '/var/log/hoststat.dat' using 1:7 t 'IO wait %' with lines lt 1 lw 1 lc rgb "#009900"
