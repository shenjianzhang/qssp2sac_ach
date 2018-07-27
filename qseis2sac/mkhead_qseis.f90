! This program is used to get info. from the input file
! of QSEIS and get data from the output file of QSEIS,and 
! then make the data file for qseis2sac

! Author:
!       Shenjian Zhang,    sjzhang@pku.edu.cn
!
! Input:
!       Line 1. the name of qseis input file
!       Line 2. the name of qseis output file(data-file)
! Output:
!       N*headfiles, in each one:
!       Line 1: dt, npts, b0
!       Line 2: source dep; receiver dep; distance; receiver name
!       number of receiver, write to the screen




program prework

implicit none
integer,parameter :: nrmax=181
integer,parameter :: RR0=6371.0
real,parameter :: pi=3.1415926
integer flag,unit
character(len=80) :: rname(nrmax)    ! in input file
character(len=80) :: qseisinp,qseisoutp,headfile 
! qssp_input,qssp_output,file for qssp2sac
character(len=3) idxr    ! No. of receivers
real rdep,sdep    ! depths of the receiver and event(in km)
real r(nrmax)    ! location of receivers
real twindow,tstart,dt    ! time window, delta t
integer npts    ! sampling points
integer ieqdis,kmordeg    ! receiver distances
real dist    ! distance
real r1,r2,dr,v0
integer iv0    ! type of reduced time
integer nr
integer i,k


    
! file name
!write(*,*)"the qssp input file is:"
read(*,*)qseisinp
!write(*,*)"the qssp output file is:"
read(*,*)qseisoutp
!write(*,*)"the headfile for qssp2sac is"
!read(*,*)headfile
! open the qssp-input file
open(unit=201,file=qseisinp,iostat=flag)
if(flag .ne. 0) then
    write(*,*)"Unable to open the qseis input file ",qseisinp
    close(201)
    return
end if

! source depth(in km)
call skipline(201)
read(201,*)sdep
! receiver parameters
call skipline(201)
read(201,*)rdep    ! depth of receiver
read(201,*)ieqdis,kmordeg    ! equidistant, unit(km or deg)
read(201,*)nr    ! number of receivers
if(kmordeg .eq. 1) then    ! use km as distant unit
    dist = 1
else    ! deg2km
    dist = RR0*pi/180.d0
end if
if(ieqdis .eq. 1 .and. nr .ge. 1) then    ! equi-distance
    read(201,*)r1,r2
    if(nr .eq. 1) then
        dr=0.d0
    else
        dr=(r2-r1)/dble(nr-1)
    end if
    do i=1,nr
        r(i)=dist*(r1+dr*dble(i-1))
    end do
else
    read(201,*)(r(i),i=1,nr)
    do i=1,nr
        r(i) = dist*r(i)
    end do
end if
call skipline(201)
read(201,*)tstart,twindow,npts
if(twindow .le. 0.d0 .or. npts .le. 0) then
    stop 'Error in input: time window or sampling no <= 0!'
end if
dt = twindow/dble(npts)    ! delta t
call skipline(201)
read(201,*)iv0,v0
! Consider the time reduction of each receiver?

close(201)

! write info. into new files
do k=1,nr
    write(idxr,'(i3)')k
    write(rname(k),'(F8.2)')r(k)
    headfile="./datafiles/"//trim(adjustl(idxr))//'.'//qseisoutp
    open(unit=202,file=headfile)
    write(202,203)dt,npts,tstart
    write(202,204)sdep,rdep,r(k),trim(adjustl(qseisoutp)),trim(adjustl(rname(k)))
    close(202)
end do
write(*,'(I3)')nr

203 format(F8.2,I8,F8.2)
204 format(3(F8.2),A20,A20)

end program
