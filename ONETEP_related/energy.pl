#!/usr/bin/env perl
for $arg (@ARGV) {
    open(arg,$arg);
    while ( <arg> ) {
	if (/^Final energy, E/ ) {
	    @line = split;
	    $e = $line[4];
	}elsif(/^Final energy/ ) {
	    @line = split;
	    $e = $line[3];
	}
    }
    printf "%-24s  %15.6f\n",$arg,$e;
}
