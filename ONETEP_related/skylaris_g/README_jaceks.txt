The following is a list of the utilities due to Jacek.

Last updated: 2011.06.30.

These should, preferably, be put in a directory which is in your $PATH, such as $HOME/bin.
Some of these utilities are scripts -- these should work on any POSIX-compliant system.
Others are statically-compiled C++ binaries -- these should work on x86_64 linuces.

All the utilities were written by Jacek Dziedzic, jack.erede@gmail.com.
No warranties, either express or implied, are hereby given for this software.
It is supplied without any accompanying guarantee, whether expressly mentioned, implied or tacitly assumed.

Checking up on running jobs (on Iridis)
---------------------------------------

qq
qctrl

Manipulation of .cube files
---------------------------

cube2charge  --	Computes the integral of the charge in a .cube file.
	       	EXAMPLE: cube2charge H2O_density.cube

cube2dx      --	Converts a .cube file to a .dx file. Allows for bohr<->A unit conversion.
	   	EXAMPLE: cube2dx H2O_density.cube

cube_wrapper -- Adds an extra layer of gridpoints to a .cube file, realizing PBCs.
		EXAMPLE: cube_wrapper periodize_me.cube

cubechop     --	Chops (zeroes) value below a certain threshold in a .cube file.
	    	EXAMPLE: cubechop noisy.cube 1E-12


Manipulation of .dx files
-------------------------

dx2cube      --	Converts a .dx file to a .cube file. Atomic positions can be read from a .dat file.
	   	EXAMPLE: dx2cube H2O_density.dx H2O.dat

dxaxpy       -- Performs y = a*x + b, reading x from a .dx file, writing y to a .dx file, a and b are scalars.
		EXAMPLE: dxaxpy multiply_me_by_two_pi.dx 6.283 0
	  
dxproduct    -- Performs y = a*x1*x2 + b, reading x1 and x2 from .dx files, writing y to a .dx file, a and b are scalars.
		EXAMPLE: dxproduct H2O_charge.dx H2O_potential.dx 0.5 0

dxsum        -- Performs y = a1*x1 + a2*x2, reading x1 and x2 from .dx files, writing y to a .dx file, a1 and a2 are scalars.
		EXAMPLE: dxsum core_charge.dx elec_charge.dx

dxintegrate  -- Computes the integral of a quantity in a .dx file.
		EXAMPLE: dxintegrate H2O_density.dx

dxgeom 	     -- Provides details about a geometry of a .dx file.
		EXAMPLE: dxgeom test.dx

dxstats      -- Provides statistical information for data in a .dx file.
                EXAMPLE: dxstats test.dx

dxgetpart    -- Extracts cuboid subsets or supersets from a .dx file.
		EXAMPLE: dxgetpart big.dx 10 10 10 30 30 30

dxchop 	     -- Chops (zeroes) value below/above a certain threshold in a .dx file.
		EXAMPLE: dxchop noisy.dx below 1E-10
		EXAMPLE: dxchop noisy.dx above 1E-10

dxcoarsen    -- Coarsens (picks out every nth point) from a .dx file.
		Remaining points are ignored, no averaging is performed.
		EXAMPLE: dxcoarsen fine.dx 5

dxserver     -- Serves requested datapoints from a .dx file.
		EXAMPLE: dxserver test.dx


Manipulation of .pdb files
--------------------------

pdb2box      -- Computes the bounding box of a .pdb file.
		EXAMPLE: pdb2box mysterious.pdb

pdb2dat      -- Converts a .pdb file to a .dat file.
		EXAMPLE: pdb2dat -x 40 -y 50.5 -z 25 my.pdb (uses a 40x50.5x25 [a0^3] box)
		EXAMPLE: pdb2dat -x 40 -y 50.5 -z 25 -a my.pdb (uses a 40x50.5x25 [A^3] box)
		EXAMPLE: pdb2dat -x 10 -y 10 -z 10 -m my.pdb (auto-size box, with 10 a0 of padding)


pdbstrip     -- Strips a desired species or residue from a .pdb file.
		EXAMPLE: pdbstrip my.pdb Na

pdbtranslate -- Translates atoms in a .pdb file.
	        EXAMPLE: pdbtranslate my.pdb 10 20 30


Manipulation of Gaussian input files
------------------------------------

gaussian2dat -- Converts simple Gaussian input files to a .dat file.
		EXAMPLE: gaussian2dat nitrate.g03 

gaussian2pdb -- Converts simple Gaussian input files to a .pdb file.
		EXAMPLE: gaussian2pdb nitrate.pdb


Manipulation of ONETEP .dat files
---------------------------------

dat2bounds   -- Calculates the widths (between cores and NGWFs) of a .dat file.
		EXAMPLE: dat2bounds mysterious.dat

datshift     -- Shifts coordinates of all atoms in a .dat file, leaving the box unchanged.
		EXAMPLE: datshift translate_me.dat 10 20 30

datcentre    -- Centres the molecule in a .dat file, leaving the box unchanged.
                Output goes to a new file (with a '_shifted' suffix).
		EXAMPLE: datcentre centre_me.dat

Energies from ONETEP runs
-------------------------

dE_binding   -- Calculates the binding energy given .out files for a complex, host and ligand.
	        EXAMPLE: dE_binding complex.out host.out ligand.out

dG_solvation -- Calculates the free energy of solvation given .out files for in-solvent and in-vacuum.
		EXAMPLE: dG_solvation in_solution.out in_vacuo.out

getenergy    -- Extracts the converged energy (or any of its components) given an .out file.
		EXAMPLE: getenergy NO3.out total
		EXAMPLE: getenergy NO3.out kinetic

plotgradient -- Produces a log-plot of the RMS gradient from a running or completed ONETEP calculation.


Trivial but useful
-----------------

getcol       -- picks a column from a file
                EXAMPLE: getcol data.txt 4
                EXAMPLE: cat data.txt | getcol 4
                
getline      -- picks a line from a file
                EXAMPLE: getline data.txt 4
                EXAMPLE: cat data.txt | getline 4
            
getlines     -- picks a range of lines from a file
                EXAMPLE: getlines data.txt 1000 1500

gettheselines   -- picks a set of lines from a file
                EXAMPLE: gettheselines data.txt 100 200 300 400 500
                
findmax      -- finds the maximum value in a file of numbers
                EXAMPLE: cat data.txt | findmax 
                EXAMPLE: findmax data.txt

findmin      -- function similarly
findavg
findabsavg
findsum

Other utilities
---------------

out2pqr      -- Reconstructs an input .pqr (.pdb-compatible) file given an .out file.
                Bond information, naturally, is lost.
		EXAMPLE: out2pqr NO3.out 

unitconv     -- Converts units.
		EXAMPLE: unitconv energy_ev energy_kcal_per_mol (to find out the conversion factor between eV and kcal/mol)
		EXAMPLE: unitconv force_si force_ev_over_A data.txt (to convert units in data.txt from N to eV/A)
		EXAMPLE: unitconv potential_si potential_au :30.5 (to convert 30.5V to Eh/e)

walltime     -- Shows the walltime of a ONETEP run or a set of runs along with the status of the run (completed, running, crashed).
                Useful for estimating walltimes of future runs and finding out if a job died due to walltime limit or not.

xyzxform     -- All-purpose manipulation of .xyz files (rotation, translation, scaling, renaming, picking out subsets, many more).

killthese    -- kills processes matching a regexp.
	        EXAMPLE: killthese -9 onetep
	        
renicethese  -- renices processes matching a regexp
                EXAMPLE: renicethese 10 onetep
                
                	        
