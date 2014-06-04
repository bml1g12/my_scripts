#!/bin/bash
#Reads a outfile file out.log and prints out a stepwise .xyz of the geomtry optimisation
#Counts the numbero of atoms based on the checkpoint filename 
#mkdir -p geom_opt
checkpoint_file_name=$1
output_log_filename=out.log

#####
#produces the first step in a .xyz file to count the number of atoms
newzmat -ichk -oxyz -step 1 $1 count
num_atoms=`wc -l count.xyz | awk {'print $1'}`
end=`expr $num_atoms + 4` 
#####


grep 'Input o' -A $end $output_log_filename > tmp.grep

csplit --digits=3 --quiet --prefix=outfile tmp.grep "/^--$/" "{*}" 

rm trajectory.xyz
touch trajectory.xyz

for file in outfile[0-9]*;
do
  echo "$num_atoms" > tmp_$file
  echo "comment" >> tmp_$file
  cat $file | tail -n $num_atoms | awk {'print $2" "$4" "$5" "$6'} >> tmp_$file
  cat tmp_$file >> trajectory.xyz
done


rm outfile*
rm tmp.grep
rm tmp_*
rm count.xyz







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
