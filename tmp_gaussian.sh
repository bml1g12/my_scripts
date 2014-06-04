#!/bin/bash
#provide checkpoint basefilename as first argument

#mkdir -p geom_opt
checkpoint_file_name=$1
#produces the first step in a .xyz file
newzmat -ichk -oxyz -step 1 $1 count
num_atoms=`wc -l count.xyz | awk {'print $1'}`
end=`expr $num_atoms + 4` 

grep 'Input o' -A $end out.log


 #| tail -n $num_atoms | awk {'print $2" "$4" "$5" "$6'} 


#touch trajectory.xyz

#for i in `seq 1 3` 
#do 
# newzmat -ichk -oxyz -step $i $1 geom_$i
# sed -i "1s/^/comment\n/" geom_$i.xyz
# sed -i "1s/^/$num_atoms\n/" geom_$i.xyz
# cat geom_$i.xyz >> trajectory.xyz
#done 

#mv trajectory.xyz geom_opt/

#rm geom_*.xyz
#rm geom_*.xyz geom_opt/
