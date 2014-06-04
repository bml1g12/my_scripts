program read_potential

  implicit  none

  integer, parameter::dp=kind(1.0d0)
  integer::ns,nx,ny,nz
  integer::n1,n2,n,i,j,k
  real(kind=dp), dimension(:,:,:), allocatable::pot
  complex(kind=dp), dimension(:), allocatable::pot_line
  real(kind=dp)::ave_pot

  character(len=50)fname

  write(*,*)'Electrostatic potential file name?'
  read(*,*)fname
  open(unit=10,file=trim(fname),status='old',form='unformatted')
  open(unit=11,file=trim(fname)//'.fmt')
  open(unit=12,file=trim(fname)//'.line')

  read(10)ns
  read(10)nx,ny,nz
  write(*,*)'Grid size=',nx,ny,nz
  allocate(pot(nx,ny,nz))
  allocate(pot_line(nz))
  do n=1,nx*ny
     read(10)n1,n2,pot_line
     pot(n1,n2,:)=pot_line
  end do
  ave_pot=sum(pot)/real(nx*ny*nz,dp)
  write(*,*)'Average potential (Hartrees)=',ave_pot
  do i=1,nx
     do j=1,ny
        do k=1,nz
           write(11,'(3i4,f12.5)')i,j,k,pot(i,j,k)
        end do
     end do
  end do
  do i=1,nx
    write(12,'(i4,f12.5)')i,sum(pot(i,:,:))/real(ny*nz,dp)
  end do
  
  stop

end program read_potential
