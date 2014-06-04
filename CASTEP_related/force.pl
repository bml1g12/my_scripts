#!/usr/bin/env perl
#takes the x coordinate force of the first $atom t matches and prints result

my $atom = "O";
#qr is a perl expression to print a regex after the / as a string
my $atreg = qr/^ \* $atom         1/o;
for $arg (@ARGV) {
    open(arg,$arg);
    while ( <arg> ) {
	if( / Forces \*{12}/../^ \*+$/ ) {
	    if (/$atreg/)  {
		@line = split;
		$e = $line[3];
	    }
	}
    }
#    printf "%-24s  %15.6f\n",$arg,$e;
     printf "$e\n";
}
