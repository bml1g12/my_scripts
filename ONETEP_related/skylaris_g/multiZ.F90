! -*- mode: F90 ; mode: font-lock ; column-number-mode: true -*-

!=================================================================
! This program takes the information from a file of format:
!
! Nspecies
! block specis (without the %block and %endblock lines)
!
! and generates the new block species and block species_atomic_set
! to be stuck in ONETEP input files to initialise the NGWFs to 
! multiple-Z basis sets using the atomic solver.
!-----------------------------------------------------------------
! Note: use with script "atsol_multiZ" to generate the files.
! Note: only atoms up to Z<=18 will work.
!-----------------------------------------------------------------
! Created by Alvaro Ruiz Serrano on 16/06/2011
! Modified by Alvaro Ruiz Serrano to include PZ and PZP. 28/07/2011
!================================================================= 


program multiZ

  implicit none

  ! ars: declare species type
  type :: species
     character(len=6) :: id
     character(len=2) :: symbol
     integer :: zz
     integer :: nfuncs
     double precision :: radius
     integer :: family
     character(len=200) :: conf
  end type species

  ! ars: declare bs_params type
  type :: bs_params
     integer :: nfuncs
     character(len=200) :: conf
  end type bs_params

  integer, parameter :: SZ=1
  integer, parameter :: DZ=2
  integer, parameter :: TZ=3
  integer, parameter :: QZ=4
  integer, parameter :: PZ=5
  integer, parameter :: SZP=6
  integer, parameter :: DZP=7
  integer, parameter :: TZP=8
  integer, parameter :: QZP=9
  integer, parameter :: PZP=10
  integer, parameter :: SZ2P=11
  integer, parameter :: DZ2P=12
  integer, parameter :: TZ2P=13
  integer, parameter :: QZ2P=14
  integer, parameter :: PZ2P=15
  integer, parameter :: families=5 ! ars: groups of atoms with the same basis set
  integer, parameter :: input_unit = 11
  integer, parameter :: output_unit = 12

  ! ars: variables
  character(len=200) :: filename
  integer            :: bstype
  integer            :: nspecies
  integer            :: ierr
  type(bs_params)    :: table(1:families,SZ:PZ2P)
  type(species), allocatable :: allspecies(:)

  ! ars: init table
  ! ars: add more entries to the table to enable more elements and basis sets
  ! ars: set number of functions
  data table(1,:)%nfuncs /1,2,3,4,5,4,5,6,7,8,7,8,9,10,11/           ! Z=[1-2]
  data table(2,:)%nfuncs /1,2,3,4,5,4,5,6,7,8,7,8,9,10,11/           ! Z=[3-4]
  data table(3,:)%nfuncs /4,8,12,16,20,9,13,17,21,25,14,18,22,26,30/ ! Z=[5-10]
  data table(4,:)%nfuncs /1,2,3,4,6,4,5,6,7,8,7,8,9,10,11/           ! Z=[11-12]
  data table(5,:)%nfuncs /4,8,12,16,20,9,13,17,21,25,14,18,22,26,30/ ! Z=[13-18]

  ! ars: set configuration
  ! Z=[1-2]
  data table(1,:)%conf   /"","2s0","2s0 2pX 3s0","2s0 2pX 3s0 3pX 3dX 4s0 4pX","2s0 2pX 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0",&                               ! 0P
                          "2sX 2p0","2s0 2p0","2s0 2p0 3s0","2s0 2p0 3s0 3pX 3dX 4s0 4pX","2s0 2p0 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0",&                    ! 1P
                          "2sX 2p0 3sX 3p0","2s0 2p0 3sX 3p0","2s0 2p0 3s0 3p0","2s0 2p0 3s0 3p0 3dX 4s0 4pX","2s0 2p0 3s0 3p0 3dX 4s0 4pX 4dX 4fX 5s0"/ ! 2P 
  ! Z=[3-4]
  data table(2,:)%conf   /"","2pX 3s0","2pX 3s0 3pX 3dX 4s0","2pX 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0",&                                                     ! 0P
                          "2pX 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0",&                                                                    ! 0P
                          "2p0","2p0 3s0","2p0 3s0 3pX 3dX 4s0","2p0 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0",&                                                  ! 1P
                          "2p0 3s0 3pX 3dX 4s0 4pX 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0",&                                                                    ! 1P
                          "2p0 3sX 3p0","2p0 3s0 3p0","2p0 3s0 3p0 3dX 4s0","2p0 3s0 3p0 3dX 4s0 4pX 4dX 4fX 5s0",&                                      ! 2P
                          "2p0 3s0 3p0 3dX 4s0 4pX 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0"/                                                                     ! 2P
  ! Z=[5-10]
  data table(3,:)%conf   /"","3s0 3p0","3s0 3p0 3dX 4s0 4p0","3s0 3p0 3dX 4s0 4p0 4dX 4fX 5s0 5p0",&                                                     ! 0P
                          "3s0 3p0 3dX 4s0 4p0 4dX 4fx 5s0 5p0 5dX 5fX 5gX 6s0 6p0",&                                                                    ! 0P
                          "3sX 3pX 3d0","3s0 3p0 3d0","3s0 3p0 3d0 4s0 4p0","3s0 3p0 3d0 4s0 4p0 4dX 4fX 5s0 5p0",&                                      ! 1P
                          "3s0 3p0 3d0 4s0 4p0 4dX 4fx 5s0 5p0 5dX 5fX 5gX 6s0 6p0",&                                                                    ! 1P
                          "3sX 3pX 3d0 4sX 4pX 4d0","3s0 3p0 3d0 4sX 4pX 4d0","3s0 3p0 3d0 4s0 4p0 4d0",&                                                ! 2P
                          "3s0 3p0 3d0 4s0 4p0 4d0 4fX 5s0 5p0","3s0 3p0 3d0 4s0 4p0 4d0 4fx 5s0 5p0 5dX 5fX 5gX 6s0 6p0"/                               ! 2P
  ! Z=[11-12]
  data table(4,:)%conf   /"","3pX 3dX 4s0","3pX 3dX 4s0 4pX 4dX 4fX 5s0","3pX 3dX 4s0 4pX 4dX 4fX 5s0 5dX 5fX 5gX 6s0",&                                 ! 0P
                          "3pX 3dX 4s0 4pX 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0 6pX 6dX 7s0",&                                                                ! 0P
                          "3p0","3p0 3dX 4s0","3p0 3dX 4s0 4pX 4dX 4fX 5s0",&                                                                            ! 1P
                          "3p0 3dX 4s0 4pX 4dX 4fX 5s0 5dX 5fX 5gX 6s0","3p0 3dX 4s0 4pX 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0 6pX 6dX 7s0",&                  ! 1P
                          "3p0 4sX 4p0","3p0 3dX 4s0 4p0","3p0 3dX 4s0 4p0 4dX 4fX 5s0",&                                                                ! 2P
                          "3p0 3dX 4s0 4p0 4dX 4fX 5s0 5dX 5fX 5gX 6s0","3p0 3dX 4s0 4p0 4dX 4fX 5s0 5pX 5dX 5fX 5gX 6s0 6pX 6dX 7s0"/                   ! 2P
  ! Z=[13-18]
  data table(5,:)%conf   /"","3dX 4s0 4p0","3dX 4s0 4p0 4dX 4fX 5s0 5p0","3dX 4s0 4p0 4dX 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0",&                             ! 0P
                          "3dX 4s0 4p0 4dX 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0 6dX 7s0",&                                                                    ! 0P
                          "3d0","3d0 4s0 4p0","3d0 4s0 4p0 4dX 4fX 5s0 5p0",&                                                                            ! 1P
                          "3d0 4s0 4p0 4dX 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0","3d0 4s0 4p0 4dX 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0 6dX 7s0 7p0",&              ! 1P
                          "3d0 4sX 4pX 4d0","3d0 4s0 4p0 4d0","3d0 4s0 4p0 4d0 4fX 5s0 5p0",&                                                            ! 2P
                          "3d0 4s0 4p0 4d0 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0","3d0 4s0 4p0 4d0 4fX 5s0 5p0 5dX 5fX 5gX 6s0 6p0 6dX 7s0 7p0"/               ! 2P

  ! ars: process file
  call read_blocks()

  ! ars: look up in the table for basis set and write blocks
  call table_lookup()
  
  ! ars: write blocks species and species_atomic_set
  call write_blocks()
  
  ! ars: deallocate and exit
  deallocate(allspecies,stat=ierr)
  if (ierr.ne.0) stop "Problem deallocating allspecies"
  
  write(*,'(a)') "done! :)"

contains


  subroutine read_blocks()


    ! ars: reads prompt info and blocks on input file
    ! Created by Alvaro Ruiz Serrano on 16/06/2011

    implicit none

    ! ars: input info
    character(len=10)  :: bstype_tag, bstypeio
    integer :: isp



    ! ars: get arguments and welcome banner
    call getarg(1,filename)
    call getarg(2,bstypeio)
    read(bstypeio,'(i3)') bstype
    if(bstype.eq.1) then
       bstype_tag = "1Z0P"
    else if(bstype.eq.2) then
       bstype_tag = "2Z0P"
    else if(bstype.eq.3) then
       bstype_tag = "3Z0P" 
    else if(bstype.eq.4) then
       bstype_tag = "4Z0P"
    else if(bstype.eq.5) then
       bstype_tag = "5Z0P"
    else if(bstype.eq.6) then
       bstype_tag = "1Z1P"
    else if(bstype.eq.7) then
       bstype_tag = "2Z1P"
    else if(bstype.eq.8) then
       bstype_tag = "3Z1P"
    else if(bstype.eq.9) then
       bstype_tag = "4Z1P"
    else if(bstype.eq.10) then
       bstype_tag = "5Z1P"
    else if(bstype.eq.11) then
       bstype_tag = "1Z2P"
    else if(bstype.eq.12) then
       bstype_tag = "2Z2P"
    else if(bstype.eq.13) then
       bstype_tag = "3Z2P"
    else if(bstype.eq.14) then
       bstype_tag = "4Z2P"
    else if(bstype.eq.15) then
       bstype_tag = "5Z2P"
    else
       stop "W-What? ... Unknown basis set type -- ABORTING"
    end if

    write(*,'(5a)', advance='no') "Generating ", trim(bstype_tag) , " basis set for file ", trim(filename), " ... "


    ! ars: read from file
    open(unit=input_unit, form="formatted" ,file=trim(filename), action="read", status='old' )
    read(input_unit,'(i)') nspecies

    ! ars: allocate allspecies
    allocate(allspecies(1:nspecies), stat=ierr)
    if (ierr.ne.0) stop "Problem allocating allspecies"
    allspecies(:)%conf=""

    ! ars: fill allspecies
    do isp = 1, nspecies
       read(input_unit,*)allspecies(isp)%id, allspecies(isp)%symbol, allspecies(isp)%zz, allspecies(isp)%nfuncs, allspecies(isp)%radius
       if(allspecies(isp)%zz.le.2) then
          allspecies(isp)%family = 1
       elseif(allspecies(isp)%zz.le.4) then
          allspecies(isp)%family = 2
       elseif(allspecies(isp)%zz.le.10) then
          allspecies(isp)%family = 3
       elseif(allspecies(isp)%zz.le.12) then
          allspecies(isp)%family = 4
       elseif(allspecies(isp)%zz.le.18) then
          allspecies(isp)%family = 5
       else
          allspecies(isp)%family = 0
          write(*,'(/,3a)') "No data for ", trim(allspecies(isp)%symbol), "! You can add it manually ;)"
       end if

    end do

    ! ars: close input unit
    close(input_unit)


  end subroutine read_blocks


  subroutine table_lookup()


    ! ars: checks info on the lookup table
    ! Created by Alvaro Ruiz Serrano on 16/06/2011

    implicit none

    integer :: isp, family

    do isp = 1, nspecies
       family = allspecies(isp)%family
       if (family.gt.0) then
          allspecies(isp)%nfuncs = table(family,bstype)%nfuncs
          allspecies(isp)%conf = table(family,bstype)%conf
       end if
    end do

  end subroutine table_lookup

  subroutine write_blocks()

    ! ars: writes output file
    ! Created by Alvaro Ruiz Serrano on 16/06/2011

    implicit none

    integer :: isp
    character(len=200) :: outfilename

    outfilename = trim(filename)//"_out"
    

    ! ars: and now, write new file!
    open(unit=output_unit, form="formatted" ,file=trim(outfilename), action="write")

    ! ars: block_species
    write(output_unit,'(a)') " %block species"
    do isp = 1, nspecies
       write(output_unit,'(1x,a6,1x,a2,1x,i3,1x,i3,1x,f15.12,1x)') allspecies(isp)%id, allspecies(isp)%symbol, allspecies(isp)%zz, allspecies(isp)%nfuncs, allspecies(isp)%radius
    end do
    write(output_unit,'(a,/)') " %endblock species"


    ! ars: block_species_atomic_set
    write(output_unit,'(a)') " %block species_atomic_set"
    do isp = 1, nspecies
       if(bstype.eq.1) then
          write(output_unit,*) allspecies(isp)%id, '"SOLVE"'
       else
          write(output_unit,*) allspecies(isp)%id, '"SOLVE conf=', trim(allspecies(isp)%conf), '"'
       end if
    end do
    write(output_unit,'(a)') " %endblock species_atomic_set"

    ! ars: close output unit
    close(output_unit)

  end subroutine write_blocks


end program multiZ
