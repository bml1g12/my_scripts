#!/bin/bash
#Ben Lowe
#17/07/2013
#collates the ONETEP total energy from all subdirectories


for directory in [0-9]*;
do
  echo $directory
  cd $directory
  grep '<-- CG' *.onetep | awk {'print $3'}
  cd ..
done

