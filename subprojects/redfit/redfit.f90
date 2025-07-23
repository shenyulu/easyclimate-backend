! Estimate red-noise background of an autospectrum, which is estimated from
! an unevenly spaced time series. In addition, the program corrects for the
! bias of Lomb-Scargle Fourier transform (correlation of Fourier components),
! which depends on the distribution of the sampling times t(i) along the
! time axis.
!
! Main Assumptions:
! -----------------
!     - The noise background can be approximated by an AR(1) process.
!     - The distribution of data points along the time axis is not
!       too clustered.
!     - The potential effect of harmonic signal components on the
!       estimation procedure is neglected.
!     - The time series has to be weakly stationary.
!
! The first-order autoregressive model, AR(1) model, which is used
! to describe the noise background in a time series x(t_i), reads
!
!
!            x(i) =  rho(i) * x(i-1)  +  eps(i)          (1)
!
!
! with                           t(i) - t(i-1)
!                rho(i) =  exp(- -------------)
!                                     tau
!
! and eps ~ NV(0, vareps). To ensure Var[red] = 1, we set
!
!                                2 * (t(i) - t(i-1))
!            vareps = 1 -  exp(- -------------------).
!                                       tau
!
! Stationarity of the generated AR(1) time series is assured by dropping
! the first N generated points.
!
!
! Computational Steps:
! --------------------
!
! 1. Estimate autospectrum Gxx of the unevenly spaced input time series in the
!    interval [0,fNyq], using the Lomb-Scargle Fourier transform in combination
!    with the Welch-Overlapped-Segment-Averaging (WOSA) procudure, as described
!    in Schulz and Stattegger (1997).
!
! 2. Estimate tau from the unevenly sampled time series using the time-
!    domain algorithm of Mudelsee (200?).
!
! 3. Determine the area under Gxx -> estimator of data variance ==> varx.
!
! 4. Repeat Nsim times
!    - create AR(1) time series (red) acc. to Eq. 1, using the observation
!      times of the input data, but each time with different eps(i)
!    - estimate autospectrum of red ==> Grr
!    - scale Grr such that area under the spectrum is identical to varx
!    - sum Grr ==> GrrSum
!
! 5. Determine arithmetic mean of GrrSum ==> GrrAvg.
!
! 6. Ensure that area under GrrAvg is identical to varx (account for rounding
!    errors).
!
! 7. Calculate theoretical AR(1) spectrum for the estimated tau ==> GRedth.
!
! 8. Scale GRedth such that area under the spectrum is identical to varx (this
!    step is required since the true noise variance of the data set is
!    unknown).
!
! 9. Estimate the frequency-dependent correction factor (corr) for the
!    Lomb-Scargle FT from the ratio between mean of the estimated AR(1) spectra
!    (GrrAvg) and the scaled theoretical AR(1) spectrum (GRedth).
!
! 10. Use correction factors to eliminate the bias in the estimated spectrum
!     Gxx ==> Gxxc.
!
! 11. Scale theorectical AR(1) spectrum for various significance levels.
!
!
! Input:   parameter namelist; passed as config. file via command line
! ------
!          &cfg
!              fnin = 'foo.dat',    File with time series data
!             fnout = 'foo.out',    Results are written to this file
!              nsim = 1000,         Number of simulations
!            mctest = t,            [T/F] Calc. MC-based false-alarm levels
!                                   (Default F)
!              ofac = 4.0,          Oversampling factor for LSFT
!             hifac = 1.0,          max. freq. = HIFAC * <f_Nyq> (Default = 1.0)
!               n50 = 3,            number of WOSA segments (50 % overlap)
!            rhopre = -99.0,        prescibed value for rho; unused if < 0
!                                   Default = -99.0)
!              iwin = 2             window type (0: Rectangular
!          /                                     1: Welch
!                                                2: Hanning
!                                                3: Triangular
!                                                4: Blackman-Harris)
!
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
!
!
! Output:
! -------
! * Estimated parameters and spectra (including significane levels) are
!   written to FNOUT (self-explanatory!).
!
! * Error and warning messages are written to REDFIT.LOG.
!
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
!
! Authors: Michael Schulz, MARUM and Faculty of Geosciences, Univ. Bremen
! -------- Klagenfurter Str., D-28334 Bremen
!          mschulz@marum.de
!          www.geo.uni-bremen.de/~mschulz
!
!          Manfred Mudelsee, Inst. of Meteorology, Univ. Leipzig
!          Stephanstr. 3, D-04103 Leipzig
!          Mudelsee@rz.uni-leipzig.de
!
! Reference: Schulz, M. and Mudelsee, M. (2002) REDFIT: Estimating
! ---------- red-noise spectra directly from unevenly spaced paleoclimatic
!            time series. Computers and Geosciences, 28, 421-426.
!
!
! written: 23.02.2000
! modifications:
!   24.02.00 - V. 2.1
!            - calc. mean tau by averaging over rho_segment instead of
!              tau_segment
!   29.02.00 - V. 2.2
!            - red-noise false-alarm levels from percentiles of MC simulation
!              CI80(:)-CI99(:)
!   05.03.00 - bug fix in MC percentil estimation
!            - don't open log file in append mode
!            - delete log file if no error occured
!   05.03.00 - V. 2.3
!            - option for determination of MC-based false-alarm levels (set
!              by MCTEST in namelist)
!            - MAKEAR: discard first N data points to forget initial conditions
!            - output format changed
!   03.04.00 - V. 2.4
!            - test for equality of theoretical and estimated spectrum added
!              (NOT WELL TESTED YET)
!   03.04.00 - V. 2.5
!            - replace test for equality of theoretical and estimated spectrum
!              by runs test
!            - bias correction for rho added
!   04.04.00 - hifac read from namelist
!            - option to prescribe rho via namelist [RHOPRE]
!            - calc. of false-alarm level after Thomson (1990) added; written
!              to output file together with corresponding scaling of the
!              theoretical red-noise spectrum
!   17.04.00 - V. 2.6
!            - bugfix: equation for rho bias correction was incorrect
!   20.04.00 - V. 3.0
!            - all array memory allocated at runtime
!            - MAKEAR: remove discard of first N data points introduced in
!              V 2.3 (not required; cf. Mudelsee GG paper)
!            - simplify computation of avgdt
!   18.05.00 - V. 3.1
!            - bias correction for rho corrected (again...)
!   10.07.00 - V. 3.2
!            - minor bugfix in winwgt; nseg was not set to an integer value
!            - length of filename set to 80 instead 60 char.
!   05.08.00 - exit gracefully if memory allocation fails (new SR ALLOCERR
!              => write error to unit errio)
!   27.08.00 - V. 3.3
!            - bugfix in getchi2; function did not converge for dof > 5000
!              and small values of alpha
!   05.09.00 - V. 3.4
!            - bugfix in error output during memory allocation failure =>
!              ialloc must be checked after EACH  allocation because first
!              memory alloc. may fail while subsequent allocation with
!              smaller size might still work (resetting ierr to 0)
!   06.09.00 - calculate/display required amount of RAM; pass info to SR
!              ALLOCERR via new module MEMINFO
!   12.01.01 - V. 3.5
!            - rename output col. "Corr. Fac." to "CorrFac" to ease import
!              into Excel
!   18.01.01 - SR ftfix optimized (w/ LF95 Sampler Tool):
!                 - loop over samples modified
!                 - const1 as parameter
!                 ==> ca. 20 % speed increase
!            - incr. accuracy for pi
!   06.03.01 - indication for prescribed rho added to output
!   07.03.01 - add [carriagecontrol = "FORTRAN"] to open statements for output
!              (Non F95! Required by LF95 to avoid leading blank in each record)
!   19.07.04 - V. 3.6
!            - option for (automatic) check of input TS added
!              -> program stops upon descending time axis
!              -> data for mult. sampling times are averaged
!                 (averaged time series is written to TimeSeries.avg)
!   07.01.05 - V. 3.7
!            - bugfix: array dimensions were not modified after correcting for
!              duplicate input times
!   11.09.05 - V. 3.8
!            - ensure non-negative value of tau
!              => write warning to unit errio)
!   05.08.06 - V. 3.8a
!            - Runs Test for 2% and 10% significance added (empirical coeffs. for
!              5% re-calculated using NLR)
!            - output for runs test changed: %acceptance=(1-alpha) instead of alpha
!   24.04.09 - V. 3.8b
!            - for large data sets (N > 10000) overflow in memory allocation; associated
!              integer variables changed to kind = 8
!   13.08.09 - V. 3.8c
!            - inform user to consult log file if an error has occurred.
!   28.07.10 - V. 3.8d
!            - add quotes to head for easier import into spreadsheets.
!   07.11.10 - V. 3.8e
!            - bugfix: rare crahes due to overflow of trigonometric arguments in
!              subroutine TRIG (happens for "old" high-resolution data, i.e. if t*omega
!              gets larger than approx 8e5). Workaround: change variable arg in SR TRIG
!              to double precision
!
!--------------------------------------------------------------------------
!		     M O D U L E   D E F I N I T O N S
!--------------------------------------------------------------------------
! global array dimensions and constants
! -------------------------------------
  module const
     implicit none
     public
     character (len = 11) :: vers = 'REDFIT 3.8e'
     real, parameter :: pi = 3.141592653589793238462643383279502884197
     real, parameter :: tpi = 2.0 * pi
     integer :: maxdim
  end module const
!
! time series data
! ----------------
  module timeser
     implicit none
     public
     real, dimension(:), allocatable :: t, x
     integer :: np
  end module timeser
!
! parameter
! ---------
  module param
     implicit none
     public
     real :: ofac
     real :: hifac = 1.0
     real :: rhopre = -99.0
     integer :: nsim, n50, iwin
     logical :: mctest = .false.
  end module param
!
! trigonometric data for FT
! -------------------------
  module trigwindat
     implicit none
     public
     real, dimension(:,:,:), allocatable :: tcos, tsin
     real, dimension(:,:), allocatable :: wtau, ww
  end module trigwindat
!
! error handling
! --------------
  module error
     implicit none
     public
     integer :: ierr = 0                ! error flag; 1=error in gettau; 2=warning in gettau
     integer, parameter :: errio = 99   ! i/o unit for log file
     logical :: errflag = .false.       ! flags existence of duplicate times in input
  end module error
!
! memory size info
! ----------------
  module meminfo
     implicit none
     public
     integer, parameter :: realsize = kind(1.0)
     integer(kind=8) :: iram
     character (len = 2) :: memunit
  end module meminfo
!
!--------------------------------------------------------------------------
!                 E N D   M O D U L E   D E F I N I T O N S
!--------------------------------------------------------------------------
!
  ! program redfit
  SUBROUTINE run_redfit(cfgfile)  !+ shenyulu 2025.1.9
  USE, INTRINSIC :: ISO_C_BINDING  !+ shenyulu 2025.1.9
!
  use const
  use timeser
  use param
  use trigwindat
  use mutil
  use error
  use meminfo
!
  implicit none
!
  !+ shenyulu 2025.1.9
  ! Declare input parameters (configuration file names from Python)
  CHARACTER(KIND=C_CHAR), DIMENSION(80), INTENT(IN) :: cfgfile
  CHARACTER(LEN=80) :: cfgfile_fortran  ! Convert to a Fortran string
!
  real, dimension(:), allocatable :: &
                          freq, &    ! frequency vector
                          gxx, &     ! autospectrum of input data
                          gxxc, &    ! corrected autospectrum of input data
                          grrsum, &  ! sum of AR(1) spectra
                          grravg, &  ! average AR(1) spectrum
                          gredth, &  ! theoretical AR(1) spectrum
                          corr, &    ! correction factor
                          ci80, &    ! 80% false-alarm level from MC
                          ci90, &    ! 90% false-alarm level from MC
                          ci95, &    ! 95% false-alarm level from MC
                          ci99       ! 99% false-alarm level from MC
  real, dimension(:,:), allocatable :: grr     ! AR(1) spectra
  real, dimension(:), allocatable :: red        ! AR(1) time series
  real :: tau, rnsim, getchi2, fac80, fac90, fac95, fac99, dof, &
          avgdt, fac, rho, rhosq, fnyq, varx, varr, winbw, rnow, rprv, &
          alphacrit, faccrit
  integer:: kstart, kstop, krate, kmax, ntime
  integer, dimension(10) :: idumini
  integer :: i, ncnt, iocheck, nout, idum, rcnt, nseg, ialloc
  integer :: idx80, idx90, idx95, idx99
  integer(kind=8) :: isum
  integer, dimension(3) :: rcritlo, rcrithi
  logical :: ini
  !- shenyulu 2025.1.9
  ! character (len = 80) :: fnin, fnout, cfgfile
  character (len = 80) :: fnin, fnout
!
!
  namelist /cfg/ fnin, fnout, nsim, ofac, hifac, n50, iwin, mctest, rhopre
!
  interface
     subroutine sort(arr)
     use nrtype
     implicit none
     real(sp), dimension(:), intent(inout) :: arr
     end subroutine sort
  end interface
  interface
     subroutine spectr(ini, t, x, ofac, hifac, n50, iwin, frq, gxx)
     implicit none
     logical, intent(in) :: ini
     real, dimension(:), intent(in) :: t, x
     real, intent(in) :: ofac, hifac
     integer, intent(in) :: n50, iwin
     real, dimension(:), intent(out) :: frq, gxx
     end subroutine spectr
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
! open log file for error messages
! --------------------------------
  ! open(errio, file = "redfit.log", carriagecontrol = "FORTRAN")  !- shenyulu 2025.1.9
  open(errio, file = "redfit.log")  !+ shenyulu 2025.1.9

!
! check number of command line arguments
! --------------------------------------
  ! ncnt = nargs()
  ! if (ncnt .ne. 1) then
  !    write (errio, '(1x,a)') 'Error - pass config file via command line!'
  !    close(errio)
  !    write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
  !    stop
  ! end if
!
! retrieve command line arguments
! -------------------------------

  !- shenyulu 2025.1.9
  
  ! cfgfile = getarg(1)
  ! !write(*,*) "cfgfile = ", cfgfile     !+ shenyulu 2022.8.29
  ! open (10, file = cfgfile, form = 'formatted', status = 'old', &
  !      iostat = iocheck)
  ! if (iocheck .ne. 0 ) then
  !    write (errio, *) ' Error - Can''t open config file!'
  !    close(errio)
  !    write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
  !    stop
  ! end if
  ! read(10, nml = cfg)
  ! close (10)

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
! workspace dimensions
! --------------------
  call setdim(fnin, maxdim, nout, nseg)
!
! determine memory requirement
! ----------------------------
  isum = 3*maxdim + 11*nout + 4*nseg
  isum = isum + 2*nout*n50
  isum = isum + 2*nout*nseg*n50
  if (mctest .eqv. .true.) then
     isum = isum + 4*nout + nsim*nout
  else
     isum = isum + nout
  end if
  iram = realsize * isum/1024 ! [kB]
  memunit = "kB"
  if (iram .gt. 1024) then
     iram = iram /1024         ! [MB]
     memunit = "MB"
  end if
  if (iram .gt. 1024) then
     iram = iram /1024         ! [GB]
     memunit = "GB"
  end if
  ! write(*,'(1x,a14,1x,i4,1x,a2//)') "Required RAM =", iram, memunit
!
! setup workspace for input data
! ------------------------------
  allocate(x(maxdim), t(maxdim), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
!
! retrieve time series data
! -------------------------
  call readdat(fnin)
!
! check input time axis
! ---------------------
  call check()
!
! in case of duplicate entries reinitialize array dimensions
! and retrieve averaged time series
! ----------------------------------------------------------
  if (errflag .eqv. .true.) then
     write(*,'(/1x,a/)') "Resetting dimensions after correcting for duplicate sampling times..."
     deallocate(x, t, stat = ialloc)
     if (ialloc .ne. 0) call allocerr("d")
     fnin = "TimeSeries.avg"
     call setdim(fnin, maxdim, nout, nseg)
     allocate(x(maxdim), t(maxdim), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     call readdat(fnin)
  end if
!
! allocate remaining workspace
! ----------------------------
  allocate(red(maxdim), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  allocate (gxxc(nout), grrsum(nout), freq(nout), gxx(nout), &
            grravg(nout), gredth(nout), corr(nout), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  if (mctest .eqv. .true.) then
     allocate (ci80(nout), ci90(nout), ci95(nout), ci99(nout), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
  end if
!
! average dt of entire time series
! --------------------------------
  avgdt = sum(t(2:np)-t(1:np-1)) / real(np-1)
!
! determine autospectrum of input data
! ------------------------------------
  ini = .true.
  call spectr(ini, t(1:np), x(1:np), ofac, hifac, n50, iwin, freq, gxx)
!
! estimate data variance from autospectrum
! ----------------------------------------
  varx = freq(2) * sum(gxx(1:nout))  ! NB: freq(2) = df
!
! estimate tau unless tau is prescribed; die gracefully in case of an error
! -------------------------------------------------------------------------
  if (rhopre .lt. 0.0) then
     call gettau(tau)
     if (ierr .eq. 1) then
        write (errio,*) ' Error in GETTAU'
        close(errio)
        write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
        stop
     end if
!
!   make sure that tau is non-negative
!   ----------------------------------
    if (tau .lt. 0.0) then
       ierr = 2
       write (errio,*) 'Warning: GETTAU returned tau =', tau
       write (errio,*) '         Negative tau is forced to zero.'
       tau = 0.0
    end if
  else
     tau = -avgdt / log(rhopre)
  end if
!
! Generate NSim AR(1) Spectra
! ---------------------------
  if (mctest .eqv. .true.) then
     allocate(grr(nsim, nout), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
  else
     allocate(grr(1, nout), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
  end if
  call random_seed
  call random_seed(get = idumini(1:10))
  idum = -abs(idumini(1))
  grrsum(:) = 0.0
  grravg(:) = 0.0
  rnsim = real(nsim)
  do i = 1, nsim
    !  if ((mod(i,50) .eq. 0) .or. (i .eq. 1)) write(*,*) 'ISim =', i
!
!    setup AR(1) time series and estimate its spectrum
!    -------------------------------------------------
     call makear1(t, np, tau, idum, red)
     if (mctest .eqv. .true.) then
        call spectr(.false., t(1:np), red(1:np), ofac, hifac, n50, iwin, &
                 freq, grr(i,:))
     else
        call spectr(.false., t(1:np), red(1:np), ofac, hifac, n50, iwin, &
                 freq, grr(1,:))
     end if
!
!    scale and sum red-noise spectra
!    -------------------------------
     if (mctest .eqv. .true.) then
        varr = freq(2) * sum(grr(i,1:nout))  ! NB: freq(2) = df
        fac = varx / varr
        grr(i,1:nout) = fac * grr(i,1:nout)
        grrsum(1:nout) = grrsum(1:nout) + grr(i,1:nout)
     else
        varr = freq(2) * sum(grr(1,1:nout))  ! NB: freq(2) = df
        fac = varx / varr
        grrsum(1:nout) = grrsum(1:nout) + fac * grr(1,1:nout)
     end if
  end do
!
! determine average red-noise spectrum; scale average again to
! make sure that roundoff errors do not affect the scaling
! ------------------------------------------------------------
  grravg(1:nout) = grrsum(1:nout) / rnsim
  varr = freq(2) * sum(grravg(1:nout))
  fac = varx / varr
  grravg(1:nout) = fac * grravg(1:nout)
!
! determine lag-1 autocorrelation coefficient
! -------------------------------------------
  rho = exp (-avgdt / tau)              ! avg. autocorrelation coefficient
  rhosq = rho * rho
!
! set theoretical spectrum (e.g., Mann and Lees, 1996, Eq. 4)
! make area equal to that of the input time series
! -----------------------------------------------------------
  fnyq = freq(nout)                   ! Nyquist freq.
  gredth(1:nout) = (1.0-rhosq) / (1.0-2.0*rho*cos(pi*freq(1:nout)/fnyq)+rhosq)
  varr = freq(2) * sum(gredth(1:nout))
  fac = varx / varr
  gredth(1:nout) = fac * gredth(1:nout)
!
! determine correction factor
! ---------------------------
  corr(1:nout) = grravg(1:nout) / gredth(1:nout)
!
! correct for bias in autospectrum
! --------------------------------
  gxxc(1:nout) = gxx(1:nout) / corr(1:nout)
!
! red-noise false-alarm levels from percentiles of MC simulation
! --------------------------------------------------------------
  if (mctest .eqv. .true.) then
     do i = 1, nout
        call sort(grr(1:nsim, i))
     end do

! dbg
!     open (10, file='hist.out', carriagecontrol = "FORTRAN")
!     write (10,*) "#  Freq index: Col.1 = 10"
!     write (10,*) "#              Col.2 = ", nout/2
!     write (10,*) "#              Col.3 = ", nout-10
!     do i = 1, nsim
!        write(10,*) grr(i,10)/corr(10), "  ", grr(i,nout/2)/corr(nout/2),&
!              "  ", grr(i,nout-10)/corr(nout-10)
!     end do
!     close(10)
! dbg end

!
!    set percentil indices
!    ---------------------
     idx80 = int(0.80 * nsim)
     idx90 = int(0.90 * nsim)
     idx95 = int(0.95 * nsim)
     idx99 = int(0.99 * nsim)
!
!    find frequency-dependent percentil and apply bias correction
!    ------------------------------------------------------------
     do i = 1, nout
        ci80(i) = grr(idx80, i) / corr(i)
        ci90(i) = grr(idx90, i) / corr(i)
        ci95(i) = grr(idx95, i) / corr(i)
        ci99(i) = grr(idx99, i) / corr(i)
     end do
  end if
!
! scaling factors for red noise from chi^2 distribution
! -----------------------------------------------------
  call getdof(iwin, n50, dof)
  fac80 = getchi2(dof, 0.20) / dof
  fac90 = getchi2(dof, 0.10) / dof
  fac95 = getchi2(dof, 0.05) / dof
  fac99 = getchi2(dof, 0.01) / dof
  if (ierr .eq. 1) stop
!
! critical false alarm level after Thomson (1990)
! -----------------------------------------------
  nseg = int(2 * np / (n50 + 1))         ! points per segment
  alphacrit = 1.0 / real(nseg)
  faccrit = getchi2(dof, alphacrit) / dof
  if (ierr .eq. 1) stop
!
! test equality of theoretical AR1 and estimated spectrum using a runs test
! (Bendat and Piersol, 1986, p. 95). The empirical equations for calculating
! critical values for different significanes were derived from the tabulated
! critical values in B&P.
! --------------------------------------------------------------------------
  rcnt = 1  ! count the "runs"
  rprv = sign(1.0, gxxc(1)-gredth(1))
  do i = 2, nout
     rnow = sign(1.0, gxxc(i)-gredth(i))
     if (rnow .ne. rprv) rcnt = rcnt + 1
     rprv = rnow
  end do
!
! 10-% level of significance
! -------------------------
  rcritlo(1) = nint((-0.62899892 + 1.0030933 * sqrt(real(nout/2)))**2.0)
  rcrithi(1) = nint(( 0.66522732 + 0.9944506 * sqrt(real(nout/2)))**2.0)
!
! 5-% level of significance
! -------------------------
  rcritlo(2) = nint((-0.78161838 + 1.0069634 * sqrt(real(nout/2)))**2.0)
  rcrithi(2) = nint(( 0.75701059 + 0.9956021 * sqrt(real(nout/2)))**2.0)
!
! 2-% level of significance
! -------------------------
  rcritlo(3) = nint((-0.92210867 + 1.0064993 * sqrt(real(nout/2)))**2.0)
  rcrithi(3) = nint(( 0.82670832 + 1.0014299 * sqrt(real(nout/2)))**2.0)
!
! save results of AR(1) fit
! -------------------------
  call system_clock(kstop, krate, kmax)
  if (kstop .ge. kstart) then
     ntime = (kstop-kstart) / krate
  else ! kmax overflow
     ntime = ((kmax-kstart)+kstop) / krate
  end if
  
  ! open (20, file = fnout, form = "formatted", iostat = iocheck, &
  !      carriagecontrol = "FORTRAN")  !- shenyulu 2025.1.9
  open (20, file = fnout, form = "formatted", iostat = iocheck) !+ shenyulu 2025.1.9

  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t create ', trim(fnout)
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
     stop
  end if
  write (20,*) '# ', vers
  write (20,*) '#'
  write (20,*) '# Input:'
  write (20,*) '# ------'
  write (20,*) '# File = ', trim(fnin)
  write (20,*) '# OFAC = ', ofac
  write (20,*) '# HIFAC = ', hifac
  write (20,*) '# n50 = ', n50
  write (20,*) '# Iwin = ', iwin
  write (20,*) '# Nsim = ', Nsim
  write (20,*) '#'
  write (20,*) '# Initial values:'
  write (20,*) '# ---------------'
  write (20,*) '# idum = ', - abs(idumini(1))
  write (20,*) '# Data variance (from data spectrum) = ', varx
  write (20,*) '# Avg. dt = ', avgdt
  write (20,*) '#'
  write (20,*) '# Results:'
  write (20,*) '# --------'
  if (rhopre .lt. 0.0) then
     write (20,*) '# Avg. autocorr. coeff., rho = ', rho
  else
     write (20,*) '# PRESCRIBED avg. autocorr. coeff., rho = ', rhopre
  end if
  write (20,*) '# Avg. tau = ', tau
  write (20,*) '# Degrees of freedom = ', dof
  write (20,*) '# 6-dB Bandwidth = ', winbw(iwin, freq(2)-freq(1), ofac)
  write (20,*) '# Critical false-alarm level (Thomson, 1990) = ', &
                   (1.0-alphacrit) * 100.0
  write (20,*) '#    ==> corresponding scaling factor for red noise = ', faccrit
  write (20,*) '#'
  write (20,*) '# Equality of theoretical and data spectrum: Runs test'
  write (20,*) '# ---------------------------------------------------'
  if ((iwin .eq. 0) .and. (ofac .eq. 1.0) .and. (n50 .eq. 1)) then
    write (20,*) '# 90-% acceptance region: rcritlo = ', rcritlo(1)
    write (20,*) '#                         rcrithi = ', rcrithi(1)
    write (20,*) '#'
    write (20,*) '# 95-% acceptance region: rcritlo = ', rcritlo(2)
    write (20,*) '#                         rcrithi = ', rcrithi(2)
    write (20,*) '#'
    write (20,*) '# 98-% acceptance region: rcritlo = ', rcritlo(3)
    write (20,*) '#                         rcrithi = ', rcrithi(3)
    write (20,*) '#'
    write (20,*) '# r_test = ', rcnt
  else
    if (iwin .ne. 0) write (20,*)   '# Test requires IWin = 0'
    if (ofac .ne. 1.0) write (20,*) '# Test requires OFAC = 1.0'
    if (n50 .ne. 1) write (20,*)    '# Test requires N50 = 1'
  end if
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
  write (20,*) '#  7: 80%-Chi2 = 80-% false-alarm level (Chi^2)'
  write (20,*) '#  8: 90%-Chi2 = 90-% false-alarm level (Chi^2)'
  write (20,*) '#  9: 95%-Chi2 = 95-% false-alarm level (Chi^2)'
  write (20,*) '# 10: 99%-Chi2 = 99-% false-alarm level (Chi^2)'
  if (mctest .eqv. .true.) then
     write (20,*) '# 11: 80%-MC = 80-% false-alarm level (MC)'
     write (20,*) '# 12: 90%-MC = 90-% false-alarm level (MC)'
     write (20,*) '# 13: 95%-MC = 95-% false-alarm level (MC)'
     write (20,*) '# 14: 99%-MC = 99-% false-alarm level (MC)'
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Gxx""",7x,"""Gxx_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",5x,"""80%-Chi2""",4x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""",5x,"""80%-MC""",6x,"""90%-MC""",6x,"""95%-MC""",6x,"""99%-MC""")')
     do i = 1, nout
        write (20,'(1x,14(e12.6,2x))') freq(i), gxx(i), gxxc(i), gredth(i), &
                   grravg(i), corr(i), gredth(i)*fac80, gredth(i)*fac90, &
                   gredth(i)*fac95, gredth(i)*fac99, ci80(i), ci90(i), &
                   ci95(i), ci99(i)
     end do
  else
     write (20,*) '#'
     write(20,'("#  ""Freq""",9x,"""Gxx""",7x,"""Gxx_corr""",4x,"""Gred_th""",6x,"""<Gred>""",5x,&
 &               """CorrFac""",5x,"""80%-Chi2""",4x,"""90%-Chi2""",4x,"""95%-Chi2""",&
 &               4x,"""99%-Chi2""")')
     do i = 1, nout
        write (20,'(1x,10(e12.6,2x))') freq(i), gxx(i), gxxc(i), gredth(i), &
                   grravg(i), corr(i), gredth(i)*fac80, gredth(i)*fac90, &
                   gredth(i)*fac95, gredth(i)*fac99
     end do
  end if
  close(20)
  
!---------------------------
! ! Binary file output
! ! + shenyulu 2022.8.29
!---------------------------
    
    open(50, file = "tmp_real.output", form = "unformatted", access = "stream")
    if (rhopre .lt. 0.0) then
        write(50) ofac, hifac, &
                  - abs(idumini(1)), varx, avgdt, &
                  rho, tau, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacrit) * 100.0, faccrit, &
                  rcritlo(1), rcrithi(1), rcritlo(2), rcrithi(2), rcritlo(3), rcrithi(3)
    else
        write(50) ofac, hifac, &
                  - abs(idumini(1)), varx, avgdt, &
                  rhopre, tau, dof, winbw(iwin, freq(2)-freq(1), ofac), (1.0-alphacrit) * 100.0, faccrit, &
                  rcritlo(1), rcrithi(1), rcritlo(2), rcrithi(2), rcritlo(3), rcrithi(3)
    end if
    close(50)
    
    open(50, file = "tmp_int.output", form = "unformatted", access = "stream")
    write(50) n50, iwin, Nsim, &
              rcnt, ntime, nout
    close(50)
    
    if (mctest .eqv. .true.) then
        open(50, file = "tmp_array.output", form = "unformatted", access = "stream")
        write(50) freq, gxx, gxxc, gredth, grravg, corr, gredth*fac80, gredth*fac90, gredth*fac95, gredth*fac99, ci80, ci90, ci95, ci99
        close(50)
    else
        open(50, file = "tmp_array.output", form = "unformatted", access = "stream")
        write(50) freq, gxx, gxxc, gredth, grravg, corr, gredth*fac80, gredth*fac90, gredth*fac95, gredth*fac99
        close(50)
    end if
    
!---------------------------

!
! clean up
! --------
  if (ierr .eq. 0) then
     close(errio, status = "delete")
  else
     close(errio, status = "keep")
     write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
  end if
  deallocate (tsin, tcos, wtau, ww, grr, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  deallocate(x, t, red, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  deallocate (freq, gxx, gxxc, grrsum, grravg, gredth, corr, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  if (mctest .eqv. .true.) then
     deallocate (ci80, ci90, ci95, ci99, stat = ialloc)
     if (ialloc .ne. 0) call allocerr("d")
  end if
!
  CLOSE(errio, STATUS="DELETE")
!
  end
!
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
  use meminfo
!
  implicit none
!
  character(len=1), intent(in)  :: ichar
!
  if (ichar .eq. "a") then
     write (errio, '(1x,a)') 'Error - Insufficient RAM; memory allocation failed!'
     write (errio, '(9x,a16,1x,i4,1x,a2)') 'Setting requires', iram, memunit
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
     stop
  end if
  if (ichar .eq. "d") then
     write (errio, '(1x,a)') 'Error - memory deallocation failed!'
     close(errio)
     write(*,*) "An error has occurred. Check REDFIT.LOG for further information."
     stop
  end if
!
  end subroutine allocerr
!
!
!--------------------------------------------------------------------------
  subroutine setdim(fnin, maxdim, nout, nseg)
!--------------------------------------------------------------------------
! Analyze data file and set array dimensions.
!--------------------------------------------------------------------------
  use timeser
  use param
  use error
!
  implicit none
!
  character (len = 80), intent(in) :: fnin
  integer, intent(out) :: maxdim, nout, nseg
!
  real :: tdum, xdum, t1, avgdt, tp, df, fnyq
  integer :: i, iocheck, nfreq
  character (len = 1) :: flag
!
! open input file
! ---------------
  open (10, file = fnin, form = 'formatted', status = 'old', &
       iostat = iocheck)
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t open ', trim(fnin)
     close(errio)
     stop
  end if
!
! skip header
! -----------
  do while (.true.)
     read (10, '(a1)') flag
     if (flag .ne. '#') then
        backspace (10)
        exit
     end if
  end do
!
! count data
! ----------
  i = 1
  do while (.true.)
     read (10, *, iostat = iocheck) tdum, xdum
     if (i .eq. 1) t1 = tdum      ! save initial time
     if (iocheck .ne. 0) exit
     i = i + 1
  end do
  close(10)
!
! number of input data
! --------------------
  np = i - 1
!
! set max. array dimension
! ------------------------
  maxdim = np
!
! number of output data (code copied from SR spectr())
! ----------------------------------------------------
  nseg = int(2 * np / (n50 + 1))         ! points per segment
  avgdt = (tdum - t1) / real(np-1)       ! avg. sampling interval
  tp = avgdt * nseg                      ! average period of a segment
  df = 1.0 / (ofac * tp)                 ! freq. spacing
  fnyq = hifac * 1.0 / (2.0 * avgdt)     ! average Nyquist freq.
  nfreq = fnyq / df + 1                  ! f(1) = f0; f(nfreq) = fNyq
  nout = nfreq
!
! diagnostic output to stdout
! ---------------------------
  ! write (*,*) "   N =", np
  ! write (*,*) "t(1) = ", t1
  ! write (*,*) "t(N) = ", tdum
  ! write (*,*) "<dt> = ", avgdt
  ! write (*,*) "Nout =", nout
  ! write (*,*)
!
  end subroutine setdim
!
!
!--------------------------------------------------------------------------
  subroutine readdat(fnin)
!--------------------------------------------------------------------------
  use timeser
  use error
!
  implicit none
!
  character (len = 80), intent(in) :: fnin
!
  integer :: i, iocheck
  character (len = 1) :: flag
!
! open input file
! ---------------
  open (10, file = fnin, form = 'formatted', status = 'old', &
       iostat = iocheck)
  if (iocheck .ne. 0 ) then
     write (errio, *) ' Error - Can''t open ', trim(fnin)
     close(errio)
     stop
  end if
!
! skip header
! -----------
  do while (.true.)
     read (10, '(a1)') flag
     if (flag .ne. '#') then
        backspace (10)
        exit
     end if
  end do
!
! retrieve data
! -------------
  do i = 1, np
     read (10,*) t(i), x(i)
  end do
  close(10)
!
  end subroutine readdat
!
!
!--------------------------------------------------------------------------
  subroutine check()
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
  do i = 1, np-1
     if (t(i) .gt. t(i+1)) then
        err_order = .true.
        write(errio,'(1x,a,1x,e12.6)') 'Descending time axis at t =', t(i)
     end if
  end do
  if (err_order .eqv. .true.) stop
!
! check for duplicates time and replace values of time-dependent variable by their mean
! -------------------------------------------------------------------------------------
  idx = 1
  do while (.true.)
     if (t(idx+1) .eq. t(idx)) then
        err_dupl = .true.
        write(errio,'(1x,a,1x,e12.6,1x,a)') 'Duplicate time at t =', t(idx), '...averaging data'
!
!       search for multiple occurrences
!       -------------------------------
        icnt = 0
        do i = 1, np-idx
           if (t(idx+i) .eq. t(idx)) icnt = icnt + 1
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
           do i = idx+1, np-1
                t(i) = t(i+1)
                x(i) = x(i+1)
           end do
           np  = np - 1
        end do
     end if
     idx = idx + 1
     if (idx .eq. np-1) exit
  end do
!
! save averaged data set
! ----------------------
  if (err_dupl .eqv. .true.) then
     errflag = .true.
     open(90, file = "TimeSeries.avg")
     do i = 1, np
        write(90,*) t(i), x(i)
     end do
     close(90)
  end if
!
  end subroutine check
!
!
!--------------------------------------------------------------------------
  subroutine spectr(ini, t, x, ofac, hifac, n50, iwin, frq, gxx)
!--------------------------------------------------------------------------
  use trigwindat
  use const
!
  implicit none
!
  real, parameter :: si = 1.0
  real, parameter :: tzero = 0.0
!
  logical, intent(in) :: ini
  real, dimension(:), intent(in) :: t, x
  real, intent(in) :: ofac, hifac
  integer, intent(in) :: n50, iwin
  real, dimension(:), intent(out) :: frq, gxx
!
  real, dimension(:), allocatable :: twk, xwk, ftrx, ftix
  integer :: i, j, np, nseg, nfreq, lfreq, istart, nout, ialloc
  real ::  avgdt, tp, wz, scal, df, fnyq
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
! set parameters for transform
! ----------------------------
  np = size(t)                           ! # of data points
  nseg = int(2 * np / (n50 + 1))         ! points per segment
  avgdt = (t(np) - t(1)) / real(np-1)    ! average sampling interval
  tp = avgdt * nseg                      ! average period of a segment
  df = 1.0 / (ofac * tp)                 ! freq. spacing
  wz = 2.0 * pi * df                     ! omega = 2*pi*f
  fnyq = hifac * 1.0 / (2.0 * avgdt)     ! average Nyquist freq.
  nfreq = fnyq / df + 1                  ! f(1) = f0; f(nfreq) = fNyq
  lfreq = nfreq * 2
  nout = nfreq
!
! setup workspace
! ---------------
  gxx(:) = 0.0
  allocate(twk(nseg), xwk(nseg), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  allocate(ftrx(lfreq), ftix(lfreq), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  if (ini .eqv. .true.) then
     allocate(tcos(nseg,nfreq,n50), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     allocate(tsin(nseg,nfreq,n50), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     allocate(wtau(nfreq,n50), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
     allocate(ww(nseg,n50), stat = ialloc)
     if (ialloc .ne. 0) call allocerr("a")
  end if
!
  do i = 1, n50
!
!    copy data of i'th segment into workspace
!    ----------------------------------------
     istart = (i-1) * nseg / 2
     do j = 1, nseg
        twk(j) = t(istart + j)
        xwk(j) = x(istart + j)
     end do
!
!    detrend data
!    ------------
     call rmtrend (twk(1:nseg), xwk(1:nseg), nseg)
!
!    apply window to data
!    --------------------
     if (ini .eqv. .true.) call winwgt(twk(1:nseg), iwin, ww(1:nseg, i))
     xwk(1:nseg) = ww(1:nseg, i) * xwk(1:nseg)
!
!    setup trigonometric array for LSFT
!    ----------------------------------
     if (ini .eqv. .true.) call trig(i, twk(1:nseg), nseg, wz, nfreq)
!
!    LSFT
!    ----
     call ftfix(i, xwk(1:nseg), twk(1:nseg), nseg, wz, nfreq, si, lfreq, tzero, ftrx, ftix)
!
!    sum raw spectra
!    ---------------
     do j = 1, nout
        gxx(j) = gxx(j) + (ftrx(j)*ftrx(j) + ftix(j)*ftix(j))
     end do
  end do
!
! scale autospectrum and setup frequency axis
! -------------------------------------------
  scal = 2.0 / (n50 * nseg * df * ofac)
  do i = 1, nout
     gxx(i) = gxx(i) * scal
     frq(i) = (i-1) * df
  end do
  deallocate(twk, xwk, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  deallocate(ftrx, ftix, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
!
  end subroutine spectr
!
!
!--------------------------------------------------------------------------
  subroutine makear1(t, np, tau, idum, red)
!--------------------------------------------------------------------------
  use const
!
  implicit none
!
  integer, intent(in)    :: np
  real, dimension(np), intent(in) :: t
  real, intent(in)       :: tau
  integer, intent(inout) :: idum
  real, dimension(np), intent(out) :: red
!
  real :: sigma, dt, gasdev
  integer :: i
!
! set up AR(1) time series
! ------------------------
  red(1) = gasdev(idum)
  do i = 2, np
     dt = t(i) - t(i-1)
     sigma = 1.0 - exp(-2.0 * dt / tau)
     sigma = sqrt (sigma)
     red(i) = exp(-dt/tau) * red(i-1) + sigma * gasdev(idum)
  end do
!
  end subroutine makear1
!
!
!------------------------------------------------------------------------
  subroutine ftfix(iseg, xx, tsamp, nn, wz, nfreq, si, lfreq, tzero, ftrx, ftix)
!------------------------------------------------------------------------
! Fourier transformation for unevenly spaced data
! (Scargle, 1989; ApJ 343, 874-887)
!
! - folding of trigonom. and exp. arguments in a*pi disabled
!------------------------------------------------------------------------
  use trigwindat
  implicit  none
!
  real, dimension(*), intent(in) :: xx, tsamp
  real, dimension(*), intent(out) :: ftrx, ftix
  real, intent(in)    :: wz, si, tzero
  integer, intent(in) :: iseg, nn, nfreq, lfreq
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
!
!------------------------------------------------------------------------
  subroutine trig(iseg, tsamp, nn, wz, nfreq)
!------------------------------------------------------------------------
  use trigwindat
  use param
!
  implicit  none
!
  real, dimension(*), intent(in) :: tsamp
  real, intent(in)    :: wz
  integer, intent(in) :: iseg, nn, nfreq
!
  real, parameter :: tol1 = 1.0E-04
!
  real    :: csum, ssum, wdel, wrun, wuse,  tim, sumtc, sumts, ttt, &
             tc, ts, watan, wtnew
  !double  :: arg                       ! - shenyulu 2022.8.29
  double precision :: arg               ! + shenyulu 2022.8.29
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
!
!----------------------------------------------------------------------
  subroutine getdof(iwin, n50, dof)
!--------------------------------------------------------------------------
! Effective number of degrees of freedom for the selected window
! and n50 overlappaing segments (Harris, 1978)
!----------------------------------------------------------------------
  implicit none
!
  integer, intent(in) :: iwin, n50
  real, intent(out) :: dof
!
  real, parameter, dimension(0:4) :: c50 = (/0.500, 0.344, 0.167, 0.250, 0.096/)
  real :: c2, denom, rn, neff
!
  rn = real(n50)
  c2 = 2.0 * c50(iwin) * c50(iwin)
  denom = 1.0 + c2 - c2/rn
  neff = rn / denom
  dof = 2.0 * neff
!
  end subroutine getdof
!
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
!
!----------------------------------------------------------------------
  subroutine gettau(tau)
!----------------------------------------------------------------------
  use const
  use param
  use timeser
  use error
!
  implicit none
!
  real, intent(out) :: tau
  real, dimension(:), allocatable :: twk, xwk
  integer :: nseg, i, j, istart, ialloc
  real :: rho, rhosum, avgdt
!
  rhosum = 0.0
  nseg = int(2 * np / (n50 + 1))         ! points per segment
  allocate(twk(nseg), xwk(nseg), stat = ialloc)
  if (ialloc .ne. 0) call allocerr("a")
  do i = 1, n50
!
!    copy data of i'th segment into workspace
!    ----------------------------------------
     istart = (i-1) * nseg / 2
     do j = 1, nseg
        twk(j) = t(istart + j)
        xwk(j) = x(istart + j)
     end do
!
!    detrend data
!    ------------
     call rmtrend (twk(1:nseg), xwk(1:nseg), nseg)
!
!    estimate and sum rho for each segment
!    -------------------------------------
     call tauest(twk(1:nseg), xwk(1:nseg), nseg, tau, rho)
     if (ierr .eq. 1) then
       write(errio,*) ' Error in TAUEST'
       return
     end if
!
!    bias correction for rho (Kendall & Stuart, 1967; Vol. 3))
!    ---------------------------------------------------------
     rho = (rho * (real(nseg) - 1.0) + 1.0) / (real(nseg) - 4.0)
!
     rhosum = rhosum + rho
  end do
!
! average rho
! -----------
  rho = rhosum / real(n50)
!
! average dt of entire time series
! --------------------------------
  avgdt = sum(t(2:np)-t(1:np-1)) / real(np-1)
!
! average tau
! -----------
  tau = -avgdt / log(rho)
!
  deallocate(twk, xwk, stat = ialloc)
  if (ialloc .ne. 0) call allocerr("d")
  end subroutine gettau
!
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
!       np      :       number of points
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
!
!----------------------------------------------------------------------
!     Numerical Recipes code
!----------------------------------------------------------------------
  !include 'F:\num_recipes\recipes_f-90\avevar.f90'
  !include 'F:\num_recipes\recipes_f\gasdev.f'
  !include 'F:\num_recipes\recipes_f-90\ran.f90'
  !include 'F:\num_recipes\recipes_f-90\gammp.f90'
  !include 'F:\num_recipes\recipes_f-90\gser.f90'
  !include 'F:\num_recipes\recipes_f-90\gcf.f90'
  !include 'F:\num_recipes\recipes_f-90\gammln.f90'
  !include 'F:\num_recipes\recipes_f-90\erfcc.f90'
  !include 'F:\num_recipes\recipes_f-90\sort.f90'
