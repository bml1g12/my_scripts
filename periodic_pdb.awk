#!/bin/bash
#usage < input.pdb > output_fixed.pdb

commentLine=3 #up to and including the header lines of the pdb
awk '
{

if ($1 != "ATOM" && $1 != "HETATM")
    {print $0} # print lines of pdb without changing them

if (FNR == commentLine) 
    {xpbc=$2; ypbc=$3; zpbc=$4}

if ($1 == "HETATM")
    {
     x=$6; 
     y=$7; 
     z=$8;
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
     printf substr($0, 1, 31)
     printf "%8.3f", x
     printf "%8.3f", y
     printf "%8.3f", z
     printf substr($0,54)"\n";

 }
if ($1 == "ATOM")
 {
     x=$7; 
     y=$8; 
     z=$9;
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
     printf substr($0, 1, 31)
     printf "%8.3f", x
     printf "%8.3f", y
     printf "%8.3f", z
     printf substr($0,54)"\n";
 }



#else if (FNR > 9 && $1 == "ATOM" && $3 != "P") 
#    {print substr($0, 1, 24) n substr($0,27)}
#    if ($3 == "P") 
#        {n++
#        print substr($0, 1, 24) n substr($0,27)}
        
#else if ($1 != "ATOM" && FNR >9)
#    {print $0}
}
' commentLine=$commentLine
