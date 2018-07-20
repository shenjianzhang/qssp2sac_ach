! This program is used to get info. from the input file
! of QSSP and get data from the output file of qssp2017,and 
! then make the data file for qssp2sac

! Author:
!       Shenjian Zhang,    sjzhang@pku.edu.cn
!
! Input:
!       Line 1. the name of qssp input file
!       Line 2. the name of qssp output file(data-file)
! Output:
!       N*headfiles, in each one:
!       Line 1: dt, npts, b0
!       Line 2: source lat,lon,dep; receiver lat,lon,dep; receiver name
!       number of receiver, write to the screen
! Need to update:
!       find the first source patch as the event time



program prework

implicit none

integer,parameter :: nrmax = 181
integer flag,unit
character(len=80) :: outfile    ! in input file
character(len=80) :: qsspinp,qsspoutp,headfile 
! qssp_input,qssp_output,file for qssp2sac
character(len=3) idxr    ! No. of receivers
real dpr,dpe    ! depths of the receiver and event(in km)
real twindow,twinout,dt    ! time window, delta t
integer npts    ! sampling points
real fcut,slwmax,supress    ! max freq., max slowness, supress factor
integer ipath,isurf    ! switch of turning-point and free-surface filter
real minpath,maxpath,RR0    ! range of turning-point,radius
real cfgr    ! critical freq. for gravity
integer cldeggr    ! critical l-order for gravity
integer psv,sh,ldegmin,ldegmax    ! selection of modes and min. max. of l-order
integer ngrn    ! number of discrete source,Green's fun
integer grnsel(50)    ! Green's function calculation selection
real rs    ! estimated radius of source patch
character(len=80) grndir
character(len=80) grnfile(50)    ! file names for Green's functions
real grndep(50)    ! source depths, max source =50
integer ns,sdfsel,nr    ! number of sources, source data format selection, num. of receivers
real munit,mtt,mpp,mrr,mtp,mpr,mrt,strike,dip,rake,funit,fe,fn,fv    ! moment/single force
real lats(50),lons(50),deps(50),togs(50),trss(50)    ! sources
real slat,slon,sdep    ! ========source info.========
integer icmp(6)    ! type of the output result, e.g. disp,vel, acc...
logical seldis,selvel,selacc,selpre,seltil,selgra 
integer nlpf,ioutform    ! order of the bandpass filter,outfile format
real f1corner,f2corner,slwlwcut,slwupcut    ! bandpass corner, slowness cut-off
real latr(nrmax),lonr(nrmax),tred(nrmax)    ! receiver info.
character(len=80) rname(nrmax)    ! receiver names
integer i,is,ig,ir,j,k    ! index

! file name
!write(*,*)"the qssp input file is:"
read(*,*)qsspinp
!write(*,*)"the qssp output file is:"
read(*,*)qsspoutp
!write(*,*)"the headfile for qssp2sac is"
!read(*,*)headfile
! open the qssp-input file
open(unit=201,file=qsspinp,iostat=flag)
if(flag .ne. 0) then
    write(*,*)"Unable to open the qssp input file ",qsspinp
    close(201)
    return
end if

! uniform receiver depth
call skipline(201)
read(201,*)dpr
! time(frequency) sampling
call skipline(201)
read(201,*)twindow,dt
read(201,*)fcut    ! max freq. of Green's functions
read(201,*)slwmax  ! max slowness of Green's functions
read(201,*)supress ! supress factor for time aliasing
read(201,*)ipath,minpath,maxpath  ! swith and range of the turning-ppint
read(201,*)RR0,isurf  ! radius of earth(km), free-surface filter switch
! cutoffs of spectra
call skipline(201)
read(201,*)cfgr,cldeggr    ! critical freq. and critical l-order for gravity
call skipline(201)
read(201,*)psv,sh,ldegmin,ldegmax
! Green's function files
call skipline(201)
read(201,*)ngrn,rs,grndir
if(ngrn.le.0)then
    stop ' bad number of source depths!'
else if(ngrn .gt. 50)then
        stop ' number of source depths exceeds the maximum!'
end if
do i = 1,ngrn    ! cycle of the sources
!   call skipline(201)
    read(201,*)grndep(i),grnfile(i),grnsel(i)
    if(grnsel(i) .lt. 0 .or. grnsel(i) .gt. 1)then
        stop ' bad Green function selection!'
    endif
end do
! multi-event source parameters
call skipline(201)
read(201,*)ns, sdfsel
if(sdfsel .eq. 1) then    ! source data format 1
    do is = 1,ns
        call skipline(201)
        read(201,*)munit,mrr,mtt,mpp,&
        &mrt,mpr,mtp,lats(is),lons(is),deps(is),togs(is),trss(is)
    end do
else if(sdfsel .eq. 2) then
    do is = 1,ns
        call skipline(201)
        read(201,*)munit,strike,dip,rake,&
        &lats(is),lons(is),deps(is),togs(is),trss(is)
    end do
else if(sdfsel .eq. 3) then    ! single force
    do is = 1,ns
        call skipline(201)
        read(201,*)funit,fe,fn,fv,lats(is),lons(is),deps(is),togs(is),trss(is)
    end do
else
    stop ' bad selection for the source data format!'
end if
! ====use the first line as the source info.====
slat = lats(1)
slon = lons(1)
sdep = deps(1)
! ==== for the head of sac ====
! receiver parameters
call skipline(201)
read(201,*)(icmp(j),j=1,11)
seldis=icmp(1).eq.1
selvel=icmp(2).eq.1
selacc=icmp(3).eq.1
selpre=icmp(4).eq.1
seltil=icmp(5).eq.1
selgra=icmp(6).eq.1
call skipline(201)
read(201,*)outfile
! call skipline(201)
read(201,*)twinout
npts = int(twinout/dt)    ! sampling points???
read(201,*)nlpf,f1corner,f2corner    ! bandpass para.
read(201,*)slwlwcut,slwupcut
read(201,*)nr    ! number of the receivers
do ir=1,nr
!   call skipdoc(unit)
    read(201,*)latr(ir),lonr(ir),rname(ir),tred(ir)
end do
close(201)
! write info. into new files
do k=1,nr
    write(idxr,'(i3)')k
    headfile="./datafiles/"//trim(adjustl(idxr))//'.'//qsspoutp
    open(unit=202,file=headfile)
    write(202,203)dt,npts,tred(k)
    write(202,204)slat,slon,sdep,latr(k),lonr(k),dpr,trim(adjustl(qsspoutp)),trim(adjustl(rname(k)))
    close(202)
end do
write(*,'(I3)')nr

203 format(F8.2,I8,F8.2)
204 format(6(F8.2),2X,A40,A20)

end program
