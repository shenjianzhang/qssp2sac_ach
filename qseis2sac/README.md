# qseis2sac

## How to Compile

~~~bash
$ ifort mkhead-qseis.f90 skipline.f90 -o mkhead-qseis
$ ifort sacio.f90 -c
$ ifort qseis2sac.f90 -c
$ ifort sacio.o qseis2sac.o -o qssp2seis
$ ./qseis2sacmain.sh $INPUT_OF_QSEIS $OUTPUT_OF_QSEIS
~~~
