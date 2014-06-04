#!/bin/bash
#extracts energy from guassian .out files
#tested on an IS solvent output file
grep 'SCF Done' out.log | awk {'print $5'}
