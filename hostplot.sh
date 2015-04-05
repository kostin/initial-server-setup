#!/usr/bin/gnuplot

reset
set terminal svg size 960,480

set title "Server `hostname` with IP `hostname -i` usage"

set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set format x "%H:%M"
#set xlabel "Time"
#set ylabel "Percents %"

set yrange [ 0 : ]
set grid
set key under

plot '/var/log/hoststat.dat' using 1:2 t 'Cpu usage %' with lines, \
     '/var/log/hoststat.dat' using 1:3 t 'Load Average' with lines, \
     '/var/log/hoststat.dat' using 1:4 t 'Memory usage %' with lines, \
     '/var/log/hoststat.dat' using 1:5 t 'Swap usage %' with lines, \
     '/var/log/hoststat.dat' using 1:6 t 'Disk space usage %' with lines, \
     '/var/log/hoststat.dat' using 1:7 t 'IO wait %' with lines, \
     '/var/log/hoststat.dat' using 1:8 t 'RX, Mb/s' with lines, \
     '/var/log/hoststat.dat' using 1:9 t 'TX, Mb/s' with lines, \
     '/var/log/hoststat.dat' using 1:10 t 'PHP mail queue x 10' with lines
