#!/usr/bin/python
import os, subprocess
import matplotlib.pyplot as plt
import numpy
from numpy import log
import sys
import time
import csv

filename = sys.argv[1]
eV=27.2113825435

#energies
energies = subprocess.check_output("grep '<-- E' %s | awk {'print $2'}" %filename, shell=True)
floats_energies = [float(x) for x in energies.split()]
energies_y = numpy.array(floats_energies)

print(floats_energies)

final_index=len(energies_y)-1
initial=floats_energies[0]*eV
final=floats_energies[final_index]*eV
print("Initial Energy (eV): %s" % initial)
print("Final Energy (eV): %s" % final)
dif = final - initial
print("Difference in Energy (eV): %s" % dif)
dif_kcal = dif*23.06035
print("Difference in Energy (kcal/mol): %s" % dif_kcal)

f=open('energies.csv', 'wb')
writer=csv.writer(f)
writer.writerow(["Initial Energy (eV): ", initial])
writer.writerow(["Final Energy (eV): ", final])
writer.writerow(["Difference in Energy (eV): ", dif])
writer.writerow(["Difference in Energy (kcal/mol): ", dif_kcal])
for e in floats_energies:
	writer.writerow([e])


f.close()


#x-axis
BFGS_step = []
i=0
while i < len(energies_y):
	BFGS_step.append(i)
	i+=1



fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("BFGS Step")
ax1.set_ylabel("Energy (Ha)")
plot1=ax1.plot(BFGS_step, energies_y, '-gx', label="Energy (Ha)")
plt.legend()

timetag=time.strftime("%d_%m_%y__%M")
fig1.savefig('%s_convergence.pdf' %timetag) 
#plt.draw()
fig1.savefig('convergence_energy.pdf')
plt.show()

