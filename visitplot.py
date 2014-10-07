import sys

#from visit import *
#Launch()
from visit import *

OpenDatabase("/local/scratch/bml1g12/calculations/onetep/NBO/EXPOC6_Ra_4a/esp/4a_potential.cube")
#AddPlot("Volume", "electron_density")
AddPlot("Molecule", "element")
m1=MoleculeAttributes()
m1.legendFlag=0
SetPlotOptions(m1)
AddPlot("Molecule", "element")
m2=MoleculeAttributes()
m2.legendFlag=0
SetPlotOptions(m2)
AddOperator("CreateBonds")
b=CreateBondsAttributes()
b.maxDist = (2, 4)
SetOperatorOptions(b)

DefineVectorExpression("g","gradient(electron_density)")
#AddPlot("Streamline","g")

DefineScalarExpression("g_norm", "magnitude(gradient(electron_density))")

AddPlot("Pseudocolor", "g_norm")

AddOperator("Slice")

s=SliceAttributes()

s.project2d=0
s.originType=s.Percent
s.originPercent=50
SetOperatorOptions(s)

DrawPlots()

# Creating a Pseudocolor plot and setting min/max values.
p = PseudocolorAttributes()
# Look in the object
print p
# Set the min/max values
p.min = 0.01
p.minFlag = 1
p.max = 3 
p.maxFlag = 1
SetPlotOptions(p)

#DeleteAllPlots()
