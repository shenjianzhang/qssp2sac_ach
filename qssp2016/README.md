# qssp2sac for QSSP2016

## How to Compile

~~~bash
$ ifort mkhead-2016.f90 skipline.f90 -o mkhead-2016
$ ifort sacio.f90 -c
$ ifort qssp2sac.f90 -c
$ ifort sacio.o qssp2sac.o -o qssp2sac
$ ./qssp2sacmain-2016.sh $INPUT_OF_QSSP $OUTPUT_OF_QSSP
~~~
