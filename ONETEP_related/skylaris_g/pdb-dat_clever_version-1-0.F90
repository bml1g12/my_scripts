! -*- mode: F90 ; mode: font-lock ; column-number-mode: true -*-


PROGRAM r1
  !!-------------------------------------------------------!!
  !! Creates complex ligand and host for a single pdb      !!
  !! Recognises Cl and F                                   !!
  !! Will recognise ligand currently only in moe format -  !!
  !! needs work to make this work for all pdbs.            !!
  !! Needs three arguements -1st is how many output files, !!
  !! 2nd whether coulomb-cutoff is used and                !!
  !! 3rd distance from the edge of the molecule to the sim !!
  !! cell and 4 is the input file.                         !!
  !!-------------------------------------------------------!!
  !! sjf first made 10/2008                                  !!
  !! modified 07/2010                                        !!
  !!-------------------------------------------------------!!

  IMPLICIT NONE

  INTEGER :: noatom, STAT, i, j, len_root, el_len, pla, num_files, plaend,simbufsize
  INTEGER :: charge(101:103), electron_count(101:103), atom_count(101:103),&
       o_count(101:103), h_count(101:103), s_count(101:103), n_count(101:103),&
       cl_count(101:103),c_count(101:103), F_count(101:103), FE_count(101:103)
  REAL (KIND(1.d0)), PARAMETER :: bohr_convert=1.88971616 
  REAL (KIND(1.d0)) :: X,Y,Z,crap,sim_dim,sqrcell, rvalue, buffcell,jj
  REAL (kind(1.d0)), Dimension(3) ::  min_negvalue, sim_cell, trans_mag,implicit_cell
  REAL (KIND(1.d0)), ALLOCATABLE :: cartesian_A(:,:), cartesian_B(:,:)
  CHARACTER (len=100) ::  buffer, comment,input_file, output_filec, output_filel,&
       output_filep,  rootname
  CHARACTER (len=3), ALLOCATABLE :: el_name(:,:)
  CHARACTER (len=6):: element, elem
  CHARACTER (len=6):: bin,bob, no_of_files, coulomb_in_use, sim_cell_buffer, cubic,&
       implicit_solvation, moe_file
  LOGICAL :: Onotwritten,Hnotwritten,Cnotwritten,Nnotwritten,Snotwritten,CLnotwritten,&
       fnotwritten, FEnotwritten, coulomb_used, cubic_cell, implicit_solv, moe
  ! sjf: open input file
#ifndef INTGETARG
  integer, external :: iargc
  external getarg
#endif 
  noatom=0
  charge=0
!sjf: input files
  call getarg(7,input_file)
  input_file = trim(input_file)
  call getarg(1,no_of_files)
!number of output files to generate
  if (no_of_files == 'help') then
     write(*,*)
     write(*,*) "pdb-dat <no. of files> <cutoff coulomb?> <sim cell buffer> <cubic cell?> <implicit solvent> <moe file> file.pdb"
     write(*,*) "i.e. pdb-dat 3 F 16 F F F complex.pdb"
     write(*,*)
  else
     read(no_of_files,'(i1)') num_files
  end if
  !wheter or not to use the cutoff coulomb
  call getarg(2,coulomb_in_use)
  if(coulomb_in_use == 'true' .or. coulomb_in_use == 'True' .or. coulomb_in_use == 'TRUE' .or. coulomb_in_use == 'T') then
     coulomb_used=.true.
  else
     coulomb_used=.false.
  end if
  call getarg(3,sim_cell_buffer)
  read(sim_cell_buffer,'(i3)') simbufsize
  call getarg(4,cubic)
  if(cubic == 'T' ) then
     cubic_cell=.true.
  else
     cubic_cell=.false.
  end if
  call getarg(5,implicit_solvation)
  if ( implicit_solvation == 'T' ) then
     implicit_solv=.true.
  else
     implicit_solv=.false.
  end if
  call getarg(6,moe_file)
  if ( moe_file == 'T' ) then
     moe=.true.
  else
     moe=.false.
  end if



  ! creates .dat output file of same name as .pdb file
  len_root=index(input_file,'.pdb') - 1
  IF(len_root>0) THEN
     rootname = input_file(1:len_root)
  ELSE
     STOP 'invalid input file'
  END IF

  if(num_files==3) then
     WRITE(output_filec,'(a80)') trim(rootname)//'_complex.dat'
     WRITE(output_filel,'(a80)') trim(rootname)//'_ligand.dat'
     WRITE(output_filep,'(a80)') trim(rootname)//'_host.dat'
  else
     WRITE(output_filec,'(a80)') trim(rootname)//'.dat'
  endif
  
  OPEN(UNIT=2,FILE=input_file)

  DO

     READ(2,'(a100)',end=100) buffer
     IF(index(buffer,'ATOM')/=0.or.index(buffer,'HETATM')/=0) THEN
        noatom=noatom+1
     ELSEIF(index(buffer,'END')/=0) THEN
        exit 
     END IF
  END DO


  ! allocate no. of atoms in array
100  ALLOCATE(cartesian_A(noatom,3),STAT=stat);ALLOCATE(cartesian_B(noatom,3),STAT=stat)
  ALLOCATE(el_name(noatom,2),STAT=stat)

  ! atom count
  o_count=0; h_count=0; s_count=0; n_count=0; cl_count=0; c_count=0; atom_count=0; F_count=0

  !  reopen file - rewind statement
  REWIND(2)

  electron_count = 0
  DO i=1,noatom
     DO
        READ(2,'(a100)',end=200) buffer
        IF(index(buffer,'ATOM')/=0.or.index(buffer,'HETATM')/=0) THEN         
           if (moe) then
              READ(buffer,*) bin, bin, element, bin, bin, bin, x, y, z
           else
              READ(buffer,*) bin, bin, element, bin, bin, x, y, z 
           end if
           !  store the coordinates in array cartesian_A, and element symbol in el_name
           cartesian_A(i,1)=x
           cartesian_A(i,2)=y
           cartesian_A(i,3)=z


           el_name(i,1)= trim(element)
           el_name(i,2)=trim('p')



           ! cuts element name to just its symbol      
           ! adds up electrons

           IF(index(element,'Cl')/=0) Then
              el_len=index(element,'C')
              elem = element(el_len:el_len+1)
              el_name(i,1)=trim(elem)   
              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 7
                 cl_count(103)=cl_count(103) + 1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 7
              ENDIF
              cl_count(101)=cl_count(101) + 1
              electron_count(101) = electron_count(101) + 7

           ELSEIF(index(element,'CL')/=0) Then
              el_len=index(element,'C')
              elem = element(el_len:el_len+1)
              el_name(i,1)=trim(elem) 
              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 7
                 cl_count(103)=cl_count(103) + 1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 7
              ENDIF
              cl_count(101)=cl_count(101) + 1
              electron_count(101) = electron_count(101) + 7

              ! special cases first: sometimes get CH, OH, NH also HN, HO, HC
              ! need to distinguish between these
           ELSEIF(index(element,'CH')/=0) Then
              el_len=index(element,'C') 
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 4
                 c_count(103)=c_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 4
              ENDIF
              c_count(101)=c_count(101)+1
              electron_count(101) = electron_count(101) + 4


           ELSEIF(index(element,'NH')/=0) Then
              el_len=index(element,'N')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 5
                 n_count(103)=n_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 5
              ENDIF
              n_count(101)=n_count(101)+1
              electron_count(101) = electron_count(101) + 5

           ELSEIF(index(element,'OH')/=0) Then
              el_len=index(element,'O') 
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)   

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 6
                 o_count(103)=o_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 6
              ENDIF
              o_count(101)=o_count(101)+1
              electron_count(101) = electron_count(101) + 6

           ELSEIF(index(element,'SH')/=0) Then
              el_len=index(element,'S')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 6
                 s_count(103)=s_count(103)+1 
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 6
              ENDIF
              s_count(101)=s_count(101)+1
              electron_count(101) = electron_count(101) + 6

           ELSEIF(index(element,'FE')/=0) Then
              el_len=index(element,'FE')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 8
                 FE_count(103)=FE_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 8
              ENDIF
              FE_count(101)=FE_count(101)+1
              electron_count(101) = electron_count(101) + 8

           ELSEIF(index(element,'H')/=0) Then
              el_len=index(element,'H')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 1
                 h_count(103)=h_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 1
              ENDIF
              h_count(101)=h_count(101)+1
              electron_count(101) = electron_count(101) + 1

           ELSEIF(index(element,'C')/=0) Then
              el_len=index(element,'C')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 4
                 c_count(103)=c_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 4
              ENDIF
              c_count(101)=c_count(101)+1
              electron_count(101) = electron_count(101) + 4

           ELSEIF(index(element,'S')/=0) Then
              el_len=index(element,'S')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 6
                 s_count(103)=s_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 6
              ENDIF
              s_count(101)=s_count(101)+1
              electron_count(101) = electron_count(101) + 6         

           ELSEIF(index(element,'O')/=0) Then
              el_len=index(element,'O')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)    

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 6
                 o_count(103)=o_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 6
              ENDIF
              o_count(101)=o_count(101)+1
              electron_count(101) = electron_count(101) + 6         

           ELSEIF(index(element,'N')/=0) Then
              el_len=index(element,'N')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 5
                 n_count(103)=n_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 5
              ENDIF
              n_count(101)=n_count(101)+1
              electron_count(101) = electron_count(101) + 5      

           ELSEIF(index(element,'F')/=0) Then
              el_len=index(element,'F')
              elem = element(el_len:el_len)
              el_name(i,1)=trim(elem)

              IF(INDEX(buffer,'HETATM')/=0) THEN
                 el_name(i,2)=trim('l') 
                 electron_count(103) = electron_count(103) + 7
                 F_count(103)=F_count(103)+1
              ENDIF
              IF(INDEX(buffer,'WAT')/=0) THEN
                 el_name(i,2)=trim('w') 
                 electron_count(102) = electron_count(102) + 7
              ENDIF
              F_count(101)=F_count(101)+1
              electron_count(101) = electron_count(101) + 7      


           ENDIF
           exit
        ELSEIF(index(buffer,'END')/=0) THEN
           exit
           ! comment from top of .pdb file
           !        ELSEIF(index(buffer,'REMARK')/=0) THEN
           !           read(buffer,'(a6,a100)') bin, comment
           !           comment=trim(comment)
        ENDIF
     ENDDO
  ENDDO

  !atoms sums
200  atom_count(101)=cl_count(101)+h_count(101)+o_count(101)+s_count(101)+n_count(101)+c_count(101)+F_count(101)
  atom_count(103)=cl_count(103)+h_count(103)+o_count(103)+s_count(103)+n_count(103)+c_count(103)+F_count(103)

  cl_count(102)=cl_count(101)-cl_count(103)
  F_count(102)=F_count(101)-F_count(103)
  h_count(102)=h_count(101)-h_count(103)
  o_count(102)=o_count(101)-o_count(103) 
  s_count(102)=s_count(101)-s_count(103)
  n_count(102)=n_count(101)-n_count(103)
  c_count(102)=c_count(101)-c_count(103)
  FE_count(102)=FE_count(101)-FE_count(103)
  atom_count(102)=cl_count(102)+h_count(102)+o_count(102)+s_count(102)+n_count(102)+c_count(102)+F_count(102)+FE_count(102)

  electron_count(102) = electron_count(101)-electron_count(103)


  ! WRITE(*,*) min_negvalue, trans_mag


 
  !  convert angstroms to bohr
  cartesian_B=cartesian_A*bohr_convert


  ! find min values (in bohr)
  min_negvalue(1)=minval(cartesian_B(:,1))
  min_negvalue(2)=minval(cartesian_B(:,2))
  min_negvalue(3)=minval(cartesian_B(:,3))




  !  find translation distance 
  trans_mag=simbufsize-min_negvalue

!  Translate points into simulation cell
  DO i=1,noatom
     cartesian_B(i,:)=cartesian_B(i,:)+trans_mag
  END DO

  !  simulation cell dimensions
  sim_cell(1)=maxval(cartesian_B(:,1))
  sim_cell(2)=maxval(cartesian_B(:,2))
  sim_cell(3)=maxval(cartesian_B(:,3))

  sim_cell=sim_cell+simbufsize


  if (cubic_cell) then 
     sqrcell=maxval(sim_cell)
     sim_cell=sqrcell
  endif

!if 
  if (implicit_solv) then
     do j=1,3
        dave: do i=1,30 
           jj=i*32+1
!           write(*,*) j, i, jj, sim_cell(j)
           if (jj .ge. sim_cell(j)) then
              implicit_cell(j)=jj
              exit dave
           end if
        end do dave
     end do
  end if


!write(*,*) sim_cell(1), sim_cell(2), sim_cell(3)
!write(*,*) implicit_cell(1), implicit_cell(2), implicit_cell(3)

  !data for coulomb cutoff. square simulatio cell, cutoff radius and buffer cell dimensions
!  sqrcell=maxval(sim_cell)
!  rvalue=(sqrcell*sqrt(3.d0))/2.d0
!  buffcell=sqrcell+rvalue

  if(num_files==3) then
     OPEN(UNIT=101,FILE=adjustl(output_filec))
     OPEN(UNIT=102,FILE=adjustl(output_filep))
     OPEN(UNIT=103,FILE=adjustl(output_filel))
  else
     OPEN(UNIT=101,FILE=adjustl(output_filec))
  endif


  if(num_files==3)then
     plaend=103
  else
     plaend=101
  endif

  do pla=101,plaend
     WRITE(pla,*)'! converted from .pdb file by SJF 1st phd program'
     !       WRITE(pla,'(a1,a80)')'!',comment
     WRITE(pla,*)
     WRITE(pla,*)'!number of electrons :',electron_count(pla),'doesnt take into acount charge'
     WRITE(pla,*)'!atoms'
     WRITE(pla,*)'! no. of C   :',c_count(pla)
     WRITE(pla,*)'! no. of H   :',h_count(pla)
     WRITE(pla,*)'! no. of O   :',o_count(pla)
     WRITE(pla,*)'! no. of S   :',s_count(pla)
     WRITE(pla,*)'! no. of N   :',n_count(pla)
     WRITE(pla,*)'! no. of Cl  :',cl_count(pla)
     WRITE(pla,*)'! no. of F   :',F_count(pla)   
     WRITE(pla,*)'! no. of Fe  :',FE_count(pla)
     WRITE(pla,*)'! total atoms:',atom_count(pla)
     WRITE(pla,*)
     WRITE(pla,*)
     WRITE(pla,*)
     WRITE(pla,*)'cutoff_energy       : 800 eV'
     WRITE(pla,*)'ngwf_threshold_orig : 0.000002'
     WRITE(pla,*)'kernel_cutoff       : 1000'
     WRITE(pla,*)'k_zero              : 3.5'
     WRITE(pla,*)'!write_xyz true'
     WRITE(pla,*)
     WRITE(pla,*)'elec_cg_max 0'
     WRITE(pla,*)'occ_mix 1.0'
     WRITE(pla,*)
     WRITE(pla,*)'minit_lnv 10 '
     WRITE(pla,*)'maxit_lnv 10 '
     WRITE(pla,*)    
     WRITE(pla,*)'write_denskern T'
     WRITE(pla,*)'write_tightbox_ngwfs T'
     WRITE(pla,*)
     WRITE(pla,*)'output_detail VERBOSE'
     WRITE(pla,*)
     WRITE(pla,*)'xc_functional PBE'
     WRITE(pla,*)'dispersion 1'
     WRITE(pla,*)
     WRITE(pla,*)'maxit_ngwf_cg 40'
     WRITE(pla,*)
!     WRITE(pla,*) '%block lattice_cart'
!     WRITE(pla,'(3f8.3)')  130.0 ,   0.0 ,   0.0
!     WRITE(pla,'(3f8.3)')    0.0 , 130.0 ,   0.0
!     WRITE(pla,'(3f8.3)')    0.0 ,   0.0 , 130.0
!     WRITE(pla,*) '%endblock lattice_cart'
     if (implicit_solv) then
        WRITE(pla,*) '%block lattice_cart'
        WRITE(pla,'(3f8.2)') dble(ceiling(implicit_cell(1))) ,   real(0) ,  real( 0)
        WRITE(pla,'(3f8.2)')    real(0)   , dble(ceiling(implicit_cell(2))) ,   real(0)
        WRITE(pla,'(3f8.2)')    real(0) ,  real(0) , dble(ceiling(implicit_cell(3)))
        WRITE(pla,*) '%endblock lattice_cart'
     else
        WRITE(pla,*) '%block lattice_cart'
        WRITE(pla,'(3f8.2)') dble(ceiling(sim_cell(1))) ,   real(0) ,  real( 0)
        WRITE(pla,'(3f8.2)')    real(0)   , dble(ceiling(sim_cell(2))) ,   real(0)
        WRITE(pla,'(3f8.2)')    real(0) ,  real(0) , dble(ceiling(sim_cell(3)))
        WRITE(pla,*) '%endblock lattice_cart'
     end if

     WRITE(pla,*)
     if (coulomb_used) then
        WRITE(pla,*)'!coulomb cutoff syntax'
        WRITE(pla,*)'coulombcutoffradius    :',ceiling(rvalue)
        WRITE(pla,*)'coulombcutofftype      : SPHERE'
        WRITE(pla,*)
        WRITE(pla,*)'coulombcutoffwriteint       : T'
        WRITE(pla,*)
     endif
     if (implicit_solv) then
        WRITE(pla,*)"! Turns on solvation"
        WRITE(pla,*)"is_implicit_solvent F"
        WRITE(pla,*)"is_include_cavitation F"
        WRITE(pla,*)"is_smeared_ion_rep T"
        WRITE(pla,*)""
        WRITE(pla,*)"! Parameters of the implicit solvent model "
        WRITE(pla,*)"is_solvent_surface_tension 0.0000133859 ha/bohr**2"
        WRITE(pla,*)"is_solvation_beta 1.3"
        WRITE(pla,*)"is_density_threshold 0.00035"
        WRITE(pla,*)"is_bulk_permittivity 78.54"
        WRITE(pla,*)"is_dielectric_model fix_initial"
        WRITE(pla,*)""
        WRITE(pla,*)"! Numerical details"
        WRITE(pla,*)"is_multigrid_nlevels 4"
        WRITE(pla,*)"is_smeared_ion_width 0.8"
        WRITE(pla,*)"is_discretization_order 8"
        WRITE(pla,*)"is_bc_coarseness 5"
        WRITE(pla,*)"is_bc_surface_coarseness 1"
     end if
     WRITE(pla,*)
     WRITE(pla,*) '%block positions_abs'
     DO i=1,noatom
        IF(writeatom(el_name(i,2),pla)) THEN
           WRITE(pla,'(a3,3f15.8)')  el_name(i,1),cartesian_B(i,1),cartesian_B(i,2),cartesian_B(i,3)
        ENDIF
     ENDDO
     WRITE(pla,*)'%endblock positions_abs'
     WRITE(pla,*)
     WRITE(pla,*)
     WRITE(pla,*)'%block species'


     Onotwritten = .true.
     Hnotwritten = .true.
     Cnotwritten = .true.
     Nnotwritten = .true.
     CLnotwritten = .true.
     Snotwritten = .true.
     Clnotwritten = .true.
     Fnotwritten = .true.

     DO i=1,noatom
        IF(writeatom(el_name(i,2),pla)) THEN
           select case(el_name(i,1))
           case ('O')
              if (Onotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' O   8 4 7.0'
                 Onotwritten = .false.
              end if
           case ('H')
              if (Hnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' H   1 1 7.0'
                 Hnotwritten = .false.
              end if
           case ('C')
              if (Cnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' C   6 4 7.0'
                 Cnotwritten = .false.
              END if
           case ('N')
              IF  (Nnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' N   7 4 7.0'
                 Nnotwritten = .false.
              END IF
           case ('S')
              IF  (Snotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' S  16 9 7.0'
                 Snotwritten = .false.
              END IF
           case ('Cl')
              IF  (Clnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' Cl 17 9 7.0'
                 Clnotwritten = .false.
              END IF
           case ('CL')
              IF  (CLnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' Cl 17 9 7.0'
                 CLnotwritten = .false.
              END IF
           case ('F')
              IF  (Fnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' F   9 9 7.0'
                 Fnotwritten = .false.
              END IF
           case ('FE')
              IF  (FEnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' Fe  26 16 7.0'
                 FEnotwritten = .false.
              END IF
           end select
        ENDIF
     end DO
     WRITE(pla,*)'%endblock species'
     WRITE(pla,*)
     WRITE(pla,*)
     WRITE(pla,*) '%block species_pot'

     Onotwritten = .true.
     Hnotwritten = .true.
     Cnotwritten = .true.
     Nnotwritten = .true.
     CLnotwritten = .true.
     Snotwritten = .true.
     Clnotwritten = .true.
     Fnotwritten = .true.
     Fenotwritten = .true.

     DO i=1,noatom
        IF(writeatom(el_name(i,2),pla)) THEN
           select case(el_name(i,1))
           case ('O')
              if (Onotwritten) then
                 WRITE(pla,*) el_name(i,1) ,' O_02.recpot'
                 Onotwritten = .false.
              end if
           case ('H')
              if (Hnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' H_04.recpot'
                 Hnotwritten = .false.
              end if
           case ('C')
              if (Cnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' C_01.recpot'
                 Cnotwritten = .false.
              END if
           case ('N')
              IF  (Nnotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' N_00.recpot'
                 Nnotwritten = .false.
              END IF
           case ('S')
              IF  (Snotwritten) then
                 WRITE(pla,*) el_name(i,1) , ' S_00.recpot'
                 Snotwritten = .false.
              END IF
           case ('CL')
              IF  (CLnotwritten) then
                 WRITE(pla,*)  el_name(i,1), ' Cl_00.recpot'
                 CLnotwritten = .false.
              END IF
           case ('Cl')
              IF  (Clnotwritten) then
                 WRITE(pla,*)  el_name(i,1), ' Cl_00.recpot'
                 Clnotwritten = .false.
              END IF
           case ('F')
              IF  (Fnotwritten) then
                 WRITE(pla,*)  el_name(i,1), ' F_00.recpot'
                 Fnotwritten = .false.
              END IF
           case ('FE')
              IF  (FEnotwritten) then
                 WRITE(pla,*)  el_name(i,1), ' Fe_00.recpot'
                 FEnotwritten = .false.
              END IF
           end select
        ENDIF
     end DO

     WRITE(pla,*) '%endblock species_pot'
  end do
CONTAINS

  LOGICAL function writeatom(el_type,pla)

    integer, INTENT(in) :: pla
    character, INTENT(in) :: el_type

    select case(pla)
    case (103)
       if(el_type=='l') THEN
          WRITEatom = .true.
       else
          writeatom = .false.
       ENDIF
    case (102)
       if(el_type=='p'.or.el_type=='w') THEN
          writeatom= .true.
       else
          writeatom = .false.
       ENDIF
    case (101)
       if(el_type=='l'.or.el_type=='p'.or.el_type=='w') then
          writeatom = .true.
       else
          writeatom = .false.
       ENDIF
    END select
  END function writeatom

end PROGRAM r1

