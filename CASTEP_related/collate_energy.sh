#!/bin/bash



for directory in [0-9]*/;
do
  echo $directory 
  cd $directory
  grep 'Final energy' *.castep | awk '{print $4}'
  cd ..
done
