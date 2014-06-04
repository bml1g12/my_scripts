#!/usr/bin/env perl
my $atom = "O";
my $atreg = qr/^\*    $atom       1/o; #the spaces correspond to spaces in the file, match the exact pattern of a star symbol space space space O etc.
for $arg (@ARGV) {
    open(arg,$arg);
    while ( <arg> ) {
	if( / Unconstrained \*{12}/../^ \*+$/ ) { #match all lines after unconstrained I think
	    if( / Forces \*{12}/../^ \*+$/ ) { #match all lines after Forces I think
	      #print "$_\n";                   PRINTS THE CURRENT LINE
              if (/$atreg/)  { #from the above, matches the regex
   	  	  @line = split;
		  $e = $line[3];
	      }
            }
	}
    }
    printf "%.6f\n",$e;
}
