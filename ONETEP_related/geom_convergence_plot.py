#!/usr/bin/python
import os, subprocess
import matplotlib.pyplot as plt
import numpy
from numpy import log
import sys
import time

filename = sys.argv[1]

#forces
forces = subprocess.check_output("grep '|F|' %s | awk {'print $4'}" %filename, shell=True)
forces_tol = subprocess.check_output("grep '|F|' %s | awk {'print $6'}" %filename, shell=True)
floats_forces = [float(x) for x in forces.split()]
forces_y = numpy.array(floats_forces)
floats_forces_tol = [float(x) for x in forces_tol.split()]
forces_tol_y = numpy.array(floats_forces_tol)

#|dR|

dR = subprocess.check_output("grep '|dR|' %s | awk {'print $4'}" %filename, shell=True)
dR_tol = subprocess.check_output("grep '|dR|' %s | awk {'print $6'}" %filename, shell=True)
floats_dR = [float(x) for x in dR.split()]
dR_y = numpy.array(floats_dR)
floats_dR_tol = [float(x) for x in dR_tol.split()]
dR_tol_y = numpy.array(floats_dR_tol)

#dE
dE = subprocess.check_output("grep 'dE/ion' %s | awk {'print $4'}" %filename, shell=True)
dE_tol = subprocess.check_output("grep 'dE/ion' %s | awk {'print $6'}" %filename, shell=True)
floats_dE = [float(x) for x in dE.split()]
dE_y = numpy.array(floats_dE)
floats_dE_tol = [float(x) for x in dE_tol.split()]
dE_tol_y = numpy.array(floats_dE_tol)

#x-axis
BFGS_step = []
i=0
while i < len(forces_y):
	BFGS_step.append(i)
	i+=1

fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("BFGS Step")
ax1.set_ylabel("log(convergence)")
plot1=ax1.plot(BFGS_step, log(forces_y), '-gx', label="|F|maxs (Ha/bohr)")
plot1=ax1.plot(BFGS_step, log(forces_tol_y), '-gx')
plot1=ax1.plot(BFGS_step, log(dR_y), '-bx', label = "|dR|max (bohr)")
plot1=ax1.plot(BFGS_step, log(dR_tol_y), '-bx')
plot1=ax1.plot(BFGS_step, log(dE_y), '-rx', label = "dE/ion (Ha)")
plot1=ax1.plot(BFGS_step, log(dE_tol_y), '-rx')
plt.legend()

timetag=time.strftime("%d_%m_%y__%M")
fig1.savefig('%s_convergence.pdf' %timetag) 
#plt.draw()
plt.show()
