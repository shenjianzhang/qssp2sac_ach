# qssp2sac
convert output of QSSP to SAC file


## Filelist in folders
1. `qssp2sacmain-201*.sh`: main script for word flow
2. `mkhead-201*.f90` : source code for pre-work, reading header varibles from input file of QSSP and writing into datafile
3. `qssp2sac.f90` : source code for making sac file from datafile
4. `sacio.f90`: SAC I/O module, can be found in https://github.com/wangliang1989/sacio_Fortran
Note: * stands for 6 or 7 in folder qssp2016 or qssp2017
