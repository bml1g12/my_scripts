#!/usr/bin/python

import sys, os, subprocess
import re
import csv

num_atoms=8

fname=sys.argv[1]
atom_count=17

line=int(atom_count + 4)
text = subprocess.check_output("grep -A %0.f 'Input o' %s" % (line, fname), shell=True)

print(text)

geom_step=0
geom_step_list = [] #form [geom1, geom2, geom3...]
current_geometry = [] #form [element, x, y, z]
current_atom = []

i=1
for line in text.split("\n"):
        if re.search("Input o", line):
                geom_step+=1
                if geom_step > 1: #ensured we dont print an empty geometry for first time it find the word 'input o'
                        geom_step_list.append(current_geometry)
                        current_geometry=[]
                i=1
        if (i>5 and i < atom_count+6): #skips the first few lines. i should neevr reach num_atoms+6 (23) 
                j=2
                #print("line is %s and i is %i" % (line, i))
                list=line.rsplit()
 		print(list)
                current_atom=[list[0], list[3], list[4], list[5]]
        current_geometry.append(current_atom)
        i+=1

for geometry in geom_step_list:
	print(geometry)
 	print("\n")
	print("Or each atom")
	for atom in geometry:
		print(atom)
		print("\n")
#outfile=open("geom.xyz", 'wb')
#writer=csv.writer(outfile, delimiter='\n')
#for geom_step in geom_step_list:
#        writer.writerow(row)

