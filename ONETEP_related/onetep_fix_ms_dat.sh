#!/bin/bash
#Corrects and Generates ONETEP input files from Material Studio Input Files

#18/06/2014 Changed to C6 text on output
#14/05/2014 Changed 1000 to 1000 bohr for the kernel cutoff 
#22/04/2014 Changes NGWF_radii to 9.0. Explicitly sets kernel_cutoff to 1000
#20/12/2013 changed the grep display of the NGWF radius to use -w rather than ^ and $  




# $# variable is the number of arguments provided

#http://wiki.bash-hackers.org/howto/getopts_tutorial
option_flag=false
while getopts "i:uf" opt; do
  case $opt in
    i)
      infile=$OPTARG
      #create a tail file for all parts after the lattice dimensions, we will delete all the stuff before hand and replace it with dat_head.part 
      grep '%block lattice_cart' -A 9999 $infile > tail.part
      cat ~/my_scripts/ONETEP_related/dat_head.part tail.part > $infile 
      rm tail.part
      ;;
    u)
      echo "-u Ultrafine_C6 tolerances was triggered" >&2
      option_flag=true
      awk 'NR==3 {print "!tolerances=-u Ultrafine"} 1' $infile > tmpfile && mv tmpfile $infile
      sed -i "s/NGWF_THRESHOLD_ORIG.*/NGWF_THRESHOLD_ORIG 0.0000018375/" $infile
      sed -i "s/ELEC_ENERGY_TOL.*/ELEC_ENERGY_TOL 0.0000005     eV/" $infile
      sed -i "s/GEOM_ENERGY_TOL.*/GEOM_ENERGY_TOL 0.00000500000     eV/" $infile
#using # and ' to escape the " and / neccisary
      sed -i 's#GEOM_FORCE_TOL.*#GEOM_FORCE_TOL 0.0100000000     "eV/ang"#' $infile
      sed -i "s/GEOM_DISP_TOL.*/GEOM_DISP_TOL 0.00050000000     ang/" $infile
      ;;
    f)
      echo "-f fine_bl_C6 tolerances was triggered" >&2
      option_flag=true
      sed -i "s/NGWF_THRESHOLD_ORIG.*/NGWF_THRESHOLD_ORIG 0.0000018375/" $infile
      sed -i "s/ELEC_ENERGY_TOL.*/ELEC_ENERGY_TOL 0.001     eV/" $infile
      sed -i "s/GEOM_ENERGY_TOL.*/GEOM_ENERGY_TOL 0.0000100000     eV/" $infile
      sed -i 's#GEOM_FORCE_TOL.*#GEOM_FORCE_TOL 0.0300000000     "eV/ang"#' $infile
      sed -i "s/GEOM_DISP_TOL.*/GEOM_DISP_TOL 0.0010000000     ang/" $infile
      ;;
    \?)
      echo "Invalid argument, Provide -i infile.dat, and please provide -u for MS ultrafine defaults, or -f for 'fine_bl' defaults"
     #'fine_bl' defaults = Ultrafine RMS SCF, default ONETEP ELEC_ENERGY_TOl (0.001ev/atom = onetep default and 'medium' in MS), fine BFGFS (MS fine settings) 
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if ! $option_flag
then
 echo "missing argument, please provide -i [filename.dat], and -u for MS ultrafine defaults, or -f for 'fine_bl' defaults"
 exit 1
fi

#append things to the file:
#awk 'NR==7 {print "GRD_FORMAT T"} 1' $infile > tmpfile && mv tmpfile $infile
#adjust the mpi communicator groups
#sed -i "s/COMMS_GROUP_SIZE.*//" $infile

sed -i "s/O_00.fbl/SOLVE/" $infile
sed -i "s/AUTO/SOLVE/" $infile

#ensure the radii are set to the decimal point ending used in my summer project
sed -i "s/O1 O 8 4.*/O1 O 8 4 9.0/" $infile
sed -i "s/Si1 Si 14 4.*/Si1 Si 14 9 9.0/" $infile
sed -i "s/H1 H 1 1.*/H1 H 1 1 9.0/" $infile
sed -i "s/O8 O 8 4.*/O8 O 8 4 9.0/" $infile
sed -i "s/Si8 Si 14 4.*/Si8 Si 14 9 9.0/" $infile
sed -i "s/H8 H 1 1.*/H8 H 1 1 9.0/" $infile

sed -i "s/H H 1 1.*/H H 1 1 9.0/" $infile
sed -i "s/Si Si 14 4.*/Si Si 14 9 9.0/" $infile
sed -i "s/O O 8 4.*/O O 8 4 9.0/" $infile

echo "The edited block species block is now:"
#the -w means it doesnt select all the %block lines in the document
grep -w -A 4 "%block species" $infile 


#sed creates dos ^M line endings. using ex, which is the cmd version of vi  Ican fix this:
ex $infile <<EOEX
:e ++ff=dos
:setlocal ff=unix
:wq
EOEX

echo "Copying .recpots to current working directory"

cp /home/bml1g12/project/pseudopotentials/*.recpot .

cp -i /home/bml1g12/my_scripts/ONETEP_related/run_onetep_iridis4_3.5.9.8.pbs . 

echo "--- Done. It's `date`"

