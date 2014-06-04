#!/usr/bin/python

import sys, os, subprocess
import re
import csv

num_atoms=8

fname=sys.argv[1]
text = subprocess.check_output("grep -A 17 -e 'New geometry' %s" % fname, shell=True)
geom_step=0
geom_step_list = [] #form [geom1, geom2, geom3...]
current_geometry = [] #form [element, x, y, z]
current_atom = []

i=999
for line in text.split("\n"):
	if re.search("No.", line):
		if geom_step >= 1:
			geom_step_list.append(current_geometry)
			current_geometry=[]
		geom_step+=1
 		i=0
	if (i>1) and (i<num_atoms+2): #skips the No. line and the --- line
 		#print("line is %s and i is %i" % (line, i))
		list=line.rsplit()
		current_atom=[list[1], list[3], list[4], list[5]]
	current_geometry.append(current_atom)
	i+=1
 
outfile=open("geom.xyz", 'wb')
writer=csv.writer(outfile, delimiter='\n')
for geom_step in geom_step_list:
	writer.writerow(row)


