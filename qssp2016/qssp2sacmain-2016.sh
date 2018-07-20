#!/bin/bash

# This is a bash script to make SAC files from output files
# of qssp.
#
# Author:
#       Shenjian Zhang,    sjzhang@pku.edu.cn
# Input:
#       name of input file for qssp
#       name of target file(qssp output file)
# Inside program:
#       mkhead    # write head info. into datafiles
#       qssp2sac  # make SAC files according to datafiles
# Run:
#       ./qssp2sacmain-2016.sh qsspinp qsspout


# prepare head info.
qsspinp=$1    # inp. file of qssp
qsspout=$2    # outp. file of qssp

echo $qsspinp > mkhead.inp
echo $qsspout >> mkhead.inp

#rm -rf ./datafiles
mkdir ./datafiles
mkdir ./sacfiles 

NR=`./mkhead-2016 < mkhead.inp`    # the number of receivers
i=1
while(((i <= $NR)))
do
    datafile=$i.$qsspout
    let "j=i+1"
    # write data into datafiles
    awk '{print $1,$'$j'}' $qsspout >> ./datafiles/$datafile
    echo \"./datafiles/$datafile\" > qssp2sac.inp
    ./qssp2sac < qssp2sac.inp
    let "i += 1"
done

