#!/bin/bash
#need to run as ./ if this script is named as a .awk file
#usage < input.pdb > output_fixed.pdb

#untested

commentLine=5 #up to and including the header lines of the pdb
awk '
{
if (NR <= commentLine)
    {print $0} # print lines of pdb without changing them

if (FNR == commentLine) 
    {
     xpbc=$2;
     ypbc=$3;
     zpbc=$4;
    }

if (FNR > commentLine && $1 !~ /end/)
    {
     x=$2; 
     y=$3; 
     z=$4;
     tmp=x/xpbc;
     tmpint=int(tmp);
     floortmp=(tmpint==tmp||tmp>0)?tmpint:tmpint-1;
     x=x-floortmp*xpbc;
     
     tmp=y/ypbc;
     tmpint=int(tmp);
     floortmp=(tmpint==tmp||tmp>0)?tmpint:tmpint-1;
     y=y-floortmp*ypbc;
    
     tmp=z/zpbc;
     tmpint=int(tmp);
     floortmp=(tmpint==tmp||tmp>0)?tmpint:tmpint-1;
     z=z-floortmp*zpbc;
     printf substr($0, 1, 7)
     printf "%13.9f  ", x
     printf "%13.9f  ", y
     printf "%13.9f", z
     printf substr($0,51)"\n";

 }

if ($1 ~ /end/)
    {print $0}


}
' commentLine=$commentLine 
