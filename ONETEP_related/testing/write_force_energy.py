#!/usr/bin/python
import matplotlib.pyplot as plt
import numpy
from numpy import log
import os, subprocess, sys, time, csv, glob


#dir_l
dir_list=[]
for root, dirs, files in os.walk('.', topdown=True):
	dir_list.append(dirs)
	break
print(dir_list[0])

#initialise csv
csvfile=open('force_energy_summary.csv', 'wb')
csvwriter=csv.writer(csvfile)
header=["directory_name", "Energy (Ha)", "Energy (eV)", "Forces (Ha/atom)", "Forces (eV/atom)"]
csvwriter.writerow(header)

for dirname in dir_list[0]:
	
	print("entering "+dirname)
	os.chdir(dirname)

	#find the .onetep file in cwd
	for name in glob.glob('*.onetep'):
	    data=name
	
	#get current folder and csv_row info
	current_folder_path, current_folder_name = os.path.split(os.getcwd())
	current_row=[]
	current_row.append(dirname)

	#energy extraction
	energy = subprocess.check_output("grep '<-- CG' %s | awk {'print $3'}" %data, shell=True)
	floats_energy = float(energy.split()[0])
	current_row.append(floats_energy) #energy in Ha
	current_row.append(floats_energy*27.2113825435) #Energy in eV

	#forces extraction
	forces = subprocess.check_output("perl /home/bml1g12/my_scripts/ONETEP_related/force.pl %s" %data, shell=True)
	floats_forces = float(forces.split()[0])
	current_row.append(floats_forces) #forces in Ha/atom
	current_row.append(floats_forces*27.2113825435) #forces in eV/atom

	csvwriter.writerow(current_row)
   	os.chdir('..')     
   

"""
#x-axis
BFGS_step = []
i=0
while i < len(energy_y):
	BFGS_step.append(i)
	i+=1

fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("BFGS Step")
ax1.set_ylabel("log(convergence)")
plot1=ax1.plot(BFGS_step, log(energy_y), '-gx', label="|F|maxs (Ha/bohr)")
plot1=ax1.plot(BFGS_step, log(energy_tol_y), '-gx')
plot1=ax1.plot(BFGS_step, log(dR_y), '-bx', label = "|dR|max (bohr)")
plot1=ax1.plot(BFGS_step, log(dR_tol_y), '-bx')
plot1=ax1.plot(BFGS_step, log(dE_y), '-rx', label = "dE/ion (Ha)")
plot1=ax1.plot(BFGS_step, log(dE_tol_y), '-rx')
plt.legend()

timetag=time.strftime("%d_%m_%y__%M")
fig1.savefig('%s_convergence.png' %timetag) 
#plt.draw()
plt.show()
"""

csvfile.close()
