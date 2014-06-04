#!/bin/bash

seed="test"

i=600
while [ $i -le 800 ]
do
  #imcrement i
  echo "generating param file for $i Cutoffs Energy in ./${i}eV"
  #Make a directory for each KE cutoff. The -p flag, means no error if existsing
  mkdir -p ${i}eV
  #Match line with cut_off_energy and all that follows and replace with the string 
  #you'd like, which here is the same but with a different cutoff. 
  #put into the folder created above 
  sed "s/cut_off_energy.*/cut_off_energy : $i/" $seed.parm > ./${i}eV/${seed}_${i}eV.parm
  i=`expr $i + 100`
done

echo "--- Done. It's `date`"

