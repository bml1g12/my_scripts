#!/bin/bash



for directory in [0-9]*;
do
  echo $directory 
  cd $directory
  MYVAR=$(find *_potential.cube)
  python /home/bml1g12/my_scripts/ONETEP_related/onetep_average_pot.py $MYVAR
  cd ..
done
