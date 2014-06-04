#!/usr/bin/python
import os, subprocess
import matplotlib.pyplot as plt
import numpy

#obtain current directory
cutoff_x = []
energy_y = []
forces_y = []

for dirname in os.walk('.').next()[1]:
        dir = dirname
	cutoff_x.append(dir)
        os.chdir(dirname)
        energy = subprocess.check_output("grep 'Final energy' *.castep | awk '{print $4}'", shell=True)
	energy_y.append(float(energy.split()[0]))
  	force = subprocess.check_output("MYVAR=$(find *.castep)\nperl /home/bml1g12/my_scripts/CASTEP_related/force.pl $MYVAR", shell=True)
        forces_y.append(float(force.split()[0]))
	os.chdir("..")
	print(dir)
	print(force)
	print(energy)
cutoff_x = numpy.array(cutoff_x)
energy_y = numpy.array(energy_y)
forces_y = numpy.array(forces_y)

normalised_energy = energy_y-energy_y[-1]
normalised_forces = forces_y-forces_y[-1]
#del_energy = numpy.diff(normalised_energy)
#del_forces = numpy.diff(normalised_forces)

fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("Cutoff Energy (eV)")
ax1.set_ylabel("Absolute System Energy (eV)")
plot1=ax1.plot(cutoff_x, energy_y, '-rx')

fig2 = plt.figure()
ax2 = fig2.add_subplot(111)
ax2.set_xlabel("Cutoff Energy (eV)")
ax2.set_ylabel("Absolute Forces (eV/A)")
plot2=ax2.plot(cutoff_x, forces_y, '-bo')

fig3 = plt.figure()
ax3 = fig3.add_subplot(111)
ax3.set_xlabel("Cutoff Energy (eV)")
ax3.set_ylabel("Convergence Error - System Energy (eV)")
plot3=ax3.plot(cutoff_x, normalised_energy, '-rx')

fig4 = plt.figure()
ax4 = fig4.add_subplot(111)
ax4.set_xlabel("Cutoff Energy (eV)")
ax4.set_ylabel("Convergence Error - Forces (eV/A)")
plot3=ax4.plot(cutoff_x, normalised_forces, '-rx')

fig1.savefig('cutoff_v_energy_convergence.png')
fig2.savefig('cutoff_v_forces_convergence.png')
fig3.savefig('cutoff_v_energy_convergence_error.png')
fig4.savefig('cutoff_v_forces_convergence_error.png')
#plt.draw()
#plt.show()


#for directory in [0-9]*/;
#do
#  echo $directory 
#  cd $directory
#  grep 'Final energy' *.castep | awk '{print $4}'
#  cd ..
#done
#!/bin/bash


