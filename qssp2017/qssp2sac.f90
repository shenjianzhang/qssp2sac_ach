! read the result of QSSP from an output file of QSSP,
! and write it into a SAC file.

! Author:
!       Shenjian Zhang,    sjzhang@pku.edu.cn
!
! Compile:
!       gfortran -c sacio.f90
!       gfortran -c qssp2sac.f90
!       gfortran sacio.o qssp2sac.o -o qssp2sac
! Input:
!       datafile
!       Line 1: dt, npts, b0(time reduction)
!       Line 2: event and station info.
!       Line 3-N: time and data
! Output:
!       sacfile,named as:"receiver name"+"qsspoutp name"



program qssp2sac
use sacio
implicit none
integer :: flag
character(len=80) :: datafile,sacfile    ! file name
real, allocatable, dimension(:) :: data    ! data array
type(sachead) :: head
real tm,datatmp,time   
real dt,b0,elat,elon,edep,rlat,rlon,rdep    ! head info.
character(len=40) :: rname,qsspoutp    ! receiver name
integer npts    ! for newhead,read from headfile
integer j
! input file name
write(*,*)"the data file is"
read(*,*)datafile

! ========read head and data from the data file========
open(unit=102,file=datafile,iostat=flag)
if(flag /= 0) then
    flag = 1
    write(*,*)"Unable to open data file ",datafile
    close(102)
    stop
end if
! read head info.
read(102,203)dt,npts,b0
read(102,204)elat,elon,edep,rlat,rlon,rdep,qsspoutp,rname
203 format(F8.2,I8,F8.2)
204 format(6(F8.2),2x,A40,A20)

! read data
read(102,*)
allocate(data(1:npts))
j=1
10 read(102,*,end=11)tm,datatmp
if (j .eq. 1) then
    time = tm
end if
if (time .ne. b0) then
    b0 = time
end if
data(j) = datatmp
j = j+1
goto 10
11 close(102)

sacfile="./sacfiles/"//trim(adjustl(rname))//"."//trim(adjustl(qsspoutp))
! ========write new sac file(including new head)========
call sacio_newhead(head,dt,npts,b0)    ! dt, npts, b0 are from headfile
head%evla = elat
head%evlo = elon
head%evdp = edep    ! here, if edep<0, we should set head%evel
head%stla = rlat
head%stlo = rlon
head%stdp = rdep
call sacio_writesac(sacfile,head,data,flag)

end program qssp2sac
