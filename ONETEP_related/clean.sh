#/bin/bash

for dir in [0-9]*;
do 
  echo $dir
  cd $dir
  rm *.dkn
  rm *.cube
  rm *.dx
  rm *.onetep
  rm *.err
  rm *.tightbox*
  cd ..
done
