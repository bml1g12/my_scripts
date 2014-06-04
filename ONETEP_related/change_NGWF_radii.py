#!/bin/python
#issue with this script idea is that it cant edit files inline as its taking grep input as a string :( 
import sys, commands

#filename = sys.argv[1]
 
grep_string= commands.getstatusoutput('grep -A 5 "^%block species$" test.dat')[1]

string = grep_string[1]

for line in string:
	nwgf_radii = line.rsplit()[4]
	if line == "%endblock species":
		break
