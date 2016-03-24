#Usage: vmd -dispdev text -eofexit tmp2.pdb < myscript.tcl
package require pbctools
pbc wrap
set A [atomselect top "all"] 
$A writepdb newpdb.pdb 
