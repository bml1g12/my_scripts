#!/usr/bin/env perl
for $arg (@ARGV) {
    open(arg,$arg);
    while ( <arg> ) {
	if( / Stress Tensor \*{11}/../^ \*+$/ ) {
	    @line = split;
	    $sx = $line[2] if (/^ \*  x / );
	    $sy = $line[3] if (/^ \*  y / );
	    $sz = $line[4] if (/^ \*  z / );
	}
    }
    printf "%-24s  %12.6f %12.6f %12.6f\n",$arg,$sx,$sy,$sz;
}
