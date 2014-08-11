#!/usr/bin/python
import os, subprocess
import matplotlib.pyplot as plt
import numpy
from numpy import log
import sys
import time

filename = sys.argv[1]


#dE
dE = subprocess.check_output("grep '<-- E' %s | awk {'print $1'}" %filename, shell=True)
#dE_tol = subprocess.check_output("grep 'dE/ion' %s | awk {'print $6'}" %filename, shell=True)
floats_dE = [float(x) for x in dE.split()]
dE_y = numpy.array(floats_dE)
print(dE_y)
#floats_dE_tol = [float(x) for x in dE_tol.split()]
#dE_tol_y = numpy.array(floats_dE_tol)

#x-axis
BFGS_step = []
i=0
while i < len(dE_y):
	BFGS_step.append(i)
	i+=1

print(BFGS_step)

fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("BFGS Step")
ax1.set_ylabel("convergence not log")
plot1=ax1.plot(BFGS_step, dE_y, '-rx', label = "dE/ion (Ha)")
#plot1=ax1.plot(BFGS_step, log(dE_tol_y), '-rx')
plt.legend()

timetag=time.strftime("%d_%m_%y__%M")
fig1.savefig('%s_convergence.pdf' %timetag) 
#plt.draw()
plt.show()
