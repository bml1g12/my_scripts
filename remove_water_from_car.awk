#!/bin/bash

#use pipes in and out for input output

#remove water
#awk '{if (($7 != "o2*" && $9 != -0.820) && ($7 != "h1o" && $9 != 0.410)) {print $0}}' 

#remove silica and water
#awk '{if (($7 != "o2*" && $9 != -0.820) && ($7 != "h1o" && $9 != 0.410) && ($7 != "o2z") && ($8 != "Si")) {print $0}}' 

#remove silica and water and silanolate
awk '{if (($7 != "o2*" && $9 != -0.820) && ($7 != "o") && ($7 != "h1o" && $9 != 0.410) && ($7 != "o2z") && ($8 != "Si")) {print $0}}' 

#remove silica and water and silanolate AND SODIUMS!
#awk '{if (($7 != "o2*" && $9 != -0.820) && ($7 != "o") && ($7 != "na+") && ($7 != "h1o" && $9 != 0.410) && ($7 != "o2z") && ($8 != "Si")) {print $0}}' 

