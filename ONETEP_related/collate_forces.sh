#!/bin/bash



for directory in [0-9]*;
do
  echo $directory 
  cd $directory
  MYVAR=$(find *.onetep)
  perl /home/bml1g12/my_scripts/ONETEP_related/force.pl $MYVAR
  cd ..
done
