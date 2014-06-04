import sys, os
import numpy as np

filename=sys.argv[1]

#the [9:] corresponds to missing off the header
str = file(filename).readlines()

num_atoms = int(str[2].rsplit()[0])

X=int(str[3].rsplit()[0])
Y=int(str[4].rsplit()[0])
Z=int(str[5].rsplit()[0])

#the sclar field always starts after line 'start'
start=6+num_atoms

#make a space speerated string from each element of item of the file
scalar_field = ' '.join(str[start:])

#make a numpy array from the string
data = np.fromstring(scalar_field, sep=' ')

#iPut into a vector of shape X Y |, where X Y and Z can be found from top of the .cube file
data.shape = (X, Y, Z)

average_potential = np.sum(data)/np.size(data)

print(average_potential)
