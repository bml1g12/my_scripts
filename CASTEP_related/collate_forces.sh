#!/bin/bash



for directory in [0-9]*/;
do
  echo $directory 
  cd $directory
  MYVAR=$(find *.castep)
  perl /home/bml1g12/my_scripts/CASTEP_related/force.pl $MYVAR 
  cd ..
done
