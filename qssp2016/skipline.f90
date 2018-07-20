subroutine skipline(fileunit)

implicit none

integer fileunit,iostat
character(len=1) readin    ! read the first character of the line

20 read(fileunit,'(a)',iostat=iostat)readin
if(iostat .ne. 0) then
    stop 'Error occured during read'
end if
if(readin(1:1) .ne. '#') then 
    backspace(fileunit)
    return
else
    goto 20
end if

return
end
