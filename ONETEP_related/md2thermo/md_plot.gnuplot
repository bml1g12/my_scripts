# Plot MD data
set multiplot
set autoscale
set ytic auto
set size 1.0,0.25
set origin 0.0,0.0;
plot "thermo" using 1:2 with linespoints title 'Temperature (K)';
set origin 0.0,0.25;
plot "thermo" using 1:3 with linespoints title 'Epot (Ha)';
set origin 0.0,0.50;
plot "thermo" using 1:4 with linespoints title 'Ekin (Ha)';
set origin 0.0,0.75;
plot "thermo" using 1:5 with linespoints title 'Etot (Ha)';
