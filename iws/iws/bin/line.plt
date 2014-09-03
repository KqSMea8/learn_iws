set term jpeg nocrop medium size 800,400
set key box
set grid
set output '/home/baizc/work/local/nginxroot/case.jpeg'
set ylabel 'case num'
set xlabel 'date num'
set title 'weekcase chart'
plot '/home/baizc/work/coiws/iws/data/chart.dat' u 1:2 title 'case' w lp lt 2 lw 1 pt 2

