#!/bin/bash
#usage: input.pdb > output_fixed.pdb
commentsline=2
awk '
BEGIN{n=1}
{
if (FNR <= comline) print $0;  

else if (FNR > comline) #&& $1 == "HETATM" && $3 != "P") 
    {print substr($0, 1, 24) n substr($0,27)}
    if ($3 == "P") 
        {n++
        print substr($0, 1, 24) n substr($0,27)}
        
else if ($1 != "HETATM" && FNR > comline)
    {print $0}
}
' comline=$commentsline ./$1
