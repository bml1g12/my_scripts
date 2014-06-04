#!/usr/bin/python
#read in all subdirectories (dont provide arugment) and look for .onetep files
# extract forces and energies into data collection folder

import matplotlib.pyplot as plt
import numpy
from numpy import log
import os, subprocess, sys, time, csv, glob, shutil, inspect
data_folder='data_collection'
if os.path.exists(data_folder):
    shutil.rmtree(data_folder)
os.makedirs(data_folder)
data_folder_path=os.getcwd()+'/'+data_folder

shutil.copy(inspect.getfile(inspect.currentframe()), data_folder_path+'/') #copy this python script itself to the data_collection folder

dir_list=[] # a list to hold the names of all directorys 
string_dir_list = [] # a list to hold the names of all directories with string names
int_dir_list = [] # a list to hold the names of all directories with int names
for root, dirs, files in os.walk('.', topdown=True):
	dir_list.append(dirs)
	break


#seperate out directories that contain strings, and ignore them
print("dir_list[0] is originally:")
print(dir_list[0])
for x in dir_list[0]:
	print("x is %s" % x )
	try:
		int(x)
		int_dir_list.append(x)
	except:
		string_dir_list.append(x)
		print("Directory %s will eventually be ignored as it is in string list", x)
try:
	int_dir_list=[int(x) for x in int_dir_list] #converts dirlist of form [dirs, 0, 0] to form [floatdir1, floatdir2, ... ] 
	int_dir_list=sorted(int_dir_list, key=int)               # ascending order
except:
	print("couldn't convert the directory names to ints in order to sort them - directories might be read out of order. Proceeding")
	#dir_list=dir_list[0]
print("INT DIR LIST IS:")
print(int_dir_list)

#initialise csv
csvfilename='force_energy_summary.csv'
csvfile=open('./'+data_folder+'/'+csvfilename, 'wb')
csvwriter=csv.writer(csvfile)
header=["directory_name", "Energy_Ha", "Energy_eV", "Forces_Ha_per_bohr", "Forces_eV_per_Ang"]
csvwriter.writerow(header)
all=[]

x_axis=[]
energy_Ha_y=[]
forces_eV_y=[]

last_dir=len(int_dir_list)
converged_energy=False
converged_forces=False

i=0
#data='name'  #later filled with onetep filename
for dirname in int_dir_list:
	i+=1
	print("entering "+str(dirname))
	os.chdir(str(dirname))

	#find the .onetep file in cwd
	for name in glob.glob('*.nwo'):
	    data=name
	
	#get current folder and csv_row info
	current_folder_path, current_folder_name = os.path.split(os.getcwd())
	current_row=[]
	current_row.append(str(dirname))
	
	os.mkdir(data_folder_path+'/'+current_folder_name) #make an empty copy of each folder in the datacollection folder	
	shutil.copy(current_folder_path+'/'+current_folder_name+'/'+data, data_folder_path+'/'+current_folder_name) #populate it with just the .nwo files
	
	#energy extraction
	energy = subprocess.check_output("grep 'Total DFT' %s | awk {'print $5'}" %data, shell=True)
        try:
                floats_energy = float(energy.split()[0])
        except IndexError:
                print("For directory "+str(dirname)+" there was an IndexError - ignoring this directory")
                os.chdir('..')
                continue

	current_row.append(floats_energy) #energy in Ha
        energy_Ha_y.append(floats_energy)
	#forces extraction
#	forces = subprocess.check_output("perl /home/bml1g12/my_scripts/ONETEP_related/force.pl %s" %data, shell=True)
#	floats_forces = float(forces.split()[0])
#	current_row.append(floats_forces) #forces in Ha/bohr
#	forces_eV=floats_forces*27.2113846081672*1.88972613458355
#	current_row.append(forces_eV) #forces in eV/angstrom
#	forces_eV_y=[]

	#take note of the last energy and force, as this will be assumed to converged for the convergence error calculation
#	if i==last_dir:
#		converged_energy=energy_eV
#		converged_forces=forces_eV
	
	x_axis.append(dirname)
	all.append(current_row)
   	os.chdir('..')     

print("Writing a csv with energy")
csvwriter.writerows(all)
csvfile.close() 

#add columns showing convergence error normalised

#input_csv=open('./'+data_folder+'/'+csvfilename, 'rb')
#csvreader=csv.reader(input_csv)
#header = csvreader.next()
#header.append('Energy_conv_err_eV')
#header.append('Forces_conv_err_eV_per_Ang')
#
#all=[]
#all.append(header)
#
#for row in csvreader:
#	row.append(float(row[2])-converged_energy)
#	row.append(float(row[4])-converged_forces)
#	all.append(row)	


#output_csv=open('./'+data_folder+'/'+'force_energy_summary_processed.csv', 'wb')
#csvwriter=csv.writer(output_csv, lineterminator='\n')
#print("Writing another csv with the processed forces and energy")
#csvwriter.writerows(all)

#output_csv.close()

####Plotting
"""
i=0

fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
ax1.set_xlabel("X axis label")
ax1.set_ylabel("convergence error")
plot1=ax1.plot(x_axis, energy_Ha_y, '-gx', label="Energy (Ha)")
#plot1=ax1.plot(x_axis, forces_eV_y, '-gx', label="Forces (eV/A)")

plot1=ax1.plot(x_axis, log(dR_y), '-bx', label = "|dR|max (bohr)")
plot1=ax1.plot(x_axis, log(dR_tol_y), '-bx')
plot1=ax1.plot(x_axis, log(dE_y), '-rx', label = "dE/ion (Ha)")
plot1=ax1.plot(x_axis, log(dE_tol_y), '-rx')

plt.legend()

timetag=time.strftime("%d_%m_%y__%M")
fig1.savefig(data_folder_path+'/'+'%s_convergence.png' %timetag) 
#plt.draw()
plt.show()
"""
