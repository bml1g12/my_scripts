#!/bin/bash



for directory in [0-9]*/;
do
  echo $directory 
  cd $directory
  #grep 'Final energy' *.castep | awk '{print $4}'
  MYVAR=$(find *.cst_esp)
  echo $MYVAR | /home/bml1g12/my_scripts/CASTEP_related/pot.exe
  cd ..
done
