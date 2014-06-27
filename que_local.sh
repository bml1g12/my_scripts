#/bin/bash
ulimit -s unlimited
export OMP_NUM_THREADS=1

for dir in [0-9]*;
do 
  echo $dir
  cd $dir
  mpirun -np 4 ~/ONETEP_3.5.9.8/devel/bin/onetep.RH6.intel hydroxide_bottom_shifted.dat > hydroxide_bottom_shifted.onetep 2> hydroxide_bottom_shifted.err &
  cd ..
done
