! REDFIT-X:
!=========
!
! Estimates cross-spectrum, coherency and phase spectrum from two unevenly spaced time series
! where the significance is evaluated with Monte Carlo simulations!
!
! The program is based on the previous program REDFIT (Schulz and Mudelsee, 2002),
! where autospectrum is estimated from unevenly spaced time series  and tested against red noise
! (the AR(1) parameter is estimated directly from the unevenly spaced time series).
!
! Main changes:
!       o Cross-spectral analysis has been implemented
!       o Significance measurements evaluated with Monte Carlo simulations
!       o Coherency Spectrum: Monte Carlo false alarm level
!       o Phase Spectrum: Monte Carlo confidence interval
!
!
! Authors:
! ========
! Kristin B. Olafsdottir
! Climate Risk Analysis
! E-mail: olafsdottir@climate-risk-analysis.com
!
! Michael Schulz,
! MARUM - Center for Marine Environmental Sciences and Faculty of Geosciences, Univ. Bremen
! E-mail:  mschulz@marum.de
!
! Manfred Mudelsee
! Climate Risk Analysis
! E-mail: mudelsee@climate-risk-analysis.com
!
! Reference: Olafsdottir, K.B., Schulz, M. and Mudelsee, M.(2016)
!               REDFIT-X: Cross-spectral analysis of unevenly spaced
!               paleoclimate time series. Computers and Geosciences, 91, 11-18.
!               doi:10.1016/j.cageo.2016.03.001
!
! Reference: Schulz, M. and Mudelsee, M. (2002) REDFIT: Estimating
!               red-noise spectra directly from unevenly spaced paleoclimatic
!               time series. Computers and Geosciences, 28, 421-426.
!
!
! Input:   parameter namelist; passed as configuration file
! ====
!
!       &cfg
!          fnin(1) = 'c:\ mydata\ x.dat',   Input file name  for the 1st time series data
!          fnin(2) = 'c:\mydata\ y.dat',    Input file name  for the 2nd time series data
!          fnout = 'REDFIT-X-result',       The results are written to files with this name (plain text files with various file extensions)
!          x_sign =  F,                     [T/F] Change the sign of the first time series(if T, (add minus in front of the data) default= F
!          y_sign =  F,                     [T/F] Change the sign of the first time series, default = F
!          nsim =       1000,               Number of simulations (1000-2000 is recommended)
!          mctest = T,                      [T/F] Estimate the significance of auto and coherency spectrum with Monte Carlo simulations
!          mctest_phi= T,                   [T/F] Estimate Monte Carlo confidence interval for the phase spectrum
!          rhopre(1) = -999.0,              Prescribed value for rho for the first time series, not used if rho < 0 (default = -999.0)
!          rhopre(2) = -999.0,              Prescribed value for rho for the second time series, not used if rho < 0 (default = -999.0)
!          ofac = 4.0,                      Oversampling value for Lomb-Scargle Fourier transform (typical values: 2.0-4.0)
!          hifac = 1.0,                     Max. freq. = HIFAC * <f_Nyq> (Default = 1.0)
!          n50 = 8,                         Number of WOSA segments (50 % overlap)
!          alpha = 0.05,                    Significance level (0.01, 0.05[default], 0.1)
!          iwin = 1                         Window type 0: Rectangular
!       /                                               1: Welch
!                                                       2: Hanning
!                                                       3: Triangular
!                                                       4: Blackman-Harris
!
!
! The two time series data need to be in two separated data files.
! Format of the time-series file:
!
!            # comment lines
!            # .
!            # .
!            t(1)   x(1)
!            t(2)   x(2)
!             .       .
!             .       .
!            t(N)   x(N)
!
! where t(1) < t(2) < ... < t(N) are GEOLOGICAL AGES! The maximum number of
! data points N is only limited by the available amount of memory.

! Output:
! ======
! * Estimated parameters and spectra (including significane levels) are
!   written to FNOUT (self-explanatory!).
!
! * Error and warning messages are written to REDFIT-X.LOG.
!
! Notes:
! ------
! * A linear trend is subtracted from each WOSA segment.
!
! * tau is estimated separately for each WOSA segment and subsequently
!   averaged.
!
! * Default max. frequency = avg. Nyquist freq. (hifac = 1.0).
!
! * Input times must be provided as ages since a "reversed" geological time
!   vector is assumed in subroutine TAUEST.
!
!   June 2015 V. 1.0 released
!   modifications:
!      19.08.16 - V. 1.1
!               - bug fix: after replacing duplicate time series program crashed
!                 (TimeSeriesy.avg not assigned to fnin(2))
!               - add [carriagecontrol = "FORTRAN"] to open statements for output
!                 (Non F95! Required by LF95 to avoid leading blank in each record)
!               - ensure that alpha is one of the values required in MC routine (0.01, 0.05, or 0.1)
!
!===================================================================================================
!
!need to uncomment if gfortran is used
!include 'c:\msdata\src\f90\recipes\recipes\nrtype.f90'
!include 'c:\msdata\src\f90\recipes\recipes\nr.f90'
!include 'c:\msdata\src\f90\recipes\recipes\nrutil.f90'
!--------------------------------------------------------------------------
!
!--------------------------------------------------------------------------
!                    M O D U L E   D E F I N I T O N S
!--------------------------------------------------------------------------
! global array dimensions and constants
! -------------------------------------
  module const
     implicit none
     public
     character (len = 26) :: vers = 'REDFIT-X 1.1 (August 2016)'
     real, parameter :: pi = 3.141592653589793238462643383279502884197
     real, parameter :: tpi = 2.0 * pi
     integer :: maxdimx, maxdimy                !the length of x and y
     integer :: nout                                    !nout = nfreq
     integer,parameter :: n_fnin = 2    !number of input files, 1: timeseries x, 2: timeseries y
     integer,parameter :: nspect = 4    !1.Autospectrum x
                                        !2.Autospectrum y
                                        !3.Cross-spectrum xy
                                        !4.Coherency spectrum xy
  end module const
!
! time series data
! ----------------
  module timeser
     implicit none
     public
     real, dimension(:), allocatable :: tx, x , ty, y
     integer :: npx, npy                        !number of data points
  end module timeser
!
! parameter
! ---------
  module param
     implicit none
     public
     integer, parameter :: ntry=3     ! user input: maximum number of errors
     real :: ofac
     real :: hifac = 1.0
     real,dimension(2) :: rhopre = -99.0        !1.rhopre x , 2. rhopre y
     integer :: nsim, n50, iwin
     logical :: mctest = .false.
     logical::mctest_phi=.false.
     real :: alpha
     logical:: x_sign = .false.
     logical:: y_sign = .false.
  end module param
!
! trigonometric data for FT
! -------------------------
  module trigwindat
     implicit none
     public
     real, dimension(:,:,:), allocatable :: txcos, txsin, tycos, tysin
     real, dimension(:,:), allocatable :: wxtau, wytau, wwx, wwy
  end module trigwindat
!
! error handling
! --------------
  module error
     implicit none
     public
     integer :: ierr = 0                ! error flag; 1=error in gettau; 2=warning in gettau
     integer, parameter :: errio = 99   ! i/o unit for log file
     logical :: errflagx = .false.      ! flags existence of duplicate times in input
     logical :: errflagy = .false.      ! flags existence of duplicate times in input
  end module error
!
! nyquist frequency variables
! ---------------------------
  module nyquist
     implicit none
     public
     integer :: nsegx, nsegy            ! data points per segment x and y
     real :: dfxy                       ! max frequency spacing, max(dfx,dfy)
     real :: avgdtxy                    ! max average sampling interval, max(avgdtx,avgdty)
     real :: fnyq                       ! average Nyquist frequency
     real :: wz                         ! omega = 2*pi*f
     integer :: nfreq                   ! f(1) = f(0) ; f(nfreq) = fNyq  (number of frequencies
     integer :: lfreq                   ! nfreq * 2
  end module nyquist
!
!Monte Carlo phase confidence interval variables
!--------------------------------
 module phase
    implicit none
    public
    real :: csig_mc
    real :: g
    integer :: i_boot
    real,dimension (:), allocatable :: redxb, redyb
    real, dimension(:), allocatable :: gbxx, gbyy, gbxy
    real, dimension(:,:), allocatable :: cbxy, phbxy
    integer :: idxph_low, idxph_up
    real, dimension(:,:,:), allocatable :: ephi_b
    real, dimension(:,:), allocatable :: ephi_mc
    real :: ave_phbxy, var_phbxy
    real, dimension(:,:,:), allocatable :: se_phbxy
    real, dimension(:,:), allocatable :: se_mc_phxy
    integer:: np_xy
    integer:: sg
    real, dimension(:), allocatable :: t_xy
    real :: tau_xy
  end module phase
!
!--------------------------------------------------------------------------
!                 E N D   M O D U L E   D E F I N I T O N S
!--------------------------------------------------------------------------
!
  ! program redfit
  SUBROUTINE run_redfit_x(cfgfile)
  USE, INTRINSIC :: ISO_C_BINDING
!
  use const
  use timeser
  use param
  use trigwindat
  use error
  use nyquist
  use phase
!
  implicit none
  !+ shenyulu 2025.1.9
  ! Declare input parameters (configuration file names from Python)
  CHARACTER(KIND=C_CHAR), DIMENSION(80), INTENT(IN) :: cfgfile
  CHARACTER(LEN=80) :: cfgfile_fortran  ! Convert to a Fortran string
!
  real, dimension(:), allocatable :: &
                          freq, &       ! frequency vector
                          gxx, &        ! autospectrum of input data x
                          gyy, &        ! autospectrum of input data y
                          gxy, &        ! cross-spectrum
                          cxy, &        ! coherency spectrum
                          phxy,&        ! phase spectrum
                          gxxc, &       ! corrected autospectrum of input data x
                          gyyc, &       ! corrected autospectrum of input data y
                          grxxsum, &    ! sum of AR(1) spectra x
                          gryysum, &    ! sum of AR(1) spectra y
                          grxysum, &    ! sum of cross-spectrum bivariate AR(1)
                          grxxavg, &    ! average AR(1) spectrum x
                          gryyavg, &    ! average AR(1) spectrum y
                          grxyavg, &    ! average cross-spectrum bivariate AR(1)
                          gredthx, &    ! theoretical AR(1) spectrum x
                          gredthy, &    ! theoretical AR(1) spectrum y
                          corrx, &      ! correction factor x
                          corry                 ! correction factor y
  real, dimension(:,:), allocatable :: ci90, &          ! 90% false-alarm level from MC
                                       ci95, &          ! 95% false-alarm level from MC
                                       ci99             ! 99% false-alarm level from MC
  real, dimension(:,:),allocatable :: ephi              !confidence interval for phase angle
!
! AR1 - spectrum
  real, dimension(:,:), allocatable :: grxx             ! AR(1) spectra x
  real, dimension(:,:), allocatable :: gryy             ! AR(1) spectra y
  real, dimension(:,:), allocatable :: grxy             ! Cross-spectrum bivariate AR(1)
  real, dimension(:,:), allocatable :: crxy             ! Coherency spectrum bivariate AR(1)
  real, dimension(:,:), allocatable :: phrxy            ! Phase spectrum bivariate AR(1)
  real, dimension(:), allocatable :: redx               ! AR(1) time series - based on time series x
  real, dimension(:), allocatable :: redy               ! AR(1) time series - based on time series y
!
  real :: taux,tauy, rnsim, getchi2, fac90, fac95, fac99, dof, neff, &
             avgdtx, avgdty, facx, facy, facxy, rhox, rhoxsq, rhoy, rhoysq, varx, vary, &
             varrx, varry, winbw, alphacritx, alphacrity, faccritx, faccrity,varxy, varrxy, cobias, facphi, z, getz, csig, se_dummy
  integer:: kstart, kstop, krate, kmax, ntime
  integer :: i, i2, ncnt, iocheck, ialloc
  integer :: idx90, idx95, idx99
  logical :: ini, biascorr
  ! character (len = 80) :: cfgfile,fnout  !- shenyulu 2025.1.9
  character (len = 80) :: fnout  !+ shenyulu 2025.1.9
  character (len =80), dimension(n_fnin) :: fnin
!
  character(len = 80) ::  cmdlin            !+ shenyulu 2022.8.29
!
  namelist /cfg/ fnin, fnout, nsim, ofac, hifac, n50, iwin, mctest, alpha, rhopre,mctest_phi, x_sign, y_sign
!
  interface
     subroutine sort(arr)
     use nrtype
     implicit none
     real(sp), dimension(:), intent(inout) :: arr
     end subroutine sort
  end interface
!
  interface
     subroutine spectr(ini, tx, x, ty, y, ofac, hifac, n50, iwin, frq,  &
                        gxx, gyy, gxy, cxy, phxy)
     implicit none
     logical, intent(in) :: ini
     real, dimension(:), intent(in) :: tx, x, ty, y
     real, intent(in) :: ofac, hifac
     integer, intent(in) :: n50, iwin
     real, dimension(:), intent(out) :: frq, gxx, gyy, gxy, cxy, phxy
     end subroutine spectr
  end interface
!
  interface
     subroutine gettau(rhopre,tx,x,npx,tau)
     implicit none
     real, intent(in) :: rhopre
     real, dimension(:),intent(in) :: tx, x
     integer,intent(in) :: npx
     real, intent(out) :: tau
     end subroutine gettau
  end interface
!
  Interface
     subroutine getdof(iwin, n50, dof, neff)
     implicit none
     integer, intent(in) :: iwin, n50
     real, intent(out) :: dof,neff
     end subroutine getdof
  end interface
!
interface
     subroutine avevar(data,ave,var)
     use nrtype
     implicit none
     real(sp), dimension(:), intent(in) :: data
     real(sp), intent(out) :: ave, var
     end subroutine avevar
  end interface
!
  call system_clock(kstart, krate, kmax)
!
!
  !+ shenyulu 2025.1.9
  ! Converts a C string to a Fortran string
  cfgfile_fortran = ''
  DO i = 1, 80
    IF (cfgfile(i) == C_NULL_CHAR) EXIT
    cfgfile_fortran(i:i) = cfgfile(i)
  END DO
!
! open log file for error messages
! --------------------------------
  ! open(errio, file = "redfit-x.log", carriagecontrol = "FORTRAN") !- shenyulu 2025.1.9
  open(errio, file = "redfit-x.log")  !+ shenyulu 2025.1.9
!
! welcome message
!---------------------------------------- !- shenyulu 2022.8.29
        !write(*,*) " "
        !write(*,*) " "
        !write(*,*) "================================================"
        !write(*,*) " "
        !write(*,'(5x,a)') vers
        !write(*,*) " "
        !write(*,*) "================================================"
        !write(*,*) " "
!
! retrieve command line arguments
! -------------------------------
  !- shenyulu 2025.1.9

  !       call GET_COMMAND_ARGUMENT(1, cmdlin)       !+ shenyulu 2022.8.29

  ! do i= 1,ntry
  !       write(*,*) " "
  !       !write(*,*) "Enter name of the configuration file [path + filename]"    !- shenyulu 2022.8.29
  !       !read (5,'(a)') cfgfile                    !- shenyulu 2022.8.29
  !       cfgfile = cmdlin                           !+ shenyulu 2022.8.29
  !       open (10, file = cfgfile, form = 'formatted', status = 'old', &
  !               iostat = iocheck)
  !       if (iocheck .ne. 0 ) then
  !               write(*,*) "Error - Cant''t open config file - try again!"
  !       else
  !               exit
  !       end if
  ! end do
  ! if (i > ntry) then
  !          write(*,*) "REDFIT-X terminates."
  !          stop
  ! end if
  ! write (*,*)
  ! read(10, nml = cfg)
  ! close (10)
!
  !+ shenyulu 2025.1.9
  ! Read configuration file
  OPEN(10, FILE=cfgfile_fortran, FORM='FORMATTED', STATUS='OLD', IOSTAT=iocheck)
  IF (iocheck /= 0) THEN
    WRITE(errio, *) 'Error opening config file!'
    CLOSE(errio)
    RETURN
  END IF
  READ(10, NML=cfg)
  CLOSE(10)
!
! check if alpha is one of the predefined values; otherwise reset
! ---------------------------------------------------------------
  if (alpha >= 0.1) then
     alpha = 0.1
  else if (alpha <= 0.01) then
     alpha = 0.01
  else
     alpha =0.05
  end if
!
! workspace dimensions
! --------------------
!
  call setdim(fnin,maxdimx,maxdimy,nout)
!
! setup workspace for input data
! ------------------------------
  allocate(x(maxdimx), tx(maxdimx), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  allocate(y(maxdimy), ty(maxdimy), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
!
! retrieve time series data
! -------------------------
  call readdat(fnin)
!
! check input time axis
! ----------------------
  call check1()
!
! in case of duplicate entries reinitialize array dimensions
! and retrieve averaged time series
! ----------------------------------------------------------
  if (errflagx .eqv. .true.) then
     write(*,*) "Resetting dimensions after correcting for duplicate sampling times...x"
     deallocate(x, tx, stat = ialloc)
     if (ialloc .ne. 0) call allocerr("d")
     fnin(1) = "TimeSeriesx.avg"
     call setdim(fnin,maxdimx,maxdimy,nout)
     allocate(x(maxdimx), tx(maxdimx), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     call readdat(fnin)
  end if
!
! check input time axis
! -----------------------
  call check2()
!
! in case of duplicate entries reinitialize array dimensions
! and retrieve averaged time series
! ----------------------------------------------------------
  if (errflagy .eqv. .true.) then
     write(*,*) "Resetting dimensions after correcting for duplicate sampling times...y"
     deallocate(y, ty, stat = ialloc)
     if (ialloc .ne. 0) call allocerr("d")
     fnin(2) = "TimeSeriesy.avg"
     call setdim(fnin,maxdimx,maxdimy,nout)
     allocate(y(maxdimy), ty(maxdimy), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     call readdat(fnin)
  end if
!
! change sign of the data if that is requested
! --------------------------------------------
  if (x_sign.eqv..true.) then
     x(:) = -x(:)
  end if

  if (y_sign.eqv..true.) then
     y(:) = -y(:)
  end if

! allocate remaining workspace
! ----------------------------
  allocate(redx(maxdimx), redy(maxdimy), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
!
  allocate (freq(nout), gxx(nout), gyy(nout), gxy(nout), &
             cxy(nout), phxy(nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
!
  allocate (grxxsum(nout),gryysum(nout),grxysum(nout), &
            grxxavg(nout),gryyavg(nout),grxyavg(nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  !
  allocate (gredthx(nout), gredthy(nout), corrx(nout), corry(nout), &
            gxxc(nout), gyyc(nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
 !
  if (mctest .eqv. .true.) then
        allocate (ci90(nspect,nout), ci95(nspect,nout), &
                     ci99(nspect,nout), stat = ialloc)
                if (ialloc .ne. 0) call allocerr("a")
  end if
!
  allocate (ephi(2,nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
!
! average dt of entire time series
! --------------------------------
  avgdtx = sum(tx(2:npx)-tx(1:npx-1)) / real(npx-1)
  avgdty = sum(ty(2:npy)-ty(1:npy-1)) / real(npy-1)
!
! determine autospectrum,crossspectrum, coherency and phase spectrum of input data     !step 2
! ------------------------------------
  ini = .true.
!
  call spectr(ini, tx(1:npx), x(1:npx), ty(1:npy),y(1:npy), ofac, hifac, n50, iwin, &
              freq, gxx, gyy, gxy, cxy, phxy)
!
! estimate data variance from autospectrum
! ---------------------------------------------------
  varx = freq(2) * sum(gxx(1:nout))     ! NB: freq(2) = dfxy
  vary = freq(2) * sum(gyy(1:nout))     ! NB: freq(2) = dfxy
  varxy = freq(2) * sum(gxy(1:nout))
!
! estimate tau unless tau is prescribed; die gracefully in case of an error
! ----------------------------------------------------------------------------------
   call gettau(rhopre(1), tx(1:npx), x(1:npx), npx, taux)
   if (ierr .eq. 1) then
        write (errio,*) ' Error in GETTAU'
        close(errio)
        write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
        stop
   end if
   call gettau(rhopre(2), ty(1:npy), y(1:npy), npy, tauy)
   if (ierr .eq. 1) then
        write (errio,*) ' Error in GETTAU'
        close(errio)
        write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
        stop
   end if

   write(*,*)
   write(*,'(1x,A6,1x,F10.2)') 'taux =', taux
   write(*,'(1x,A6,1x,F10.2)') 'tauy =', tauy
   write(*,*)
!
! Generate NSim AR(1) Spectra
! ---------------------------------
!
  if (mctest .eqv. .true.) then
     allocate(grxx(nsim,nout),gryy(nsim,nout),grxy(nsim,nout), &
              crxy(nsim,nout),phrxy(nsim,nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  else
     allocate(grxx(1,nout),gryy(1,nout),grxy(1,nout),          &
              crxy(1,nout),phrxy(1,nout), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  end if
!
  call ranseed
!
  grxxsum(:) = 0.0
  gryysum(:) = 0.0
  grxysum(:) = 0.0
  grxxavg(:) = 0.0
  gryyavg(:) = 0.0
  grxyavg(:) = 0.0
!
  call getdof(iwin, n50, dof, neff)
!
  rnsim = real(nsim)
  do i = 1, nsim
     if ((mod(i,50) .eq. 0) .or. (i .eq. 1)) write(*,*) 'ISim =', i
!
!   setup AR(1) time series and estimate its spectrum
!   -------------------------------------------------
!
        call makear1(tx, npx, taux, redx)
        call makear1(ty, npy, tauy, redy)
 !
         ini = .false.
            if (mctest .eqv. .true.) then
               call spectr(ini, tx(1:npx), redx(1:npx), ty(1:npy), redy(1:npy),         &
                                ofac, hifac, n50, iwin, freq, grxx(i,:), gryy(i,:),             &
                                grxy(i,:), crxy(i,:), phrxy(i,:))
            else
               call spectr(ini, tx(1:npx), redx(1:npx), ty(1:npy), redy(1:npy),         &
                                ofac, hifac, n50, iwin, freq, grxx(1,:), gryy(1,:),             &
                                grxy(1,:), crxy(1,:), phrxy(1,:))
           end if
!
!    scale and sum red-noise spectra
!    -------------------------------
!
     if (mctest .eqv. .true.) then
        varrx = freq(2) * sum(grxx(i,1:nout))   ! NB: freq(2) = df
        facx = varx / varrx
        grxx(i,1:nout) = facx * grxx(i,1:nout)  !scale grxx such that the area under grxx is identical to the area under gxx
        grxxsum(1:nout) = grxxsum(1:nout) + grxx(i,1:nout)
!
        varry = freq(2) * sum(gryy(i,1:nout))   ! NB: freq(2) = df
        facy = vary / varry
        gryy(i,1:nout) = facy * gryy(i,1:nout)  !scale gryy such that the area under gryy is identical to the area under gyy
        gryysum(1:nout) = gryysum(1:nout) + gryy(i,1:nout)
!
        varrxy = freq(2) * sum(grxy(i,1:nout))  ! NB: freq(2) = df
        facxy = varxy / varrxy
        grxy(i,1:nout) = facxy * grxy(i,1:nout) !scale grxy such that the area under grxy is identical to the area under gxy
        grxysum(1:nout) = grxysum(1:nout) + grxy(i,1:nout)
     else
        varrx = freq(2) * sum(grxx(1,1:nout))   ! NB: freq(2) = df
        facx = varx / varrx
        grxxsum(1:nout) = grxxsum(1:nout) + facx * grxx(1,1:nout)
!
        varry = freq(2) * sum(gryy(1,1:nout))   ! NB: freq(2) = df
        facy = vary / varry
        gryysum(1:nout) = gryysum(1:nout) + facy * gryy(1,1:nout)
!
        varrxy = freq(2) * sum(grxy(i,1:nout))  ! NB: freq(2) = df
        facxy = varxy / varrxy
        grxysum(1:nout) = grxysum(1:nout) + facxy *grxy(1,1:nout)
     end if
  end do        !end of nsim loop
!
! determine average red-noise spectrum; scale average again to
! make sure that roundoff errors do not affect the scaling
! ------------------------------------------------------------
  grxxavg(1:nout) = grxxsum(1:nout) / rnsim
  varrx = freq(2) * sum(grxxavg(1:nout))
  facx = varx / varrx
  grxxavg(1:nout) = facx * grxxavg(1:nout)      !Average AR(1) spectrum x
!
  gryyavg(1:nout) = gryysum(1:nout) / rnsim
  varry = freq(2) * sum(gryyavg(1:nout))
  facy = vary / varry
  gryyavg(1:nout) = facy * gryyavg(1:nout)      !Average AR(1) spectrum y
!
  grxyavg(1:nout) = grxysum(1:nout) / rnsim     !Average Cross-spectrum bivariate AR(1)
  varrxy = freq(2) * sum(grxyavg(1:nout))
  facxy = varxy / varrxy
  grxyavg(1:nout) = facxy * grxyavg(1:nout)
!
! determine lag-1 autocorrelation coefficient
! -------------------------------------------
  rhox = exp (-avgdtx / taux)              ! avg. autocorrelation coefficient x
  rhoxsq = rhox * rhox
 !
  rhoy = exp (-avgdty / tauy)              ! avg. autocorrelation coefficient y
  rhoysq = rhoy * rhoy
!
! set theoretical spectrum (e.g., Mann and Lees, 1996, Eq. 4)
! make area equal to that of the input time series
! -----------------------------------------------------------
  fnyq = freq(nout)                   ! Nyquist freq.
!
! theoretical spectrum based on rho estimated from the time series x
! ------------------------------------------------------------------
  gredthx(1:nout) = (1.0-rhoxsq) / (1.0-2.0*rhox*cos(pi*freq(1:nout)/fnyq)+rhoxsq)
  varrx = freq(2) * sum(gredthx(1:nout))
  facx = varx / varrx
  gredthx(1:nout) = facx * gredthx(1:nout)
!
! theoretical spectrum based on rho estimated from the time series y
! ------------------------------------------------------------------
  gredthy(1:nout) = (1.0-rhoysq) / (1.0-2.0*rhoy*cos(pi*freq(1:nout)/fnyq)+rhoysq)
  varry = freq(2) * sum(gredthy(1:nout))
  facy = vary / varry                     !step 5: Select G0 (for eq 2)
  gredthy(1:nout) = facy * gredthy(1:nout)
!
! correction factor for the bias adjustment of the Lomb-Scargle spectrum
! ----------------------------------------------------------------------
  corrx(1:nout) = grxxavg(1:nout) / gredthx(1:nout)
  corry(1:nout) = gryyavg(1:nout) / gredthy(1:nout)

! correct for bias in autospectrum
! -------------------------------------
  gxxc(1:nout) = gxx(1:nout) / corrx(1:nout)
  gyyc(1:nout) = gyy(1:nout) / corry(1:nout)
!
! red-noise false-alarm levels from percentiles of MC simulation
! --------------------------------------------------------------
  if (mctest .eqv. .true.) then
     do i = 1, nout
        call sort(grxx(1:nsim, i))
     end do
!
     do i = 1, nout
        call sort(gryy(1:nsim, i))
     end do
!
     do i = 1, nout
        call sort(grxy(1:nsim, i))
     end do
!
     do i = 1, nout
        call sort(crxy(1:nsim, i))
     end do
!
!    set percentil indices
!    ---------------------
!
     idx90 = int(0.90 * rnsim)
     idx95 = int(0.95 * rnsim)
     idx99 = int(0.99 * rnsim)
!
! find frequency-dependent percentil and apply bias correction for autospectrum
! -----------------------------------------------------------------------------
! for gxx
     do i = 1, nout
        ci90(1,i) = grxx(idx90, i) / corrx(i)
        ci95(1,i) = grxx(idx95, i) / corrx(i)
        ci99(1,i) = grxx(idx99, i) / corrx(i)
     end do
!
! for gyy
     do i = 1, nout
        ci90(2,i) = gryy(idx90, i) / corry(i)
        ci95(2,i) = gryy(idx95, i) / corry(i)
        ci99(2,i) = gryy(idx99, i) / corry(i)
     end do
!
! for gxy       (not used)
     do i = 1, nout
        ci90(3,i) = grxy(idx90, i)
        ci95(3,i) = grxy(idx95, i)
        ci99(3,i) = grxy(idx99, i)
     end do
!
! for cxy
     do i = 1, nout
        ci90(4,i) = crxy(idx90, i)
        ci95(4,i) = crxy(idx95, i)
        ci99(4,i) = crxy(idx99, i)
     end do
  end if
!
! scaling factors for red noise from chi^2 distribution
! --------------------------------------------------------------
  call getdof(iwin, n50, dof, neff)
  write(*,*)
  write(*,'(1x,A5,4x,F10.2)') "dof =", dof
  write(*,'(1x,A6,3x,F10.2)') "neff =", neff
  write(*,'(1x,A7,2x,F10.2)') "alpha =", alpha
!
  fac90 = getchi2(dof, 0.10) / dof
  fac95 = getchi2(dof, 0.05) / dof
  fac99 = getchi2(dof, 0.01) / dof
  if (ierr .eq. 1) stop
!
! coherency - False alarm level (theoretical)
! -------------------------------------------
  if(n50 == 1.0) then
     csig = 0.0
  else
     csig = 1.0 - alpha**(1.0/(neff-1.0))
  end if
!
! coherency - mean Monte Carlo false alarm level
! ----------------------------------------------
  if (mctest .eqv. .true.) then
     if (alpha==0.1)then
        csig_mc = sum(ci90(4,:))/nout
     else if (alpha==0.05) then
        csig_mc = sum(ci95(4,:))/nout
     else if (alpha==0.01) then
        csig_mc = sum(ci99(4,:))/nout
     else
        csig_mc = 0.0
     end if
  else
     csig_mc =-999.0
  end if
!
  write(*,*)
  write(*,'(1x,A42,F5.2,A3,F10.2)') "Mean MC false alarm for coherency (alpha =",alpha,") =", csig_mc
  write(*,'(1x,A39,11x,F10.2)') "Theoretical false alarm for coherency =", csig
!
! bias correction coherency spectrum
! ----------------------------------
  biascorr = .true.
  if (biascorr .eqv. .true.) then
     do i = 1,nout
        if (cxy(i) < 1.0) then
           cobias = ((1-cxy(i)) *(1-cxy(i)) )/ neff
           cxy(i) = cxy(i) - cobias
        end if
        if (cxy(i)< 0) then
           cxy(i) = 0
        end if
     end do
   end if
!
! Phase Spectrum - Confidence intervals (theoretical)
! ---------------------------------------------------
   z = getz(alpha/2.0)
   facphi = z *1/sqrt(2*neff) * 180/pi
!
   do i= 1,nout
!  avoid overflow error if cxy = 1 or cxy = 0
      if (cxy(i) .lt. csig_mc) then
         ephi(1,i) = -999.0
         ephi(2,i) = -999.0
      else if (cxy(i).ge. csig_mc) then
         if (cxy(i)>0.0 .and. cxy(i)<1.0) then
            ephi(1,i) = sqrt(1-cxy(i))/ sqrt(cxy(i)) * facphi
            ephi(2,i) = ephi(1,i)
            ephi(1,i) = phxy(i)+ephi(1,i)
            ephi(2,i) = phxy(i)-ephi(2,i)
         else if (cxy(i)==1.0 )then
            ephi(1,i) = 0.0
            ephi(2,i) = 0.0
         else if (cxy(i) == 0.0) then
            ephi(1,i) = phxy(i) + 180.0
            ephi(2,i) = 180.0 - phxy(i)
         end if
     end if
  end do
!
! Phase Spectrum - Monte Carlo confidence interval
! ------------------------------------------------
  if ((mctest_phi .eqv. .true.) .and. (mctest.eqv. .true.)) then
        allocate (gbxx(nout), gbyy(nout), gbxy(nout), stat = ialloc)
                if (ialloc .ne. 0) call allocerr("a")
        allocate (cbxy(nsim, nout),phbxy(nsim, nout), stat = ialloc)
                if (ialloc .ne. 0) call allocerr("a")
        allocate (ephi_b(2, nout, 2), stat = ialloc)            ! 1:lowver boundary, 2:upper boundary , 1:time-scale x 2:time-scale y
                if (ialloc .ne. 0) call allocerr("a")
        allocate (se_phbxy(2,nout,2), stat = ialloc)            !  1:lowver boundary, 2:upper boundary , 1: time-scale x, 2: time-scale y
                if (ialloc .ne. 0) call allocerr("a")
        allocate (ephi_mc(2, nout), stat = ialloc)              ! Mean over the two time scales  1:lowver boundary, 2:upper boundary
                if (ialloc .ne. 0) call allocerr("a")
        allocate (se_mc_phxy(2, nout), stat = ialloc)           ! Mean over the two time scales  1:lowver boundary, 2:upper boundary
                if (ialloc .ne. 0) call allocerr("a")
  end if
!
  idxph_low = int((alpha/2)*nsim)
  idxph_up = int ((1.0-alpha/2)*nsim)
!
  if ((mctest_phi .eqv. .true.) .and. (mctest.eqv. .true.))then
     write(*,*)
     write(*,*) "Monte Carlo confidence interval for phase..."
     do sg = 1,2                !two loops. 1: time steps from time series x used. 2: time steps from time series y used
!
        if (sg==1) then
           np_xy = npx
        else if (sg==2) then
           np_xy = npy
        end if
!
        allocate(t_xy(np_xy),stat = ialloc)
                if (ialloc .ne. 0) call allocerr("a")

        if (sg==1) then
           t_xy(:) = tx(:)
           tau_xy = taux
        else if (sg ==2) then
           t_xy(:) = ty(:)
           tau_xy = tauy
        end if
!
        nsegx = int(2 * np_xy / (n50 + 1))
        nsegy = int(2 * np_xy / (n50 + 1))
!
        allocate (redxb(np_xy), redyb(np_xy), stat = ialloc)
                if (ialloc .ne. 0) call allocerr("a")
!
        do i = 1,nout
           if (cxy(i) .ge.csig_mc) then                                                                         !Confidence interval is only formed at frequencies where the coherency is  significant
             g = sqrt(((-2.0 *sqrt(1.0-cxy(i)))/cxy(i))+(2.0/cxy(i))-(1.0))             ! g value - used to generate two time series with known coherency. cxy(i) has been bias corrected.
!
             deallocate (txsin, txcos,tysin, tycos, wxtau, wytau, wwx, wwy,  stat = ialloc)
             if (ialloc .ne. 0) call allocerr("d")
!
             do i_boot = 1,nsim
                call make_coherar1(redxb,redyb) ! 2 red noise time series with known coherency are generated
                if (i_boot==1) then
                   ini = .true.
                else
                   ini = .false.
                end if
                call spectr(ini, t_xy(1:np_xy), redxb(1:np_xy), t_xy(1:np_xy), redyb(1:np_xy),          &
                     ofac, hifac, n50, iwin, freq, gbxx, gbyy,          &
                     gbxy, cbxy(i_boot,:), phbxy(i_boot,:))
             end do
             write(*,'(1x,a6,1x,i4,5x,a9,1x,i3)') "freq =" ,i, "time-sc =", sg
!
             call avevar(phbxy(1:nsim,i),ave_phbxy,var_phbxy)
             se_dummy = 0.0
             se_dummy = sqrt(var_phbxy)
             z = getz(alpha/2.0)
             se_phbxy(1,i,sg) = phxy(i) + z * se_dummy          ! Standard error based CI. Lower boundary  standard error *z(alpha).
             se_phbxy(2,i,sg) = phxy(i) -  z * se_dummy         ! Standard error bassed CI. Upper boundary

             call sort(phbxy(1:nsim,i))                         ! for percentile based CI
             phbxy(:,i) = phbxy(:,i) - ave_phbxy                !The mean phase value from the Monte Carlo ensemble subtracted from the phase values to center the values around zero
             ephi_b(1,i,sg) = phxy(i) + phbxy(idxph_low,i)      !The estimated phase value from the observed series added to the upper and  lower boundary to form the confidence interval
             ephi_b(2,i,sg) = phxy(i) + phbxy(idxph_up, i)
          else if (cxy(i).lt. csig_mc) then
                   ephi_b(1,i,sg) = -999.0
                   ephi_b(2,i,sg) = -999.0
                   se_phbxy(1,i,sg) = -999.0
                   se_phbxy(2,i,sg) = -999.0
          end if
        end do
!
        deallocate (t_xy, redyb, redxb,  stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
!
     end do
!
!    Form the final Monte Carlo confidence interval by taking the mean value for both time scalces
!    ---------------------------------------------------------------------------------------------
     do i = 1,nout
        ephi_mc(1,i)=  (ephi_b(1,i,1)+ephi_b(1,i,2))/2
        ephi_mc(2,i)=  (ephi_b(2,i,1) + ephi_b(2,i,2))/2
        se_mc_phxy(1,i) = (se_phbxy(1,i,1) + se_phbxy(1,i,2))/2         !not printed in result file
        se_mc_phxy(2,i) = (se_phbxy(2,i,1) + se_phbxy(2,i,2))/2         !not printed in result file
     end do
  end if
!
  nsegx = int(2 * npx / (n50 + 1))              ! nsegx and nsegy set to previous values
  nsegy= int(2 * npy / (n50 + 1))
!
! critical false alarm level after Thomson (1990)
! -----------------------------------------------
! for autospectrum xx
  alphacritx = 1.0 / real(nsegx)
  faccritx = getchi2(dof, alphacritx) / dof
  if (ierr .eq. 1) stop
!
! for autospectrum yy
  alphacrity = 1.0 / real(nsegy)
  faccrity = getchi2(dof, alphacrity) / dof
  if (ierr .eq. 1) stop
!
! save results of AR(1) fit
! -------------------------
  call system_clock(kstop, krate, kmax)
  if (kstop .ge. kstart) then
     ntime = (kstop-kstart) / krate
  else ! kmax overflow
     ntime = ((kmax-kstart)+kstop) / krate
  end if

! Write result file - Autospectrum X
! ----------------------------------------
  open (20, file = trim(fnout)//'.gxx', form = "formatted", iostat = iocheck, &
       carriagecontrol = "FORTRAN")
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers, '    Autospectrum X'
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin(1))
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', Nsim
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# Data variance (from data spectrum) = ', varx
  write (20,*) '# Avg. dtx = ', avgdtx
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre(1) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rho = ', rhox
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(1)
  end if
  write (20,*) '# Avg. tau = ', taux
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '# Critical false-alarm level (Thomson, 1990) = ', &
                   (1.0-alphacritx) * 100.0
  write (20,*) '#    ==> corresponding scaling factor for red noise = ', faccritx
  write (20,*) '#'
  write (20,*) '#'
  write (20,*) '# Elapsed time [s] = ', ntime
  write (20,*) '#'
  write (20,*) '# Data Columns:'
  write (20,*) '# -------------'
  write (20,*) '#  1: Freq = frequency'
  write (20,*) '#  2: Gxx = spectrum of input data'
  write (20,*) '#  3: Gxx_corr = bias-corrected spectrum of input data'
  write (20,*) '#  4: Gred_th = theoretical AR(1) spectrum'
  write (20,*) '#  5: <Gred> = average spectrum of Nsim AR(1) time series (uncorrected)'
  write (20,*) '#  6: CorrFac = Gxx / Gxx_corr'
  write (20,*) '#  7: 90%-Chi2 = 90-% false-alarm level (Chi^2)'
  write (20,*) '#  8: 95%-Chi2 = 95-% false-alarm level (Chi^2)'
  write (20,*) '#  9: 99%-Chi2 = 99-% false-alarm level (Chi^2)'
  if (mctest .eqv. .true.) then
     write (20,*) '# 10: 90%-MC = 90-% false-alarm level (MC)'
     write (20,*) '# 11: 95%-MC = 95-% false-alarm level (MC)'
     write (20,*) '# 12: 99%-MC = 99-% false-alarm level (MC)'
     write (20,*) '#'
      write(20,'("#  ""Freq""",9x,"""Gxx""",7x,"""Gxx_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",5x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""",5x,"""90%-MC""",6x,"""95%-MC""",6x,"""99%-MC""" )')
     do i = 1, nout
        write (20,'(1x,13(e12.6,2x))') freq(i), gxx(i),gxxc(i), gredthx(i), &
                   grxxavg(i), corrx(i), gredthx(i)*fac90, &
                   gredthx(i)*fac95, gredthx(i)*fac99, ci90(1,i), &
                   ci95(1,i), ci99(1,i)
     end do
  else
     write (20,*) '#'
      write(20,'("#  ""Freq""",9x,"""Gxx""",7x,"""Gxx_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",4x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""")')
     do i = 1, nout
        write (20,'(1x,9(e12.6,2x))') freq(i), gxx(i),gxxc(i), gredthx(i), &
                   grxxavg(i), corrx(i), gredthx(i)*fac90, &
                   gredthx(i)*fac95, gredthx(i)*fac99
     end do
  end if
  close(20)
  
!---------------------------
! ! Binary file output (gxx)
! ! + shenyulu 2022.9.1
!---------------------------

    open(50, file = "tmp_real_gxx.output", form = "unformatted", access = "stream")
    if (rhopre(1) .lt. 0.0) then
        write(50) ofac, hifac, varx, avgdtx, &
                  rhox, rhopre(1), &
                  taux, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacritx) * 100.0, faccritx
    else
        write(50) ofac, hifac, varx, avgdtx, &
                  rhox, rhopre(1), &
                  taux, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacritx) * 100.0, faccritx
    end if
    close(50)
    
    open(50, file = "tmp_int_gxx.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              ntime, nout
    close(50)
    
    if (mctest .eqv. .true.) then
        open(50, file = "tmp_array_gxx.output", form = "unformatted", access = "stream")
        write(50) freq, gxx,gxxc, gredthx, grxxavg, corrx, gredthx*fac90, gredthx*fac95, gredthx*fac99, ci90(1,:), ci95(1,:), ci99(1,:)
        close(50)
    else
        open(50, file = "tmp_array_gxx.output", form = "unformatted", access = "stream")
        write(50) freq, gxx,gxxc, gredthx, grxxavg, corrx, gredthx*fac90, gredthx*fac95, gredthx*fac99
        close(50)
    end if

!
! Write result file - Autospectrum Y
! ----------------------------------------
  open (20, file = trim(fnout)//'.gyy', form = "formatted", iostat = iocheck, &
       carriagecontrol = "FORTRAN")
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers, '    Autospectrum Y'
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin(2))
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', Nsim
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# Data variance (from data spectrum) = ', vary
  write (20,*) '# Avg. dtx = ', avgdty
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre(2) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rho = ', rhoy
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(2)
  end if
  write (20,*) '# Avg. tau = ', tauy
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '# Critical false-alarm level (Thomson, 1990) = ', &
                   (1.0-alphacrity) * 100.0
  write (20,*) '#    ==> corresponding scaling factor for red noise = ', faccrity
  write (20,*) '#'
  write (20,*) '#'
  write (20,*) '# Elapsed time [s] = ', ntime
  write (20,*) '#'
  write (20,*) '# Data Columns:'
  write (20,*) '# -------------'
  write (20,*) '#  1: Freq = frequency'
  write (20,*) '#  2: Gyy = spectrum of input data'
  write (20,*) '#  3: Gyy_corr = bias-corrected spectrum of input data'
  write (20,*) '#  4: Gred_th = theoretical AR(1) spectrum'
  write (20,*) '#  5: <Gred> = average spectrum of Nsim AR(1) time series (uncorrected)'
  write (20,*) '#  6: CorrFac = Gyy / Gyy_corr'
  write (20,*) '#  7: 90%-Chi2 = 90-% false-alarm level (Chi^2)'
  write (20,*) '#  8: 95%-Chi2 = 95-% false-alarm level (Chi^2)'
  write (20,*) '#  9: 99%-Chi2 = 99-% false-alarm level (Chi^2)'
  if (mctest .eqv. .true.) then
     write (20,*) '# 10: 90%-MC = 90-% false-alarm level (MC)'
     write (20,*) '# 11: 95%-MC = 95-% false-alarm level (MC)'
     write (20,*) '# 12: 99%-MC = 99-% false-alarm level (MC)'
     write (20,*) '#'
      write(20,'("#  ""Freq""",9x,"""Gyy""",7x,"""Gyy_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",5x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""",5x,"""90%-MC""",6x,"""95%-MC""",6x,"""99%-MC""" )')
     do i = 1, nout
        write (20,'(1x,12(e12.6,2x))') freq(i), gyy(i),gyyc(i), gredthy(i), &
                   gryyavg(i), corry(i), gredthy(i)*fac90, &
                   gredthy(i)*fac95, gredthy(i)*fac99, ci90(2,i), &
                   ci95(2,i), ci99(2,i)
     end do
  else
     write (20,*) '#'
      write(20,'("#  ""Freq""",9x,"""Gyy""",7x,"""Gyy_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",4x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""")')
     do i = 1, nout
        write (20,'(1x,9(e12.6,2x))') freq(i), gyy(i),gyyc(i), gredthy(i), &
                   gryyavg(i), corry(i), gredthy(i)*fac90, &
                   gredthy(i)*fac95, gredthy(i)*fac99
     end do
  end if
  close(20)

!---------------------------
! ! Binary file output (gyy)
! ! + shenyulu 2022.9.1
!---------------------------

    open(50, file = "tmp_real_gyy.output", form = "unformatted", access = "stream")
    if (rhopre(2) .lt. 0.0) then
        write(50) ofac, hifac, vary, avgdty, &
                  rhoy, rhopre(2), &
                  tauy, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacrity) * 100.0, faccrity
    else
        write(50) ofac, hifac, vary, avgdty, &
                  rhoy, rhopre(2), &
                  tauy, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacrity) * 100.0, faccrity
    end if
    close(50)
    
    open(50, file = "tmp_int_gyy.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              ntime, nout
    close(50)
    
    if (mctest .eqv. .true.) then
        open(50, file = "tmp_array_gyy.output", form = "unformatted", access = "stream")
        write(50) freq, gyy, gyyc, gredthy, &
                  gryyavg, corry, gredthy*fac90, &
                  gredthy*fac95, gredthy*fac99, ci90(2,:), &
                  ci95(2,:), ci99(2,:)
        close(50)
    else
        open(50, file = "tmp_array_gyy.output", form = "unformatted", access = "stream")
        write(50) freq, gyy,gyyc, gredthy, &
                  gryyavg, corry, gredthy*fac90, &
                  gredthy*fac95, gredthy*fac99
        close(50)
    end if


!
! Write result file - Cross-spectrum XY
! -------------------------------------------
  open (20, file = trim(fnout)//'.gxy', form = "formatted", iostat = iocheck, &
       carriagecontrol = "FORTRAN")
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers, '    Cross-spectrum XY'
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin(1))
  write (20,*) '# File = ', trim(fnin(2))
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', Nsim
  write (20,'(a22,f6.3)') '# Level of signif. = ', alpha
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# Avg. dtxy = ', avgdty
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre(1) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhox = ', rhox
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(1)
  end if
  if (rhopre(2) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhoy = ', rhoy
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(2)
  end if
  write (20,*) '# Avg. taux = ', taux
  write (20,*) '# Avg. tauy = ', tauy
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '#'
  write (20,*) '# Elapsed time [s] = ', ntime
  write (20,*) '#'
  write (20,*) '# Data Columns:'
  write (20,*) '# -------------'
  write (20,*) '#  1: Freq = frequency'
  write (20,*) '#  2: Gxy = cross-spectrum of input data'
  write (20,*) '#'
  write(20,'("#  ""Freq""",9x,"""Gxy""" )')
     do i = 1, nout
        write (20,'(1x,3(e12.6,2x))') freq(i), gxy(i)
     end do
  close(20)


!---------------------------
! ! Binary file output (gxy)
! ! + shenyulu 2022.9.1
!---------------------------

    open(50, file = "tmp_real_gxy.output", form = "unformatted", access = "stream") 
    write(50) ofac, hifac, alpha, avgdty, &
              rhox, rhopre(1), rhoy, rhopre(2), &
              taux, tauy, dof, winbw(iwin, freq(2)-freq(1), ofac)    
    close(50)
    
    open(50, file = "tmp_int_gxy.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              ntime, nout
    close(50)
    

    open(50, file = "tmp_array_gxy.output", form = "unformatted", access = "stream")
    write(50) freq, gxy
    close(50)

  
!
! Write result file - Coherency spectrum XY
! -------------------------------------------------
  open (20, file = trim(fnout)//'.cxy', form = "formatted", iostat = iocheck, &
       carriagecontrol = "FORTRAN")
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers, '    Coherency-spectrum XY'
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin(1))
  write (20,*) '# File = ', trim(fnin(2))
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', Nsim
  write (20,'(a22,f6.3)') '# Level of signif. = ', alpha
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# Avg. dtxy = ', avgdty
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre(1) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhox = ', rhox
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(1)
  end if
  if (rhopre(2) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhoy = ', rhoy
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(2)
  end if
  write (20,*) '# Avg. taux = ', taux
  write (20,*) '# Avg. tauy = ', tauy
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '#'
  write (20,*) '# Elapsed time [s] = ', ntime
  write (20,*) '#'
  write (20,*) '# Data Columns:'
  write (20,*) '# -------------'
  write (20,*) '#  1: Freq = Frequency'
  write (20,*) '#  2: Cxy = Coherency-spectrum of input data'
  write (20,*) '#  3: Csig = Theoretical False alarm level'
  if (mctest .eqv. .true.) then
     write (20,fmt='(a64,f6.3,a)') '#  4: MC-CSig = Mean Monte Carlo false-alarm level (for alpha =',alpha,')'
     write (20,*) '#  5: 90%-MC = 90% Monte Carlo false-alarm level'
     write (20,*) '#  6: 95%-MC = 95% Monte Carlo false-alarm level'
     write (20,*) '#  7: 99%-MC = 99% Monte Carlo false-alarm level'
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Cxy""",9x,"""Csig""",7x,&
  &              """MC-Csig""",6x,"""90%-MC""",6x,"""95%-MC""",4x,"""99%-MC""" )')
     do i = 1, nout
        write (20,'(1x,7(f12.6,2x))') freq(i), cxy(i), csig, &
                   csig_mc, ci90(4,i), ci95(4,i), ci99(4,i)
     end do
  else
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Cxy""", 9x,"""Csig""" )')
     do i = 1, nout
        write (20,'(1x,3(f12.6,2x))') freq(i), cxy(i), csig
     end do
  end if
  close(20)
  
!---------------------------
! ! Binary file output (cxy)
! ! + shenyulu 2022.9.1
!---------------------------

    open(50, file = "tmp_real_cxy.output", form = "unformatted", access = "stream")
    
    write(50) ofac, hifac, alpha, avgdty, &
                    rhox, rhopre(1), rhoy, rhopre(2), &
                    taux, tauy, dof, winbw(iwin, freq(2)-freq(1), ofac), csig, csig_mc   
    close(50)
    
    open(50, file = "tmp_int_cxy.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              ntime, nout
    close(50)
    

    open(50, file = "tmp_array_cxy.output", form = "unformatted", access = "stream")
    if (mctest .eqv. .true.) then
        write(50) freq, cxy, ci90(4,:), ci95(4,:), ci99(4,:)
    else
        write(50) freq, cxy
    end if
    close(50)  
  
!
!
! Write result file - Phase spectrum XY
! --------------------------------------------
  open (20, file = trim(fnout)//'.phxy', form = "formatted", iostat = iocheck, &
       carriagecontrol = "FORTRAN")
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers, '    Phase spectrum XY'
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin(1))
  write (20,*) '# File = ', trim(fnin(2))
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', nsim
  write (20,'(a22,f6.3)') '# Level of signif. = ', alpha
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# Avg. dtxy = ', avgdty
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre(1) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhox = ', rhox
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(1)
  end if
  if (rhopre(2) .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rhoy = ', rhoy
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre(2)
  end if
  write (20,*) '# Avg. taux = ', taux
  write (20,*) '# Avg. tauy = ', tauy
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '#'
  write (20,*) '# Elapsed time [s] = ', ntime
  write (20,*) '#'
  write (20,*) '# Data Columns:'
  write (20,*) '# -------------'
  write (20,*) '#  1: Freq = Frequency'
  write (20,*) '#  2: Phxy = Phase-spectrum of input data'
  write (20,*) '#  3: CI-low = Theoretical Confidence Interval - lower'
  write (20,*) '#  4: CI-up =  Theoretical Confidence Interval - upper'
  if ((mctest_phi.eqv..true.).and.(mctest.eqv..true.))then
     write (20,*) '#  5: CI-mc-low = Monte Carlo Confidence Interval - lower   (percentiles)'
     write (20,*) '#  6: CI-mc-up =  Monte Carlo Confidence Interval - upper   (percentiles)'
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Phxy""",6x,"""CI-low""",7x, """CI-up""",6x,"""CI-mc-low""",4x,&
                 &    """CI-mc-up""")')
     do i = 1, nout
        write (20,'(1x,6(f12.6,2x))') freq(i), phxy(i), ephi(1,i),ephi(2,i), &
                    ephi_mc(1,i), ephi_mc(2,i)
     end do
  else
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Phxy""",6x,"""CI-low""",6x, """CI-up""")')
     do i = 1, nout
        write (20,'(1x,4(f12.6,2x))') freq(i), phxy(i), ephi(1,i),ephi(2,i)
     end do
  end if
  close(20)

!---------------------------
! ! Binary file output (phxy)
! ! + shenyulu 2022.9.1
!---------------------------

    open(50, file = "tmp_real_phxy.output", form = "unformatted", access = "stream") 
    write(50) ofac, hifac, alpha, avgdty, &
              rhox, rhopre(1), rhoy, rhopre(2), &
              taux, tauy, dof, winbw(iwin, freq(2)-freq(1), ofac)
    close(50)
    
    open(50, file = "tmp_int_phxy.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              ntime, nout
    close(50)
    

    open(50, file = "tmp_array_phxy.output", form = "unformatted", access = "stream")
    if ((mctest_phi.eqv..true.).and.(mctest.eqv..true.))then
        write(50) freq, phxy, ephi(1,:),ephi(2,:), ephi_mc(1,:), ephi_mc(2,:)
    else
        write(50) freq, phxy, ephi(1,:),ephi(2,:)
    end if
    close(50)  
    
  
!
! clean up
! --------
  if (ierr .eq. 0) then
     close(errio, status = "delete")
  else
     close(errio, status = "keep")
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
  end if
  deallocate(x, tx, redx, y, ty, redy, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  deallocate (freq, gxx, gyy, gxy, cxy, phxy, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  deallocate(grxx, gryy, grxy, crxy, phrxy, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  deallocate(grxxsum, gryysum, grxysum,                 &
             grxxavg, gryyavg, grxyavg, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  deallocate (gredthx, gredthy, corrx , corry,          &
               gxxc, gyyc, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  if (mctest .eqv. .true.) then
     deallocate (ci90, ci95, ci99, stat = ialloc)
        if (ialloc .ne. 0) call allocerr("d")
  end if
  if ((mctest_phi.eqv..true.).and. (mctest.eqv..true.))then
     deallocate (gbxx,gbyy,gbxy,cbxy,phbxy,ephi_b,se_phbxy, ephi_mc, se_mc_phxy,  stat = ialloc)
     if (ialloc .ne. 0) call allocerr("d")
  end if
! !+ shenyulu 2025.1.9
  deallocate(ephi, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
!!+ shenyulu 2025.1.9
  if (allocated(txcos)) deallocate(txcos, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(tycos)) deallocate(tycos, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(txsin)) deallocate(txsin, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(tysin)) deallocate(tysin, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(wxtau)) deallocate(wxtau, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(wytau)) deallocate(wytau, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(wwx)) deallocate(wwx, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (allocated(wwy)) deallocate(wwy, stat=ialloc)
  if (ialloc .ne. 0) call allocerr("d")

  end
!
!--------------------------------------------------------------------------
  subroutine allocerr(ichar)
!--------------------------------------------------------------------------
! Report errors during allocation or deallocation to errio and terminate
! program.
!
! ichar = a : Allocation Error
! ichar = d : Deallocation Error
!--------------------------------------------------------------------------
  use error
!
  implicit none
!
  character(len=1), intent(in)  :: ichar
!
  if (ichar .eq. "a") then
     write (errio, '(1x,a)') 'Error - Insufficient RAM; memory allocation failed!'
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
  if (ichar .eq. "d") then
     write (errio, '(1x,a)') 'Error - memory deallocation failed!'
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT-X.LOG for further information."
     stop
  end if
!
  end subroutine allocerr
!
!--------------------------------------------------------------------------
  subroutine setdim(fnin,maxdimx,maxdimy,nout)
!--------------------------------------------------------------------------
! Analyze data file and set array dimensions.
!--------------------------------------------------------------------------
  use timeser
  use param
  use error
  use nyquist
  use const, only : n_fnin, pi
!
  implicit none
!
  character (len = 80), dimension (n_fnin), intent(in) :: fnin
  integer, intent(out) :: maxdimx,maxdimy,nout
!
  real :: tdum, xdum, t1
  real :: avgdtx, avgdty                !average sampling interval for x and y
  real :: tpx, tpy                      !average period of segment x and y
  real :: dfx, dfy                      !frequency spacing for x and y
  integer :: i, iocheck, j
  character (len = 1) :: flag
  integer :: n

! j loop - opens both inputfiles x and y and sets number of data points npx and npy
! --------------------------------------------------------------------------------
  do j = 1,n_fnin
!
!   open input file
!   ---------------
     open (10, file = fnin(j), form = 'formatted', status = 'old', &
          iostat = iocheck)
     if (iocheck .ne. 0 ) then
        write (errio, *) ' Error - Can''t open ', trim(fnin(j))
        close(errio)
        stop
     end if
!
!    skip header
!    -----------
     do while (.true.)
        read (10, '(a1)') flag
        if (flag .ne. '#') then
           backspace (10)
           exit
        end if
     end do
!
!    count data
!    ----------
     i = 1
     do while (.true.)
        read (10, *, iostat = iocheck) tdum, xdum
        if (i .eq. 1) t1 = tdum         ! save initial time
        if (iocheck .ne. 0) exit
        i = i + 1
     end do
     close(10)
!
!    number of input data
!    --------------------
!
     if (j == 1) then
        npx = i - 1                                              !number of data points x
        avgdtx = (tdum - t1) / real(npx-1)                       ! avg. sampling interval for x
         print '(a,f11.3,a,f11.3,a,i8,a)', 'X time interval :   [ ',t1,'; ',tdum,' ]       - ',npx,' points'
     else if (j == 2) then
        npy = i -1                                               !number of data points y
        avgdty = (tdum - t1) / real(npy-1)                       ! avg. sampling interval for y
        print '(a,f11.3,a,f11.3,a,i8,a)', 'Y time interval :   [ ',t1,'; ',tdum,' ]       - ',npy,' points'
     end if
!
  end do   !(end of j - loop)
!
! set max. array dimension
! ------------------------
  maxdimx = npx
  maxdimy = npy
!
! number of output data (results saved in the module nyquist)
! ----------------------------------------------------------
  nsegx = int(2 * npx / (n50 + 1))              ! points per segment x
  nsegy = int(2 * npy / (n50 + 1))              ! points per segment  y
!
  if (avgdtx >= avgdty) then
     avgdtxy = avgdtx
  else
     avgdtxy = avgdty                                   ! eq 7 in the SPECTRUM paper;avgdtxy = max (avgdtx,avgdty)
  end if
  tpx = avgdtx * nsegx                                  ! average period of a segment x
  tpy = avgdty * nsegy                                  ! average period of a segment y
  dfx = 1.0 / (ofac * tpx)                              ! freq. spacing x       (fundamental freq)
  dfy = 1.0 / (ofac * tpy)                              ! freq. spacing y
  if ( dfx >= dfy) then
     dfxy = dfx                                         !eq 8 in SPECTRUM paper dfxy = max (dfx,dfy)
  else
     dfxy = dfy
  end if
  wz = 2.0 * pi * dfxy                          ! omega = 2*pi*f
  fnyq = hifac * 1.0 / (2.0 * avgdtxy)          ! average Nyquist freq.
  nfreq = fnyq / dfxy + 1                       ! f(1) = f0; f(nfreq) = fNyq
  lfreq = nfreq * 2
  nout = nfreq
!
! diagnostic output to stdout
! ---------------------------
  write(*,*)
  write(*,'(a,f10.2)') "dtxy =", avgdtxy
  write(*,'(a,i10)') "Nout =", nout
  write(*,'(a,f10.2)') "fnyq =", fnyq
  write(*,*)
!
  end subroutine setdim
!--------------------------------------------------------------------------
  subroutine readdat(fnin)
!--------------------------------------------------------------------------
  use timeser
  use error
  use const,only:n_fnin
!
  implicit none
!
  character (len = 80), dimension (n_fnin), intent(in) :: fnin
  integer :: i, iocheck, j
  character (len = 1) :: flag
!
  do j = 1,n_fnin               !Goes through inputfile x and y
!
!    open input file
!    ---------------
     open (10, file = fnin(j), form = 'formatted', status = 'old', &
          iostat = iocheck)
     if (iocheck .ne. 0 ) then
        write (errio, *) ' Error - Can''t open ', trim(fnin(j))
        close(errio)
        stop
     end if
!
!    skip header
!    -----------
     do while (.true.)
        read (10, '(a1)') flag
        if (flag .ne. '#') then
           backspace (10)
           exit
        end if
     end do
!
!    retrieve data
!    -------------
     if (j ==1 ) then
        do i = 1, npx
           read (10,*) tx(i), x(i)
        end do
        close(10)
      else if (j == 2) then
        do i = 1, npy
           read (10,*) ty(i), y(i)
        end do
        close(10)
      end if
!
   end do
!
  end subroutine readdat
!--------------------------------------------------------------------------
  subroutine check1()
!--------------------------------------------------------------------------
  use timeser
  use error
  implicit none
!
  real    :: ave
  integer :: i, j, idx, icnt
  logical :: err_order = .false.
  logical :: err_dupl = .false.
!
! check for descending time axis
! ------------------------------
  do i = 1, npx-1
     if (tx(i) .gt. tx(i+1)) then
        err_order = .true.
        write(errio,'(1x,a,1x,e12.6)') 'Descending time axis at t =', tx(i)
     end if
  end do
  if (err_order .eqv. .true.) stop
!
! check for duplicates time and replace values of time-dependent variable by their mean
! -------------------------------------------------------------------------------------
  idx = 1
  do while (.true.)
     if (tx(idx+1) .eq. tx(idx)) then
        err_dupl = .true.
        write(errio,'(1x,a,1x,e12.6,1x,a)') 'Duplicate time at t =', tx(idx), '...averaging data'
!
!       search for multiple occurrences
!       -------------------------------
        icnt = 0
        do i = 1, npx-idx
           if (tx(idx+i) .eq. tx(idx)) icnt = icnt + 1
        end do
!
!       replace first data by mean of duplicates points
!       -----------------------------------------------
        ave = sum(x(idx:idx+icnt)) / real(icnt+1)
        x(idx) = ave
!
!       shift remaining points
!       ----------------------
        do j = 1, icnt
           do i = idx+1, npx-1
                tx(i) = tx(i+1)
                x(i) = x(i+1)
           end do
           npx  = npx - 1
        end do
     end if
     idx = idx + 1
     if (idx .eq. npx-1) exit
  end do
!
! save averaged data set
! ----------------------
  if (err_dupl .eqv. .true.) then
     errflagx = .true.
     open(90, file = "TimeSeriesx.avg")
     do i = 1, npx
        write(90,*) tx(i), x(i)
     end do
     close(90)
  end if
!
  end subroutine check1
!--------------------------------------------------------------------------
  subroutine check2()
!--------------------------------------------------------------------------
  use timeser
  use error
  implicit none
!
  real    :: ave
  integer :: i, j, idx, icnt
  logical :: err_order = .false.
  logical :: err_dupl = .false.
!
! check for descending time axis
! ------------------------------
  do i = 1, npy-1
     if (ty(i) .gt. ty(i+1)) then
        err_order = .true.
        write(errio,'(1x,a,1x,e12.6)') 'Descending time axis at ty =', ty(i)
     end if
  end do
  if (err_order .eqv. .true.) stop
!
! check for duplicates time and replace values of time-dependent variable by their mean
! -------------------------------------------------------------------------------------
  idx = 1
  do while (.true.)
     if (ty(idx+1) .eq. ty(idx)) then
        err_dupl = .true.
        write(errio,'(1x,a,1x,e12.6,1x,a)') 'Duplicate time at ty =', ty(idx), '...averaging data'
!
!       search for multiple occurrences
!       -------------------------------
        icnt = 0
        do i = 1, npy-idx
           if (ty(idx+i) .eq. ty(idx)) icnt = icnt + 1
        end do
!
!       replace first data by mean of duplicates points
!       -----------------------------------------------
        ave = sum(y(idx:idx+icnt)) / real(icnt+1)
        y(idx) = ave
!
!       shift remaining points
!       ----------------------
        do j = 1, icnt
           do i = idx+1, npy-1
                ty(i) = ty(i+1)
                y(i) = y(i+1)
           end do
           npy  = npy - 1
        end do
     end if
     idx = idx + 1
     if (idx .eq. npy-1) exit
  end do
!
! save averaged data set
! ----------------------
  if (err_dupl .eqv. .true.) then
     errflagy = .true.
     open(90, file = "TimeSeriesy.avg")
     do i = 1, npy
        write(90,*) ty(i), y(i)
     end do
     close(90)
  end if
!
  end subroutine check2
!--------------------------------------------------------------------------
  subroutine spectr(ini, tx, x, ty, y, ofac, hifac, n50, iwin, frq, gxx, &
                    gyy, gxy, cxy, phxy)
!--------------------------------------------------------------------------
  use trigwindat
  use const
  use nyquist
!
  implicit none
!
  real, parameter :: si = 1.0
  real, parameter :: tzero = 0.0
!
  logical, intent(in) :: ini
  real, dimension(:), intent(in) :: tx, x, ty, y
  real, intent(in) :: ofac, hifac
  integer, intent(in) :: n50, iwin
  real, dimension(:), intent(out) :: frq, gxx, gyy, gxy, cxy, phxy
!
  real, dimension(:), allocatable :: txwk, xwk, ftrx, ftix, &
                                     tywk, ywk, ftry, ftiy
  integer :: i, j, istart, ialloc
  real ::  scalx,scaly,scalxy
  real :: rnx, rny
  complex,dimension(nout) :: cpxy
!
  interface
     subroutine winwgt(t, iwin, ww)
     implicit none
     real, intent(in), dimension(:) :: t
     real, intent(out), dimension(:) :: ww
     integer, intent(in) :: iwin
     end subroutine winwgt
  end interface
!
  interface
     subroutine ftfix(iseg, xx, tsamp, nn, tcos, tsin, wtau, wz, nfreq, &
                      si, lfreq, tzero, ftrx, ftix)
     implicit none
     real, dimension(:), intent(in) :: xx, tsamp
     real, dimension(:), intent(out) :: ftrx, ftix
     real, intent(in):: wz, si, tzero
     integer, intent(in) :: iseg, nn, nfreq, lfreq
     real, dimension(:,:,:), intent(in) :: tcos, tsin
     real, dimension(:,:), intent(in) :: wtau
     end subroutine ftfix
  end interface
!
 interface
     subroutine trig(iseg, tsamp, nn, wz, nfreq, tcos, tsin, wtau)
     implicit none
     real, dimension(*), intent(in) :: tsamp
     real, intent(in)    :: wz
     integer, intent(in) :: iseg, nn, nfreq
     real,dimension(:,:,:),intent(out):: tcos,tsin
     real,dimension(:,:),intent(out):: wtau
     end subroutine trig
  end interface
!
! setup workspace
! ---------------
  gxx(:) = 0.0
  gyy(:) = 0.0
  gxy(:) = 0.0
  cxy(:) = 0.0
  phxy(:)= 0.0
  cpxy(:)= 0.0
  allocate(txwk(nsegx), xwk(nsegx), tywk(nsegy), ywk(nsegy), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  allocate(ftrx(lfreq), ftix(lfreq), ftry(lfreq), ftiy(lfreq), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  if (ini .eqv. .true.) then
     allocate(txcos(nsegx,nfreq,n50),tycos(nsegy,nfreq,n50), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
     allocate(txsin(nsegx,nfreq,n50),tysin(nsegy,nfreq,n50), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
     allocate(wxtau(nfreq,n50),wytau(nfreq,n50), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
     allocate(wwx(nsegx,n50), wwy(nsegy,n50), stat = ialloc)
        if (ialloc .ne. 0) call allocerr("a")
  end if
!

  do i = 1, n50         ! start of the segment loop
!    copy data of i'th segment into workspace
!    ----------------------------------------
     istart = (i-1) * nsegx / 2
     do j = 1, nsegx
        txwk(j) = tx(istart + j)
        xwk(j) = x(istart + j)
     end do
!
     istart = (i-1) * nsegy / 2
     do j = 1, nsegy
        tywk(j) = ty(istart + j)
        ywk(j) = y(istart + j)
     end do
!
!    detrend data
!    ------------
     call rmtrend (txwk(1:nsegx), xwk(1:nsegx), nsegx)
     call rmtrend (tywk(1:nsegy), ywk(1:nsegy), nsegy)
!
!    apply window to data
!    --------------------
     if (ini .eqv. .true.) call winwgt(txwk(1:nsegx), iwin, wwx(1:nsegx, i))
     xwk(1:nsegx) = wwx(1:nsegx, i) * xwk(1:nsegx)
     if (ini .eqv. .true.) call winwgt(tywk(1:nsegy), iwin, wwy(1:nsegy, i))
     ywk(1:nsegy) = wwy(1:nsegy, i) * ywk(1:nsegy)
!
!    setup trigonometric array for LSFT
!    ----------------------------------
     if (ini .eqv. .true.) call trig(i, txwk(1:nsegx), nsegx, wz, nfreq, txcos,txsin, wxtau)
     if (ini .eqv. .true.) call trig(i, tywk(1:nsegy), nsegy, wz, nfreq, tycos,tysin, wytau)
!
!    LSFT
!    ------
     call ftfix(i, xwk(1:nsegx), txwk(1:nsegx), nsegx, txcos(1:nsegx,1:nfreq,1:n50), txsin(1:nsegx,1:nfreq,1:n50), &
                 wxtau(1:nfreq,1:n50), wz, nfreq, si, lfreq, tzero, ftrx, ftix)
!
    call ftfix(i, ywk(1:nsegy), tywk(1:nsegy), nsegy, tycos(1:nsegy,1:nfreq,1:n50) ,tysin(1:nsegy,1:nfreq,1:n50), &
                 wytau(1:nfreq,1:n50), wz, nfreq, si, lfreq, tzero, ftry, ftiy)
!
!    sum raw spectra
!    -------------------
     do j = 1, nout
        gxx(j) = gxx(j) + (ftrx(j)*ftrx(j) + ftix(j)*ftix(j))
        gyy(j) = gyy(j) + (ftry(j)*ftry(j) + ftiy(j)*ftiy(j))
     end do
!
!    cross and phase spectra
!     --------------------------
      do j = 1,nout
         cpxy(j) = cpxy(j) + cmplx(ftrx(j),ftix(j)) * cmplx(ftry(j),-ftiy(j))           !the minus obtains the complex conjugate
        phxy(j) = phxy(j) + atan2(aimag(cpxy(j)),real(cpxy(j))) * 180/pi                ! see how atan2 function works atan2(y,x) = atan(y/x)
      end do                                                                                                    ! which means atan(imag(cpxy)/real(cpxy))
!
  end do        ! end the segment loop
!
! scale autospectrum and setup frequency axis
! -------------------------------------------
! determine smoothed spectral estimate, i.e calc. average over k spectra and scale
! spectrum such that the intergral of the smoothed spectrum equals the data variance,
! that is a (Gxx(f)*df) = a^2 ; change sign of the phase because of the geological time
! axis is inverted compared to the physical axis of time
!
  scalx = 2.0 / (n50 * nsegx * dfxy * ofac)
  scaly = 2.0 / (n50 * nsegy * dfxy * ofac)
  rnx = nsegx                                   ! make the integer nsegx real number
  rny = nsegy
  scalxy = 2.0 / (n50 * sqrt(rnx * rny) * dfxy * ofac)
  do i = 1, nout
     gxx(i) = gxx(i) * scalx
     gyy(i) = gyy(i) * scaly
     gxy(i) = abs(cpxy(i)) * scalxy
     phxy(i) = phxy(i) / n50
     frq(i) = (i-1) * dfxy
  end do
!
! coherency spectrum
! ------------------
!  mask exeptions in order to avoid 'division by zero' and 'overflow' errors.
!  If only 1 segment was used then set cxy(f) = 1 -> faster
!
   if (n50 == 1) then
      cxy(:) = 1.0
   else
      do i=1,nout
         if(gxy(i)==0.0 .or. gxx(i)==0.0 .or. gyy(i)==0.0) then
            cxy(i) = 0.0
         else
            cxy(i)= (gxy(i) * gxy(i))/(gxx(i) * gyy(i))
         end if
      end do
   end if
!
  deallocate(txwk, xwk, tywk, ywk, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  deallocate(ftrx, ftix, ftry, ftiy, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
!
  end subroutine spectr
!
!--------------------------------------------------------------------------
  subroutine makear1(t, np, tau, red)
!--------------------------------------------------------------------------
  use const
!
  implicit none
!
  integer, intent(in)    :: np
  real, dimension(np), intent(in) :: t
  real, intent(in)       :: tau
  real, dimension(np), intent(out) :: red
!
  real :: sigma, dt
  integer :: i
  real ::  z1
!
! set up AR(1) time series
! ------------------------
  if (tau.eq.0.0) then
     do i = 1,np
        call gasdev(z1)
        red(i) = z1
     end do
   else
     call gasdev(z1)
     red(1)=z1
     do i = 2, np
        dt = t(i) - t(i-1)
        sigma = 1.0 - exp(-2.0 * dt / tau)
        sigma = sqrt (sigma)
        call gasdev(z1)
        red(i) = exp(-dt/tau) * red(i-1) + sigma * z1
     end do
  end if
!
  end subroutine makear1
!
!--------------------------------------------------------------------------
  subroutine make_coherar1(red1, red2)
!--------------------------------------------------------------------------
  use phase
!
  implicit none
!
! Generates two coupled time series with prescribed coherency
!
  real, dimension(np_xy), intent(out) :: red1
  real, dimension(np_xy), intent(out) :: red2
!
  real :: sigmax, sigmay, dtx, dty
  integer :: i, j
  real ::  z1, z2
  real, dimension(np_xy) :: ex, ex_y
  real, dimension(np_xy) :: ey, ey_x
!
! Set up noise x
! --------------
  do i = 1,np_xy
     call gasdev(z1)
     ex(i) = z1
  end do
!
! Set up noise y
! --------------
  do i = 1,np_xy
     call gasdev(z2)
     ey(i) = z2
  end do
!
! Couple the noise terms
! ----------------------
  ex_y(:) = ex(:) + g*ey(:)
  ey_x(:) = ey(:) + g*ex(:)
!
! Set up AR(1) series x
! ---------------------
  if (tau_xy .le.0.0) then
     red1(:) = ex_y(:)
  else
     red1(1) = ex_y(1)
     do j = 2,np_xy
        dtx = t_xy(j) - t_xy(j-1)
        sigmax = 1.0 - exp(-2.0 * dtx / tau_xy)
        sigmax = sqrt (sigmax)
        red1(j) = exp(-dtx/tau_xy) * red1(j-1) + sigmax * ex_y(j)
     end do
  end if
!
! Set up AR(1) series y
! ---------------------
  if (tau_xy .le.0.0) then
     red2(:) = ey_x(:)
  else
     red2(1) = ey_x(1)
     do j = 2,np_xy
        dty = t_xy(j) - t_xy(j-1)
        sigmay = 1.0 - exp(-2.0 * dty / tau_xy)
        sigmay = sqrt (sigmay)
        red2(j) = exp(-dty/tau_xy) * red2(j-1) + sigmay * ey_x(j)
     end do
  end if
!
  end subroutine make_coherar1
!
!---------------------------------------------------------------------------------------------------------------------------------------------------
  subroutine ftfix(iseg, xx, tsamp, nn, tcos, tsin, wtau, wz, nfreq, &
             si, lfreq, tzero, ftrx, ftix)
!------------------------------------------------------------------------
! Fourier transformation for unevenly spaced data
! (Scargle, 1989; ApJ 343, 874-887)
!
! - folding of trigonom. and exp. arguments in a*pi disabled
!------------------------------------------------------------------------
!
  implicit  none
!
  real, dimension(:), intent(in) :: xx, tsamp
  real, dimension(:), intent(out) :: ftrx, ftix
  real, intent(in)    :: wz, si, tzero
  integer, intent(in) :: iseg, nn, nfreq, lfreq
  real, dimension(:,:,:), intent(in) :: tcos, tsin
  real, dimension(:,:), intent(in) :: wtau
!
!
  real, parameter :: tol1 = 1.0E-04
  real, parameter :: tol2 = 1.0E-08
  real, parameter :: sqrt2= 1.41421356237309504880168872420969807856967
  real, parameter :: const1 = 1.0/sqrt2
!
  real    :: const2, wdel, wrun, wuse, fnn, ftrd, ftid, phase, &
             sumt, sumx, sumr, sumi, scos2, ssin2, cross, wtnew
  integer :: i, i1, ii, iput, istop, nstop
  complex :: work
!
  wuse = wz
  fnn  = float(nn)
  const2 = si * const1
  sumt = sum (tsamp(1:nn))
  sumx = sum (xx(1:nn))
  istop = nfreq
!
! initialize for zero frequency
! -----------------------------
  ftrx(1) = sumx / sqrt(fnn)
  ftix(1) = 0.0
  wdel = wuse
  wrun = wuse
  II = 2
!
! start frequency loop
! --------------------
  do while (.true.)
    wtnew = wtau(ii,iseg)
!
!   summations over the sample
!   --------------------------
    cross = sum(tsamp(1:nn) * tcos(1:nn,ii,iseg) * tsin(1:nn,ii,iseg))
    scos2 = sum(tcos(1:nn,ii,iseg)**2.0)
    ssin2 = sum(tsin(1:nn,ii,iseg)**2.0)
    sumr = sum(xx(1:nn) * tcos(1:nn,ii,iseg))
    sumi = sum(xx(1:nn) * tsin(1:nn,ii,iseg))
!
    ftrd = const1 * sumr / sqrt(scos2)
    if (ssin2 .le. tol1) then
       ftid = const2 * sumx / sqrt(fnn)
       if (abs(cross) .gt. tol2) ftid = 0.0
    else
       ftid = const2 * sumi / sqrt(ssin2)
    end if
    phase = wtnew - wrun * tzero
    work = cmplx(ftrd, ftid) * cexp(cmplx(0.0, phase))
    ftrx(ii) = real(work)
    ftix(ii) = aimag(work)
    ii = ii + 1
    wrun = wrun + wdel
    if (ii .gt. istop) exit
  end do
!
! zero-fill transform (oversample inverse) impose symmetry for real data
! ----------------------------------------------------------------------
  if (2 * nfreq .gt. lfreq) then
     write (*,*) 'Error: 2 * nfreq > lfreq'
     stop
  end if
  i1 = nfreq + 1
  do i = i1, lfreq
     ftrx(i) = 0.0
     ftix(i) = 0.0
  end do
  nstop = lfreq / 2
  do i = 2, nstop
     iput = lfreq - i + 2
     ftrx(iput) =  ftrx(i)
     ftix(iput) = -ftix(i)
  end do
!
  end subroutine ftfix
!
!------------------------------------------------------------------------
  subroutine trig(iseg, tsamp, nn, wz, nfreq, tcos, tsin, wtau)
!------------------------------------------------------------------------
  use param
!
  implicit  none
!
  real, dimension(*), intent(in) :: tsamp
  real, intent(in)    :: wz
  integer, intent(in) :: iseg, nn, nfreq
  real,dimension(:,:,:),intent(out):: tcos, tsin
  real,dimension(:,:),intent(out):: wtau
!
  real, parameter :: tol1 = 1.0E-04
  real    :: csum, ssum, wdel, wrun, wuse,  tim, sumtc, sumts, ttt, &
             tc, ts, watan, wtnew,arg
  integer :: i, ii, istop
!
  wuse = wz
  istop = nfreq
  wdel = wuse
  wrun = wuse
  ii = 2
!
! start frequency loop
! --------------------
  do while (.true.)
!
!   calc. tau
!   ---------
    csum = 0.0
    ssum = 0.0
    sumtc = 0.0
    sumts = 0.0
    do i = 1, nn
       ttt  = tsamp(i)
       arg = 2.0 * wrun * ttt
       tc = cos(arg)
       ts = sin(arg)
       csum = csum + tc
       ssum = ssum + ts
       sumtc = sumtc + ttt * tc
       sumts = sumts + ttt * ts
    end do
    if (abs(ssum) .gt. tol1 .or. abs(csum) .gt. tol1) then
       watan = atan2 (ssum, csum)
    else
       watan = atan2 (-sumtc, sumts)
    end if
    wtau(ii,iseg) = 0.5 * watan
    wtnew = wtau(ii,iseg)
!
!   summations over the sample
!   --------------------------
    do i = 1, nn
       tim  = tsamp(i)
       arg = wrun * tim - wtnew
       tcos(i,ii,iseg) = cos(arg)
       tsin(i,ii,iseg) = sin(arg)
    end do
    ii = ii + 1
    wrun = wrun + wdel
    if (ii .gt. istop) exit
  end do
!
  end subroutine trig
!
!------------------------------------------------------------------------
  real function fold(arg)
!------------------------------------------------------------------------
  use const
!
  implicit  none
!
  real, intent(in) :: arg
!
  real, parameter :: argmax = 8000. * pi
!
  fold = arg
  do while (.true.)
     if (fold .le. argmax) exit
     fold = fold - argmax
  end do
  do while (.true.)
     if (fold .gt. -argmax) exit
     fold = fold + argmax
  end do
!
  end function fold
!
!--------------------------------------------------------------------------
  subroutine winwgt(t, iwin, ww)
!--------------------------------------------------------------------------
! calc. normalized window weights
! window type (iwin)  0: Rectangular
!                     1: Welch 1
!                     2: Hanning
!                     3: Parzen (Triangular)
!                     4: Blackman-Harris 3-Term
!--------------------------------------------------------------------------
  use const
!
  implicit none
!
  real, intent(in), dimension(:) :: t
  real, intent(out), dimension(:) :: ww
  integer, intent(in) :: iwin
!
  real :: tlen, jeff, scal, fac1, fac2, fac3, fac4, sumw2, rnp
  integer :: i, nseg
!
! useful factor for various windows
! ---------------------------------
  nseg = size(t)
  rnp = real(nseg)
  fac1 = (rnp / 2.0 ) - 0.5
  fac2 = 1.0 / ((rnp / 2.0 ) + 0.5)
  fac3 = rnp - 1.0
  fac4 = tpi /(rnp - 1.0)
  tlen = t(nseg) - t(1)
  sumw2 = 0
  do i= 1, nseg
      jeff = rnp * (t(i)-t(1)) / tlen
      select case (iwin)
         case (0)                                            ! rectangle
            ww(i) = 1.0
         case (1)                                            ! welch I
            ww(i) = 1.0 - ((jeff - fac1) * fac2)**2.0
         case (2)                                            ! hanning
            ww(i) = 0.5 * (1.0 - cos(tpi * jeff / fac3))
         case (3)                                            ! triangular
            ww(i) = 1.0 - abs((jeff - fac1) * fac2)
         case (4)                                            ! blackman-harris
            ww(i) = 0.4243801 - 0.4973406 * cos(fac4 * jeff) &
                    + 0.0782793 * cos(fac4 * 2.0 * jeff)
      end select
      sumw2 = sumw2 + ww(i) * ww(i)
  end do
!
! determine scaling factor and scale window weights;
! NB: sumw2 = nseg for rectangular window
! --------------------------------------------------
  scal = sqrt(rnp / sumw2)
  do i = 1, nseg
     ww(i) = ww(i) * scal
  end do
!
  end subroutine winwgt
!
!--------------------------------------------------------------------------
  function winbw(iwin, df, ofac)
!--------------------------------------------------------------------------
! Determine 6dB bandwidth from OFAC corrected fundamental frequency.
! Note that the bandwidth for the Blackman-Harris taper is higher than
! reported by Harris (1978, cf. Nuttall, 1981)}
!
! window type (iwin)  0: Rectangular
!                     1: Welch 1
!                     2: Hanning
!                     3: Parzen (Triangular)
!                     4: Blackman-Harris 3-Term
!--------------------------------------------------------------------------
  implicit none
!
  integer, intent(in) :: iwin
  real, intent(in)    :: df, ofac
  real                :: winbw
!
  real, parameter, dimension(0:4) :: bw = (/1.21, 1.59, 2.00, 1.78, 2.26/)
!
  winbw = df * ofac * bw(iwin)
!
  end function winbw
!
!
!------------------------------------------------------------------------
  subroutine rmtrend (x, y, n)
!------------------------------------------------------------------------
! determine linear trend by means of least squares and subtract
! this trend from a data set
!
! parameters:  x, y   : real arrays for data, on output y is replaced
!                       by the detrended values
!              n      : number of data pairs
!
! ref.: after numerical recipes 14.2
!
! written:       23/07/94
! modifications: 29/01/99 - allow n <> array dimension
!------------------------------------------------------------------------
  implicit  none
!
  real, dimension(*), intent(in) :: x
  real, dimension(*), intent(inout) :: y
  integer, intent(in) :: n
!
  real    :: sx, sy, st2, a, b, ss, sxoss, z
  integer :: i
!
  sx = 0.0
  sy = 0.0
  st2 = 0.0
  b = 0.0
  do i = 1, n
     sx = sx + x(i)
     sy = sy + y(i)
  end do
  ss = float(n)
  sxoss = sx / ss
  do i = 1, n
     z = x(i) - sxoss
     st2 = st2 + z*z
     b = b + z * y(i)
  end do
  b = b / st2
  a = (sy - sx * b) / ss
  do i = 1, n
     y(i) = y(i) - (a + b * x(i))
  end do
!
  end subroutine rmtrend
!
!----------------------------------------------------------------------
  subroutine getdof(iwin, n50, dof, neff)
!--------------------------------------------------------------------------
! Effective number of degrees of freedom for the selected window
! and n50 overlappaing segments (Harris, 1978)
!----------------------------------------------------------------------
  implicit none
!
  integer, intent(in) :: iwin, n50
  real, intent(out) :: dof,neff
!
  real, parameter, dimension(0:4) :: c50 = (/0.500, 0.344, 0.167, 0.250, 0.096/)
  real :: c2, denom, rn
!
  rn = real(n50)
  c2 = 2.0 * c50(iwin) * c50(iwin)

  denom = 1.0 + c2 - c2/rn
  neff = rn / denom
  dof = 2.0 * neff
!
  end subroutine getdof
!
!----------------------------------------------------------------------
  real function getchi2(dof, alpha)
!----------------------------------------------------------------------
  use error
  use nr, only : gammp
!
  implicit none
!
  real, parameter :: tol = 1.0e-3
  integer, parameter :: itmax = 100
  real :: dof, alpha
  real :: ac, lm, rm, eps, chi2, za, x, getz
  integer :: iter
!
! use approximation for dof > 30 (Eq. 1.132 in Sachs (1984))
! ----------------------------------------------------------
  if (dof .gt. 30.0) then
     za = -getz(alpha)   ! NB: Eq. requires change of sign for percentile
     if (ierr .eq. 1) return
     x = 2.0 / 9.0 / dof
     chi2 = dof * (1.0 - x + za * sqrt(x))**3.0
  else
     iter = 0
     lm = 0.0
     rm = 1000.0
     if (alpha .gt. 0.5) then
        eps = (1.0 - alpha) * tol
     else
        eps = alpha * tol
     end if
     do
       iter= iter + 1
       if (iter .gt. itmax) then
          write(errio,'(a)') "Error in GETCHI2: Iter > ItMax"
          ierr = 1
          return
       end if
       chi2 = 0.5 * (lm + rm)
       ac = 1.0 - gammp(0.5*dof, 0.5*chi2)
       if (abs(ac - alpha) .le. eps) exit
       if (ac .gt. alpha) then
          lm = chi2
       else
          rm = chi2
       end if
     end do
  end if
  getchi2 = chi2
!
  end function getchi2
!
!----------------------------------------------------------------------
  real function getz(alpha)
!----------------------------------------------------------------------
! Determine percentiles of the normal distribution using an approximation
! of the complementary error function by a Chebyshev polynom.
!
! For a given values of alpha (a), the program returns z(a) such that
! P[Z <= z(a)] = a. Check values are in the front cover of Neter et al.
!----------------------------------------------------------------------
  use error
  use nr, only : erfcc
!
  implicit none
!
  real, parameter :: tol = 1.0e-5
  real, parameter :: sq2 = 1.414213562
  integer, parameter :: itmax = 100
  real :: alpha
  real :: atmp, acalc, zr, zl, zm, z
  integer :: iter
!
  if (alpha .lt. 0.50) then
     atmp = alpha * 2.0
     zr = -0.1
     zl = 10.0
     iter = 0
     do while(.true.)
          iter= iter + 1
          if (iter .gt. itmax) then
             write(errio,'(a)') "Error in GETZ: Iter > ItMax"
             return
          end if
          zm = (zl + zr) / 2.0
          z = zm
          acalc = erfcc(z/sq2)
          if (acalc .gt. atmp) zr = zm
          if (acalc .le. atmp) zl = zm
         if (abs(acalc-atmp) .le. tol) exit
     end do
     z = -1.0 * z
  else if (alpha .ge. 0.50) then
     atmp =(alpha - 0.5) * 2.0
     zl = -0.1
     zr = 10.0
     iter = 0
     do while(.true.)
          iter= iter + 1
          if (iter .gt. itmax) then
             write(*,*) "Error in GETZ: Iter > ItMax"
             return
          end if
          zm = (zl + zr) / 2.0
          z = zm
          acalc = 1.0 - erfcc(zm/sq2)
          if (acalc .gt. atmp) zr = zm
          if (acalc .le. atmp) zl = zm
          if (abs(acalc-atmp) .le. tol) exit
     end do
  end if
  getz = z
!
  end function getz
!
!----------------------------------------------------------------------
  subroutine gettau(rhopre,tx,x,npx,tau)
!----------------------------------------------------------------------
  use const
  use param, only : n50
  use error
  implicit none
  real, intent(in) :: rhopre
  real, dimension(:),intent(in) :: tx, x
  integer,intent(in) :: npx
  real, intent(out) :: tau
  real, dimension(:), allocatable :: twk, xwk
  integer :: nseg, i, j, istart, ialloc
  real :: rho, rhosum, avgdt
!
! average dt of entire time series
! --------------------------------
  avgdt = sum(tx(2:npx)-tx(1:npx-1)) / real(npx-1)
!
!if prescribed tau
   if(rhopre .ge.0.0) then
      tau = -avgdt / log(rhopre)
   else if (rhopre.lt.0.0)then
      rhosum = 0.0
      nseg = int(2 * npx / (n50 + 1))         ! points per segment
      allocate(twk(nseg), xwk(nseg), stat = ialloc)
      if (ialloc .ne. 0) call allocerr("a")
      do i = 1, n50
!
!       copy data of i'th segment into workspace
!       ----------------------------------------
         istart = (i-1) * nseg / 2
         do j = 1, nseg
            twk(j) = tx(istart + j)
            xwk(j) = x(istart + j)
         end do
!
!        detrend data
!        ------------
         call rmtrend (twk(1:nseg), xwk(1:nseg), nseg)
!
!        estimate and sum rho for each segment
!        -------------------------------------
         call tauest(twk(1:nseg), xwk(1:nseg), nseg, tau, rho)
         if (ierr .eq. 1) then
            write(errio,*) ' Error in TAUEST'
            return
         end if
!
!        bias correction for rho (Kendall & Stuart, 1967; Vol. 3))
!        ---------------------------------------------------------
         rho = (rho * (real(nseg) - 1.0) + 1.0) / (real(nseg) - 4.0)
!
         rhosum = rhosum + rho
      end do
!
!     average rho
!     -----------
      rho = rhosum / real(n50)
!
!     average tau
!     -----------
      tau = -avgdt / log(rho)
!
!     make sure that tau is non-negative
!     ----------------------------------
      if (tau .lt. 0.0) then
         ierr = 2
         write (errio,*) 'Warning: GETTAU returned tau =', tau
         write (errio,*) '         Negative tau is forced to zero.'
         tau = 0.0
      end if
!
      deallocate(twk, xwk, stat = ialloc)
      if (ialloc .ne. 0) call allocerr("d")
!
  end if
!
 end subroutine gettau
!
!----------------------------------------------------------------------
!  Manfred Mudelsee's code for tau estimation
!----------------------------------------------------------------------
! TAUEST: Routine for persistence estimation for unevenly spaced time series
!----------------------------------------------------------------------
!       Main variables
!
!       t       :       time
!       x       :       time series value
!       np      :        number of points
!      dt       :       average spacing
!   scalt       :       scaling factor (time)
!     rho       :       in the case of equidistance, rho = autocorr. coeff.
!      ls       :       LS function
!   brent       :       Brent's search, minimum LS value
!    mult       :       flag (multiple solution)
!    amin       :       estimated value of a = exp(-scalt/tau)
!
!----------------------------------------------------------------------
  subroutine tauest(t, x, np, tau, rhoavg)
!
  use const
  use error
!
  implicit none
!
  integer, intent(in) :: np
  real, dimension(np), intent(in) :: t, x
  real, intent (out)  :: tau
  real, dimension(np) :: tscal, xscal
  real :: fac, avg, var, dt, rho, scalt, amin, rhoavg
  double precision :: damin
  integer :: i, mult
!
  external brent, ls, minls, rhoest
!
  interface
     subroutine avevar(data,ave,var)
     use nrtype
     implicit none
     real(sp), dimension(:), intent(in) :: data
     real(sp), intent(out) :: ave, var
     end subroutine avevar
  end interface
!
! Correct time direction; assume that ages are input
! --------------------------------------------------
  do i = 1, np
      tscal(i) = -t(np+1-i)
      xscal(i) = x(np+1-i)
  end do
!
! Scaling of x
! ------------
  call avevar(xscal(1:np), avg, var)
  fac = sqrt(var)
  xscal(1:np) = xscal(1:np) / fac
!
! Scaling of t (=> start value of a = 1/e)
! ---------------------------------------
  dt = (tscal(np)-tscal(1)) / real((np-1))
  call rhoest(np, xscal(1:np), rho)
  if (rho .le. 0.0) then
      rho = 0.05
      write(errio,*) 'Warning: rho estimation: < 0'
      ierr = 2
  else if (rho .gt. 1.0) then
      rho = 0.95
      write(errio,*) 'Warning: rho estimation: > 1'
      ierr = 2
  end if
  scalt = -log(rho)/dt
  tscal(1:np) = tscal(1:np) * scalt
!
! Estimation
! ----------
  call minls(np, dble(tscal(1:np)), dble(xscal(1:np)), damin, mult)
  if (ierr .eq. 1) then
     write(errio,*) ' Error in MNILS'
     return
  end if
  amin = sngl(damin)
  if (mult .eq. 1) then
     write(errio,*) ' Estimation problem: LS function has > 1 minima'
     return
  end if
  if (amin .le. 0.0) then
     write(errio,*) ' Estimation problem: a_min =< 0'
     return
  else if (amin .ge. 1.0) then
     write(errio,*) ' Estimation problem: a_min >= 1'
     return
  end if
!
! determine tau
! -------------
  tau = -1.0 /(scalt*log(amin))
!
! determine rho, corresponding to tau
! -----------------------------------
  rhoavg = exp(-dt / tau)
!
  end subroutine tauest
!
!
!----------------------------------------------------------------------
! Numerical Recipes (modified): Brent's search in one direction.
!----------------------------------------------------------------------
  function brent(ax,bx,cx,f,tol,xmin,xfunc,yfunc,nfunc)
!
  use error
  implicit none
!
  integer nfunc
  double precision xfunc(1:nfunc),yfunc(1:nfunc)
  integer itmax
  double precision brent,ax,bx,cx,tol,xmin,f,cgold,zeps
  external f
  parameter (itmax=100,cgold=.3819660d0,zeps=1.d-18)
  integer iter
  double precision a,b,d,e,etemp,fu,fv,fw,fx,p,q,r,tol1,tol2,u,v,w,x,xm
!
  a=min(ax,cx)
  b=max(ax,cx)
  v=bx
  w=v
  x=v
  e=0.d0
  fx=f(x,xfunc,yfunc,nfunc)
  fv=fx
  fw=fx
  do iter=1,itmax
    xm=0.5d0*(a+b)
    tol1=tol*abs(x)+zeps
    tol2=2.d0*tol1
    if(abs(x-xm).le.(tol2-.5d0*(b-a))) goto 3
    if(abs(e).gt.tol1) then
      r=(x-w)*(fx-fv)
      q=(x-v)*(fx-fw)
      p=(x-v)*q-(x-w)*r
      q=2.d0*(q-r)
      if(q.gt.0.d0) p=-p
      q=abs(q)
      etemp=e
      e=d
      if(abs(p).ge.abs(.5d0*q*etemp).or.p.le.q*(a-x).or.p.ge.q*(b-x))goto 1
      d=p/q
      u=x+d
      if(u-a.lt.tol2 .or. b-u.lt.tol2) d=sign(tol1,xm-x)
      goto 2
    endif
1   if(x.ge.xm) then
      e=a-x
    else
      e=b-x
    endif
    d=cgold*e
2   if(abs(d).ge.tol1) then
      u=x+d
    else
      u=x+sign(tol1,d)
    endif
    fu=f(u,xfunc,yfunc,nfunc)
    if(fu.le.fx) then
      if(u.ge.x) then
        a=x
      else
        b=x
      endif
      v=w
      fv=fw
      w=x
      fw=fx
      x=u
      fx=fu
    else
      if(u.lt.x) then
        a=u
      else
        b=u
      endif
      if(fu.le.fw .or. w.eq.x) then
        v=w
        fv=fw
        w=u
        fw=fu
      else if(fu.le.fv .or. v.eq.x .or. v.eq.w) then
        v=u
        fv=fu
      endif
    endif
  end do
  ierr = 1
  write(errio,*) ' brent: exceed maximum iterations'
3 xmin=x
  brent=fx
  return
  end
!
!
!----------------------------------------------------------------------
! Least-squares function
!----------------------------------------------------------------------
  double precision function ls(a,t,x,n)
  implicit none
  integer n
  double precision t(1:n),x(1:n)
  double precision a
  integer i
  ls=0.0d0
  do i=2,n
     ls=ls+(x(i)-x(i-1)*dsign(1.0d0,a)* dabs(a)**(t(i)-t(i-1)))**2.0d0
  end do
  return
  end
!
!----------------------------------------------------------------------
! Minimization of least-squares function ls.
!----------------------------------------------------------------------
  subroutine minls(n, t, x, amin, nmu_)
!
  use error
!
  implicit none
!
  double precision, parameter :: a_ar1 = 0.367879441d0 ! 1/e
  double precision, parameter :: tol = 3.0d-8          ! Brent's search, precision
  double precision, parameter :: tol2 = 1.0d-6         ! multiple solutions, precision
  integer n
  double precision t(1:n),x(1:n)
  double precision amin
  integer nmu_
  double precision dum1,dum2,dum3,dum4,a_ar11,a_ar12,a_ar13
  double precision ls,brent
  external ls,brent
!
  nmu_=0
  dum1=brent(-2.0d0, a_ar1, +2.0d0, ls, tol, a_ar11, t, x, n)
  dum2=brent( a_ar1, 0.5d0*(a_ar1+1.0d0), +2.0d0, ls, tol, a_ar12, t, x, n)
  dum3=brent(-2.0d0, 0.5d0*(a_ar1-1.0d0),  a_ar1, ls, tol, a_ar13, t, x, n)
  if (ierr .eq. 1) then
     write(errio, *) ' Error in MINLS (call to brent)'
     return
  end if
  if  ((dabs(a_ar12-a_ar11).gt.tol2.and.dabs(a_ar12-a_ar1).gt.tol2) &
  .or.(dabs(a_ar13-a_ar11).gt.tol2.and.dabs(a_ar13-a_ar1).gt.tol2)) &
  nmu_=1
  dum4=dmin1(dum1,dum2,dum3)
  if (dum4.eq.dum2) then
     amin=a_ar12
  else if (dum4.eq.dum3) then
     amin=a_ar13
  else
     amin=a_ar11
  end if
  return
  end
!
!----------------------------------------------------------------------
! Autocorrelation coefficient estimation (equidistant data).
!----------------------------------------------------------------------
  subroutine rhoest(n,x,rho)
!
  implicit none
!
  integer n
  real x(1:n)
  real rho
  integer i
  real sum1,sum2
!
  sum1=0.0
  sum2=0.0
  do i=2,n
     sum1=sum1+x(i)*x(i-1)
     sum2=sum2+x(i)**2.0
  end do
  rho=sum1/sum2
  return
  end
!

!-------------------------------------------------------------------------------------
subroutine ranseed
!-------------------------------------------------------------------------------------
      use nrtype
      use nr, only: ran
      implicit none
!     Seeds random number generator.
      integer :: seed=0
      real(sp) :: dummy=-999.0_sp
      seed=-206761862
      dummy=ran(seed)
end subroutine ranseed
!
!---------------------------------------------------------------------------------------
subroutine gasdev(harvest)
!---------------------------------------------------------------------------------------
      use nrtype
      use nr, only : ran
      implicit none
      real(sp), intent(out) :: harvest
!     Gaussian distribution (Numerical Recipes, modified: uses ran).
      real(sp) :: rsq,v1,v2
      real(sp), save :: g
      logical, save :: gaus_stored=.false.
      integer :: idum=1
      if (gaus_stored) then
          harvest=g
          gaus_stored=.false.
      else
          do
!            call ran(v1)
!            call ran(v2)
             v1=ran(idum)
             v2=ran(idum)
             v1=2.0_sp*v1-1.0_sp
             v2=2.0_sp*v2-1.0_sp
             rsq=v1**2+v2**2
             if (rsq > 0.0 .and. rsq < 1.0) exit
          end do
          rsq=sqrt(-2.0_sp*log(rsq)/rsq)
          harvest=v1*rsq
          g=v2*rsq
          gaus_stored=.true.
      end if
end subroutine gasdev

!--------------------------------------------------------------------------------------------------
!
!     Numerical Recipes code
!-------------------------------------------------------------------------------------------------
!
  !include 'c:\msdata\src\f90\recipes\recipes\avevar.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\ran.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\gammp.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\gser.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\gcf.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\gammln.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\erfcc.f90'
  !include 'c:\msdata\src\f90\recipes\recipes\sort.f90'
