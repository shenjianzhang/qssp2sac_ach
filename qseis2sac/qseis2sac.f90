! read the result of QSEIS from an output file of QSEIS,
! and write it into a SAC file.

! Author:
!       Shenjian Zhang,    sjzhang@pku.edu.cn
!
! Compile:
!       gfortran -c sacio.f90
!       gfortran -c qseis2sac.f90
!       gfortran sacio.o qseis2sac.o -o qseis2sac
! Input:
!       datafile
!       Line 1: dt, npts, b0(time reduction)
!       Line 2: event and station info.
!       Line 3-N: time and data
! Output:
!       sacfile,named as:"receiver name"+"qseisoutp name"



program qssp2sac
use sacio
implicit none
integer :: flag
character(len=80) :: datafile,sacfile    ! file name
real, allocatable, dimension(:) :: data    ! data array
type(sachead) :: head
real time,datatmp   
real dt,b0,edep,rdep,dist    ! head info.
character(len=20) :: rname,qsspoutp    ! receiver name
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
    return
end if
! read head info.
read(102,203)dt,npts,b0
read(102,204)edep,rdep,dist,qsspoutp,rname
203 format(F8.2,I8,F8.2)
204 format(3(F8.2),A20,A20)
! read data
read(102,*)
allocate(data(1:npts))
j=1
10 read(102,*,end=11)time,datatmp
data(j) = datatmp
j = j+1
goto 10
11 close(102)

sacfile="./sacfiles/"//trim(adjustl(rname))//"_"//trim(adjustl(qsspoutp))
! ========write new sac file(including new head)========
call sacio_newhead(head,dt,npts,b0)    ! dt, npts, b0 are from headfile
head%evdp = edep    ! here, if edep<0, we should set head%evel
head%stdp = rdep
head%dist = dist
call sacio_writesac(sacfile,head,data,flag)

end program qssp2sac
