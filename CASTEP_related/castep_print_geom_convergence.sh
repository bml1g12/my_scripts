#!/bin/bash
#Prints the Ttoal Enegry, Forces, Energy per atom and displacements as a CSV to stodut
echo 'Final_energy'
grep 'Final energy' $1 | awk {'print $4'}
echo ','
echo 'Fmax'
grep '|F|' $1 | awk {'print $4'}
echo ','
echo 'dE/ion'
grep 'dE/ion' $1 | awk {'print $4'}
echo ','
echo 'dRmax'
grep '|dR|' $1 | awk {'print $4'}
