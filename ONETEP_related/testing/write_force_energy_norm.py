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

#initialise csv
csvfilename='force_energy_summary.csv'
csvfile=open(csvfilename, 'wb')
csvwriter=csv.writer(csvfile)
header=["directory_name", "Energy (Ha)", "Energy (eV)", "Forces (Ha/atom)", "Forces (eV/atom)"]
csvwriter.writerow(header)

energy_eV_y=[]
forces_eV_y=[]

last_dir=len(dir_list[0])
converged_energy=False
converged_forces=False
i=1
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
	energy_eV=floats_energy*27.2113825435
	current_row.append(energy_eV) #Energy in eV
	energy_eV_y.append(energy_eV)

	#forces extraction
	forces = subprocess.check_output("perl /home/bml1g12/my_scripts/ONETEP_related/force.pl %s" %data, shell=True)
	floats_forces = float(forces.split()[0])
	current_row.append(floats_forces) #forces in Ha/atom
	forces_eV=floats_forces*27.2113825435
	current_row.append(forces_eV) #forces in eV/atom
	forces_eV_y=[]

	#take note of the last energy and force, as this will be assumed to converged for the convergence error calculation
	if i==last_dir:
		converged_energy=energy_eV
		converged_forces=forces_eV
	i+=1
	csvwriter.writerow(current_row)
   	os.chdir('..')     

csvfile.close() 

#add columns showing convergence error normalised
input_csv=open(csvfilename, 'rb')
csvreader=csv.reader(input_csv)
header = csvreader.next()
header.append('Energy Convergence Error (eV)')
header.append('Forces Convergence Error (eV/atom)')

all=[]
for row in csvreader:
	row.append(float(row[2])-converged_energy)
	row.append(float(row[4])-converged_forces)
	all.append(row)	

print(all)
output_csv=open('force_energy_summary_processed.csv', 'wb')
csvwriter=csv.writer(output_csv, lineterminator='\n')
csvwriter.writerows(all)

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
