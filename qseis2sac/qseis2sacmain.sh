#!/bin/bash

# This is a bash script to make SAC files from output files
# of qseis.
#
# Author:
#       Shenjian Zhang,    sjzhang@pku.edu.cn
# Input:
#       name of input file for qseis
#       name of target file(qseis output file)
# Inside program:
#       mkhead_qseis    # write head info. into datafiles
#       qseis2sac  # make SAC files according to datafiles
# Run:
#       ./qseis2sacmain.sh qseisinp qseisout


# prepare head info.
qseisinp=$1    # inp. file of qseis
qseisout=$2    # outp. file of qseis

echo $qseisinp > mkhead.inp
echo $qseisout >> mkhead.inp

rm -rf ./datafiles
mkdir ./datafiles
mkdir ./sacfiles 

NR=`./mkhead_qseis < mkhead.inp`    # the number of receivers
i=1
while((i <= ($NR)))
do
    datafile=$i.$qseisout
    let "j=i+1"
    # write data into datafiles
    awk '{print $1,$'$j'}' $qseisout >> ./datafiles/$datafile
    echo \"./datafiles/$datafile\" > qseis2sac.inp
    ./qseis2sac < qseis2sac.inp
    let "i += 1"
done

