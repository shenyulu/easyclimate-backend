
!-----------------------------------------------------------------------
!BOP
!
! !MODULE: HumanIndexMod
!
! !DESCRIPTION:
! Calculates Wetbulb Temperature, Stull Wet Bulb Temperature,
! 	     Heat Index, Apparent Temperature, Simplified Wet Bulb 
!	     Globe Temperature, Humidex, Discomfort Index, Stull 
!	     Discomfort Index, Temperature Humidity Comfort Index, 
!	     Temperature Humidity Physiology Index, Swamp Cooler 
!	     Temperature, Kelvin to Celsius, Vapour Pressure, & QSat_2
!
! !PUBLIC TYPES:
!
! !PUBLIC MEMBER FUNCTIONS:

!
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-07-12
! Modified 03-14-12--- filter routines for WB
!
! Modified 08-12-12--- filter for below zero calculation. 
! 	   Added WB = T at 0 and below
! Modified 05-13-13--- Adding additional Metrics. 
! 	   Added Apparent Temperature (Australian BOM)
! 	   Added Simplified Wetbulb Globe Temperature
! 	   Added Humidex
! 	   Added Discomfort Index
!	   The previous Metrics were from Keith Oleson
! 	   Added Temperature Humidity Index
! 	   Added Swamp Cooler Efficiency
!
! Modified 05-16-13--- Added Current Vapour Pressure and 
! 	   Kelvin to Celsius and converted all
!	   equations that use these inputs
! Modified 08-30-13--- Finalized Comments.  Added a new 
! 	   qsat algorithm.  Changed wet bulb calculations
!	   to calculate over the large range of atmospheric 
!	   conditions.  
! Modified 03-21-14--- Changed Specific Humidity to Mixing
!          Ratio.
!
! Modified 04-08-16--- Added new convergence routine for
!          Wet_Bulb.  CLM4.5 Inputs at 50C 100% RH cause NaN.
!          Davies-Jones is not calibrated for Tw above 40C.
!          Modification makes all moisture calculations
!          internal to Wet_Bulb.  External input of RH used,
!          Not external Q due to differences in QSat_2 and
!          QSatMod at high RH and T>45C.
!
! Modified 20-12-20--- Qinqin Kong discovered an error in
!          QSat_2Mod. The derivative of F(Tw;pi) =  
!          F(Tw;pi) * dlnF(Tw;pi)/dTw. The modifications
!          to the code are included.
!EOP
!-----------------------------------------------------------------------


!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: AppTemp
!
! !INTERFACE:
  subroutine AppTemp (Tc_1, vap_pres, u10_m, app_temp)
!
! !DESCRIPTION:
! Apparent Temperature (Australian BOM): Here we use equation 22 
! 	   where AT is a function of air temperature (C), water 
!	   vapor pressure (kPa), and 10-m wind speed (m/s). vap_pres
!	   from Erich Fischer (consistent with CLM equations)
!
! Reference:  Steadman, R.G., 1994: Norms of apparent temperature
!             in Australia, Aust. Met. Mag., 43, 1-16. 
! 	      
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_1     ! temperature (C)
    real, intent(in)  :: vap_pres ! Vapor Pressure (pa)
    real, intent(in)  :: u10_m    ! Winds at 10m (m/s)
    real, intent(out) :: app_temp ! Apparent Temperature (C)
!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    app_temp = Tc_1 + 3.30*vap_pres/1000. - 0.70*u10_m - 4.0

  end subroutine AppTemp
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: swbgt
!
! !INTERFACE:
  subroutine swbgt (Tc_2, vap_pres, s_wbgt)
!
! !DESCRIPTION:
! Simplified Wet Bulb Globe Temperature: 
! 	     Requires air temperature (C), water vapor pressure (hPa)
!
! Reference:  Willett, K.M., and S. Sherwood, 2010: Exceedance of heat
! 	      index thresholds for 15 regions under a warming 
! 	      climate using the wet-bulb globe temperature,
! 	      Int. J. Climatol., doi:10.1002/joc.2257
! 	      
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_2     ! temperature (C)
    real, intent(in)  :: vap_pres ! Vapor Pressure (pa)
    real, intent(out) :: s_wbgt   ! Simplified Wet Bulb Globe Temperature (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    s_wbgt = 0.567*(Tc_2)  + 0.393*vap_pres/100. + 3.94

  end subroutine swbgt
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: hmdex
!
! !INTERFACE:
  subroutine hmdex (Tc_3, vap_pres, humidex)
!
! !DESCRIPTION:
! Humidex:
!	Requires air temperature (C), water vapor pressure (hPa)
! Reference:  Masterson, J., and F. Richardson, 1979: Humidex, a 
! 	      method of quantifying human discomfort due to 
!	      excessive heat and humidity, CLI 1-79, Environment 
!	      Canada, Atmosheric Environment Service, Downsview, Ontario
! 	      
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_3     ! temperature (C)
    real, intent(in)  :: vap_pres ! Vapor Pressure (Pa)
    real, intent(out) :: humidex  ! Humidex (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    humidex = Tc_3 + ((5./9.) * (vap_pres/100. - 10.))

  end subroutine hmdex
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: dis_coi
!
! !INTERFACE:
  subroutine dis_coi (Tc_4, wb_t, discoi)
!
! !DESCRIPTION:
! Discomfort Index
! 	     The wet bulb temperature is from Davies-Jones, 2008.
! 	     Requires air temperature (C), wet bulb temperature (C) 
! Reference:  Epstein, Y., and D.S. Moran, 2006: Thermal comfort and the heat stress indices,
! 	      Ind. Health, 44, 388-398.
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_4     ! temperature (C)
    real, intent(in)  :: wb_t     ! Wet Bulb Temperature (C)
    real, intent(out) :: discoi   ! Discomfort Index (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    discoi = 0.5*wb_t + 0.5*Tc_4

  end subroutine dis_coi
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: dis_coiS
!
! !INTERFACE:
  subroutine dis_coiS (Tc_5, relhum, wbt_s, discois)
!
! !DESCRIPTION:
! Discomfort Index
! The wet bulb temperature is from Stull, 2011.
!     	  Requires air temperature (C), wet bulb temperature (C) 
! Reference:  Epstein, Y., and D.S. Moran, 2006: Thermal comfort and the heat stress indices,
! 	      Ind. Health, 44, 388-398.
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_5      ! temperature (C)
    real, intent(in)  :: wbt_s     ! Wet Bulb Temperature (C)
    real, intent(in)  :: relhum    ! Relative Humidity (%)
    real, intent(out) :: discois   ! Discomfort Index (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
    real ::  Tc                    ! 2-m temperature with limit (C)
    real ::  rh                    ! 2-m relative humidity with limit (%)
    real ::  rh_min                ! Minimum 2-m relative humidity (%)

!
!-----------------------------------------------------------------------
    Tc = min(Tc_5,50.)
    rh = min(relhum,99.)
    rh = max(rh,5.)
    rh_min = Tc*(-2.27)+27.7
    if (Tc < -20. .or. rh < rh_min) then
       ! wbt_s calculation invalid
       discois = Tc
    else
       ! wbt_s calculation valid
       discois = 0.5*wbt_s + 0.5*Tc
    end if

  end subroutine dis_coiS
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Wet_Bulb
!
! !INTERFACE:
  subroutine Wet_Bulb (Tin_1,vape,pin,relhum,qin,Teq,epott,wb_it)

!
! !DESCRIPTION:
! Calculates Wet Bulb Temperature, Theta_wb, Theta_e, Moist Pot Temp, 
! 	     Lifting Cond Temp, and Equiv Temp using Davies-Jones 2008 Method.
! 	     1st calculates the lifting cond temperature (Bolton 1980 eqn 22).  
! 	     Then calculates the moist pot temp (Bolton 1980 eqn 24). Then 
!	     calculates Equivalent Potential Temperature (Bolton 1980 eqn 39).  
!	     From equivalent pot temp, equiv temp and Theta_w (Davies-Jones 
!	     2008 eqn 3.5-3.8).  An accurate 'first guess' of wet bulb temperature
! 	     is determined (Davies-Jones 2008 eqn 4.8-4.11). Newton-Raphson
! 	     is used for 2 iterations, determining final wet bulb temperature 
! 	     (Davies-Jones 2008 eqn 2.6).
! Requires Temperature,Vapour Pressure,Atmospheric Pressure,Relative Humidity,Mixing Ratio
! Reference:  Bolton: The computation of equivalent potential temperature. 
! 	      Monthly weather review (1980) vol. 108 (7) pp. 1046-1053
!	      Davies-Jones: An efficient and accurate method for computing the 
!	      wet-bulb temperature along pseudoadiabats. Monthly Weather Review 
!	      (2008) vol. 136 (7) pp. 2764-2785
! 	      Flatau et al: Polynomial fits to saturation vapor pressure. 
!	      Journal of Applied Meteorology (1992) vol. 31 pp. 1507-1513
! Note: Pressure needs to be in mb, mixing ratio needs to be in 
! 	kg/kg in some equations, and in g/kg in others.  
! Calculates Iteration via Newton-Raphson Method.  Only 2 iterations.
! Reference:  Davies-Jones: An efficient and accurate method for computing the 
!	      wet-bulb temperature along pseudoadiabats. Monthly Weather Review 
!	      (2008) vol. 136 (7) pp. 2764-2785
! 	      Flatau et al: Polynomial fits to saturation vapor pressure. 
!	      Journal of Applied Meteorology (1992) vol. 31 pp. 1507-1513
! Note: Pressure needs to be in mb, mixing ratio needs to be in 
! 	kg/kg in some equations. 
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-07-12
! Modified JRBuzan 06-29-13:  Major Revision.  Changes all Calculations to be based
! 	   	   	      upon Bolton eqn 39.  Uses Derivatives in Davies-Jones
!			      2008 for calculation of vapor pressure.
! Modified JRBuzan 03-21-14:  Minor Revision.  Changed specific humidity to mixing 
!                             ratio.
!
! Modified JRBuzan 04-08-16:  Added new convergence routine for
!                             Wet_Bulb.  CLM4.5 Inputs at 50C 100% RH cause NaN.
!                             Davies-Jones is not calibrated for Tw above 40C.
!                             Modification makes all moisture calculations
!                             internal to Wet_Bulb.  External input of RH used,
!                             Not external Q due to differences in QSat_2 and
!                             QSatMod at high RH and T>45C.
! !USES:
! JRB BEGIN
!     04-08-16: For use with CESM, log entry.      
!     use clm_varctl  , only : iulog
! JRB END
!
! !ARGUMENTS:
    implicit none
    real, parameter :: SHR_CONST_TKFRZ = 273.15
    real, intent(in) :: Tin_1	! 2-m air temperature (K)
    real, intent(in) :: vape 	! Vapour Pressure (Pa)
    real, intent(in) :: pin	 	! Atmospheric Pressure (Pa)
    real, intent(in) :: relhum	! Relative Humidity (%)
    real, intent(in) :: qin	 	! Specific Humidity (kg/kg)

    real, intent(out) :: Teq	! Equivalent Temperature (K)
    real, intent(out) :: epott 	! Equivalent Potential Temperature (K)
    real, intent(out) :: wb_it	! Constant used for extreme cold temparatures (K)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
    real :: k1		        ! Quadratic Parameter (C)
    real :: k2		 	! Quadratic Parameter scaled by X (C) 
    real :: pmb		 	! Atmospheric Surface Pressure (mb)
    real :: D		 	! Linear Interpolation of X

    real :: constA = 2675.	! Constant used for extreme cold temparatures (K)
    real :: grms = 1000. 	! Gram per Kilogram (g/kg)
    real :: p0 = 1000.   	! surface pressure (mb)
    real :: C			! Temperature of Freezing (K)

    real :: hot	! Dimensionless Quantity used for changing temperature regimes
    real :: cold	! Dimensionless Quantity used for changing temperature regimes    

    real :: kappad = 0.2854	! Heat Capacity
    real :: T1     	 		! Temperature (K)
    real :: vapemb        		! Vapour Pressure (mb)
    real :: mixr        		! Mixing Ratio (g/kg)

    real :: es_mb_teq		! saturated vapour pressure for wrt TEQ (mb)
    real :: de_mbdTeq		! Derivative of Saturated Vapour pressure wrt TEQ (mb/K)
    real :: dlnes_mbdTeq		! Log derivative of the sat. vap pressure wrt TEQ (mb/K)
    real :: rs_teq			! Mixing Ratio wrt TEQ (kg/kg)
    real :: rsdTeq			! Derivative of Mixing Ratio wrt TEQ (kg/kg/K)
    real :: foftk_teq		! Function of EPT wrt TEQ 
    real :: fdTeq			! Derivative of Function of EPT wrt TEQ 

    real :: wb_temp			! Wet Bulb Temperature First Guess (C)
    real :: es_mb_wb_temp		! Vapour Pressure wrt Wet Bulb Temp (mb)
    real :: de_mbdwb_temp		! Derivative of Sat. Vapour Pressure wrt WB Temp (mb/K)
    real :: dlnes_mbdwb_temp	! Log Derivative of sat. vap. pressure wrt WB Temp (mb/K)
    real :: rs_wb_temp		! Mixing Ratio wrt WB Temp (kg/kg)
    real :: rsdwb_temp		! Derivative of Mixing Ratio wrt WB Temp (kg/kg/K)
    real :: foftk_wb_temp		! Function of EPT wrt WB Temp
    real :: fdwb_temp		! Derivative of function of EPT wrt WB Temp

    real :: tl		 	! Lifting Condensation Temperature (K)
    real :: theta_dl	 	! Moist Potential Temperature (K)
    real :: pi		 	! Non dimensional Pressure
    real :: X		 	! Ratio of equivalent temperature to freezing scaled by Heat Capacity

!    real(I8) :: j			! Iteration Step Number

! JRB BEGIN
! 04-08-16: Changing vapemb to internal Q and Vape using QSat_2.
!           Generating place holder variables.
    real :: vapemb_sat		 	! Saturated vapor pressure (mb)
    real :: de_mbdT_sat		 	! Saturated d(es)/d(T)
    real :: dlnes_mbdT_sat		 	! Saturated dln(es)/d(T)
    real :: rs_T_sat   		 	! Saturated humidity (kg/kg)
    real :: rsdT_sat		 	! Saturated d(qs)/d(T)
    real :: foftk_t_sat		 	! Saturated Davies-Jones eqn 2.3
    real :: fdT_sat                         ! Saturated d(f)/d(T)
!           Also adding convergence criteria
    real :: convergence = 0.0001 ! Convergence value
    real :: wb_temp_new             ! Wet Bulb Temperature Subsequent Guess (C)
    integer  :: iter                    ! Iteration number
    integer  :: max_iter = 1000         ! Iteration Maximum
    integer  :: converged               ! Converge Result: 0 = No, 1 = Yes
      
! JRB END
!
!-----------------------------------------------------------------------
! JRB BEGIN
! 04-08-16: Changing vapemb to internal Q and Vape.  Using RH and QSat_2 to
!           derive Q and Vape.  Commenting out previous code.
!
!     C = SHR_CONST_TKFRZ		! Freezing Temperature
!    pmb = pin*0.01		! pa to mb
!    vapemb = vape*0.01	! pa to mb
!    T1 = Tin_1			! Use holder for T
!! JRB BEGIN
!! 03-21-14 Changing specific humidity to mixing ratio
!!   mixr = qin * grms               ! change mixing ratio to g/kg
!    mixr = qin/(1. - qin) * grms ! change specific humidity to mixing ratio (g/kg)
!! JRB END

    C = SHR_CONST_TKFRZ       ! Freezing Temperature
    pmb = pin*0.01		! pa to mb
    T1 = Tin_1			! Use holder for T

    call QSat_2(T1, pin, vapemb_sat, de_mbdT_sat, dlnes_mbdT_sat, rs_T_sat, rsdT_sat, foftk_t_sat, fdT_sat)

    vapemb = vapemb_sat * relhum * 0.01  ! vapor pressure (mb) 
    mixr = rs_T_sat * relhum * 0.01 * grms ! change specific humidity to mixing ratio (g/kg)

! JRB END

! Calculate Equivalent Pot. Temp (pmb, T, mixing ratio (g/kg), pott, epott)	
! Calculate Parameters for Wet Bulb Temp (epott, pmb)
    pi = (pmb/p0)**(kappad)
    D = (0.1859*pmb/p0 + 0.6512)**(-1.)
    k1 = -38.5*pi*pi +137.81*pi -53.737
    k2 = -4.392*pi*pi +56.831*pi -0.384

! Calculate lifting condensation level.  first eqn 
! uses vapor pressure (mb)
! 2nd eqn uses relative humidity.  
! first equation: Bolton 1980 Eqn 21.
!   tl = (2840./(3.5*log(T1) - log(vapemb) - 4.805)) + 55.
! second equation: Bolton 1980 Eqn 22.  relhum = relative humidity
    tl = (1./((1./((T1 - 55.))) - (log(relhum/100.)/2840.))) + 55.

! Theta_DL: Bolton 1980 Eqn 24.
    theta_dl = T1*((p0/(pmb-vapemb))**kappad)*((T1/tl)**(mixr*0.00028))

! EPT: Bolton 1980 Eqn 39.  
    epott = theta_dl*exp(((3.036/tl)-0.00178)*mixr*(1. + 0.000448*mixr))
    Teq = epott*pi			! Equivalent Temperature at pressure
    X = (C/Teq)**3.504
	   	
! Calculates the regime requirements of wet bulb equations.
    if (Teq > 355.15) then
       hot = 1.0
    else
       hot = 0.0
    endif

    if ((X >= 1.) .AND. (X <= D)) then
       cold = 0.
    else
       cold = 1.
    endif

! Calculate Wet Bulb Temperature, initial guess
! Extremely cold regime if X.gt.D then need to 
! calculate dlnesTeqdTeq 
    if (X > D) then
       call QSat_2(Teq, pin, es_mb_teq, de_mbdTeq, dlnes_mbdTeq, rs_teq, rsdTeq, foftk_teq, fdTeq)
       wb_temp = Teq - C - ((constA*rs_teq)/(1. + (constA*rs_teq*dlnes_mbdTeq)))
    else
       wb_temp = k1 - 1.21 * cold - 1.45 * hot - (k2 - 1.21 * cold) * X + (0.58 / X) * hot
    endif

! JRB BEGIN
! 04-06-16: Adding iteration constraint.  Commenting out original code.
!
!! Newton-Raphson Method  2 iteration
!! May need to put in a second iteration.  Probably best with a do loop.
!!    do j = 0, 1
!       call QSat_2(wb_temp+C, pin, es_mb_wb_temp, de_mbdwb_temp, dlnes_mbdwb_temp, &
!           rs_wb_temp, rsdwb_temp, foftk_wb_temp, fdwb_temp)
!       wb_temp = wb_temp - ((foftk_wb_temp - X)/fdwb_temp)
!       wb_it = wb_temp
!
!       call QSat_2(wb_temp+C, pin, es_mb_wb_temp, de_mbdwb_temp, dlnes_mbdwb_temp, &
!           rs_wb_temp, rsdwb_temp, foftk_wb_temp, fdwb_temp)
!       wb_temp = wb_temp - ((foftk_wb_temp - X)/fdwb_temp)
!       wb_it = wb_temp
    converged = 0
    iter = 0
    do while ( converged .eq. 0 .and. iter < max_iter)

       iter = iter + 1
       call QSat_2(wb_temp+C, pin, es_mb_wb_temp, de_mbdwb_temp, dlnes_mbdwb_temp, &
           rs_wb_temp, rsdwb_temp, foftk_wb_temp, fdwb_temp)
       wb_temp_new = wb_temp - ((foftk_wb_temp - X)/fdwb_temp)

       if ( abs(wb_temp - wb_temp_new) < convergence ) converged = 1
       wb_temp = (0.9*wb_temp + 0.1*wb_temp_new)

    end do

    if ( converged .eq. 1 ) then
       wb_it = wb_temp
       else
!       wb_it = -9999.  ! Place Holder.
       wb_it = T1 - C  ! Place Holder.  wet bulb temperature (C)
!     Write to log.  Modify for CESM.
!     write(iulog,*) 'WARNING-Wet_Bulb failed to converge. Setting to T: WB, P, T, RH, Q, VaporP: ', &
!            wb_it, pin, T1, relhum, qin, vape
     print*, 'WARNING-Wet_Bulb failed to converge. Setting to T: WB, P, T, RH, Q: ', &
            wb_it, pin, T1, relhum, qin, vape
    endif

!!    end do

! JRB END 04-08-16
      
  end subroutine Wet_Bulb
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Wet_BulbS
!
! !INTERFACE:
  subroutine Wet_BulbS (Tc_6,rh,wbt)

!
! !DESCRIPTION:
! Reference:  Stull, R., 2011: Wet-bulb temperature from relative humidity
! 	      and air temperature, J. Appl. Meteor. Climatol., doi:10.1175/JAMC-D-11-0143.1
! 	      Note: Requires air temperature (C) and relative humidity (%)
! Note: Pressure needs to be in mb, mixing ratio needs to be in 
! 	kg/kg in some equations. 
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-07-12
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in) :: Tc_6	 ! Temperature (C)
    real, intent(in) :: rh	 	 ! Relative Humidity (%)
    real, intent(out) :: wbt	 ! Wet Bulb Temperature (C)
!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
    wbt = Tc_6 * atan(0.151977*sqrt(rh + 8.313659)) + &
          atan(Tc_6+rh) - atan(rh-1.676331) + &
          0.00391838*rh**(3./2.)*atan(0.023101*rh) - &
          4.686035

  end subroutine Wet_BulbS
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: HeatIndex
!
! !INTERFACE:
  subroutine HeatIndex (Tc_7, rh, hi)
!
! !DESCRIPTION:
! National Weather Service Heat Index 
! Requires air temperature (F), relative humidity (%)
! Valid for air temperatures above 20C. If below this set heatindex to air temperature.
! Reference: Steadman. The assessment of sultriness. Part I: 
! 	     A temperature-humidity index based on human physiology
!	     and clothing science. J Appl Meteorol (1979) vol. 18 (7) pp. 861-873
!  	     Lans P. Rothfusz. "The heat index 'equation' (or
! 	     more than you ever wanted to know about heat index)", 
!	     Scientific Services Division (NWS Southern Region Headquarters), 1 July 1990
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-07-12
! Modified JRBuzan 03-10-12
! Modified JRBuzan 05-14-13:  removed testing algorithm
! 	   	   	      Switched output to Celsius
!			      Used Boundary Conditions from 
!			      Keith Oleson
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_7     ! temperature (C)
    real, intent(in)  :: rh       ! relative humidity (%)
    real, intent(out) :: hi       ! Heat Index (C)
!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
    real :: tf
!
!-----------------------------------------------------------------------
    tf = (Tc_7) * 9./5. + 32.    ! fahrenheit

    if (tf < 68.) then
       hi = tf
    else
       hi = -42.379 + 2.04901523*tf                     &
                       + 10.14333127*rh                    &
                       + (-0.22475541*tf*rh)               &
                       + (-6.83783e-3*tf**2.)           &
                       + (-5.481717e-2*rh**2.)          &
                       + 1.22874e-3*(tf**2.)*rh         &
                       + 8.5282e-4*tf*rh**2.            &
                       + (-1.99e-6*(tf**2.)*(rh**2.))
    endif
    hi = (hi - 32.) * 5./9.	     ! Celsius

  end subroutine HeatIndex
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: THIndex
!
! !INTERFACE:
  subroutine THIndex (Tc_8, wb_t, thic, thip)
!
! !DESCRIPTION:
! Temperature Humidity Index
! The wet bulb temperature is Davies-Jones 2008 (subroutine WetBulb)
! Requires air temperature (C), wet bulb temperature (C) 
! Calculates two forms of the index:  Comfort and Physiology
! Reference:  NWSCR (1976): Livestock hot weather stress. 
! 	      Regional operations manual letter C-31-76. 
!	      National Weather Service Central Region, USA
!	      Ingram: Evaporative cooling in the pig. Nature (1965)
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-15-13
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_8     ! temperature (C)
    real, intent(in)  :: wb_t     ! Wet Bulb Temperature (C)
    real, intent(out) :: thic     ! Temperature Humidity Index Comfort (C)
    real, intent(out) :: thip     ! Temperature Humidity Index Physiology (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    thic = 0.72*wb_t + 0.72*(Tc_8) + 40.6
    thip = 0.63*wb_t + 1.17*(Tc_8) + 32.

  end subroutine THIndex
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: SwampCoolEff
!
! !INTERFACE:
  subroutine SwampCoolEff (Tc_9, wb_t, tswmp80, tswmp65)
!
! !DESCRIPTION:
! Swamp Cooler Efficiency
! 	The wet bulb temperature is Davies-Jones 2008 (subroutine WetBulb)
! 	Requires air temperature (C), wet bulb temperature (C) 
! 	Assumes that the Swamp Cooler Efficiency 80% (properly maintained)
! 	and 65% (improperly maintained).  
! Reference:  Koca et al: Evaporative cooling pads: test 
! 	      procedure and evaluation. Applied engineering
!	      in agriculture (1991) vol. 7
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-15-13
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: Tc_9     ! temperature (C)
    real, intent(in)  :: wb_t     ! Wet Bulb Temperature (C)
    real, intent(out) :: tswmp80  ! Swamp Cooler Temp 80% Efficient (C)
    real, intent(out) :: tswmp65  ! Swamp Cooler Temp 65% Efficient (C)

!
! !CALLED FROM:
! subroutine SLakeFluxes in module SLakeFluxesMod
! subroutine CanopyFluxes in module CanopyFluxesMod
! subroutine UrbanFluxes in module UrbanMod
! subroutine BareGroundFluxes in module BareGroundFluxesMod
!
! !LOCAL VARIABLES:
!EOP
!
    real :: neu80 = 0.80  ! 80% Efficient
    real :: neu65 = 0.65  ! 65% Efficient

!
!-----------------------------------------------------------------------
    tswmp80 = Tc_9 - neu80*(Tc_9 - wb_t)
    tswmp65 = Tc_9 - neu65*(Tc_9 - wb_t)

  end subroutine SwampCoolEff
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: KtoC
!
! !INTERFACE:
  subroutine KtoC (T_k, T_c)
!
! !DESCRIPTION:
! Converts Kelvins to Celsius
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-16-13
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: T_k        ! temperature (K)
    real, intent(out) :: T_c        ! temperature (C)
    real, parameter :: SHR_CONST_TKFRZ = 273.15
!
! !CALLED FROM:
! subroutines within this module
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    T_c = T_k - SHR_CONST_TKFRZ

  end subroutine KtoC
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: VaporPres
!
! !INTERFACE:
  subroutine VaporPres (rh, e, erh)
!
! !DESCRIPTION:
! Calculates Vapour Pressure
! 	     Vapour Pressure from Erich Fischer (consistent with CLM 
!	     equations, Keith Oleson)
! !REVISION HISTORY:
! Created by Jonathan R Buzan 03-16-13
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, intent(in)  :: rh        ! Relative Humidity (%)
    real, intent(in)  :: e         ! Saturated Vapour Pressure (Pa)
    real, intent(out) :: erh       ! Vapour Pressure (Pa)

!
! !CALLED FROM:
! subroutines within this module
!
! !LOCAL VARIABLES:
!EOP
!
!    real :: 

!
!-----------------------------------------------------------------------
    erh = (rh/100.) *e   ! Pa

  end subroutine VaporPres
!EOP
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: QSat_2
!
! !INTERFACE:
  subroutine QSat_2 (T_k, p_t, es_mb, de_mbdT, dlnes_mbdT, rs, rsdT, foftk, fdT)
!
! !DESCRIPTION:
! Computes saturation mixing ratio and the change in saturation
! mixing ratio with respect to temperature.  Uses Bolton eqn 10, 39.
! Davies-Jones eqns 2.3,A.1-A.10
! Reference:  Bolton: The computation of equivalent potential temperature. 
! 	      Monthly weather review (1980) vol. 108 (7) pp. 1046-1053
!	      Davies-Jones: An efficient and accurate method for computing the 
!	      wet-bulb temperature along pseudoadiabats. Monthly Weather Review 
!	      (2008) vol. 136 (7) pp. 2764-2785
!
! Modified JRBuzan 20-12-20: Error in derivative for fdt found by Qinqin Kong.
!
! !USES:
!
! !ARGUMENTS:
    implicit none
    real, parameter :: SHR_CONST_TKFRZ = 273.15
    real, intent(in)  :: T_k        ! temperature (K)
    real, intent(in)  :: p_t        ! surface atmospheric pressure (pa)
    real, intent(out) :: es_mb      ! vapor pressure (pa)
    real, intent(out) :: de_mbdT    ! d(es)/d(T)
    real, intent(out) :: dlnes_mbdT ! dln(es)/d(T)
    real, intent(out) :: rs       	! humidity (kg/kg)
    real, intent(out) :: rsdT     	! d(qs)/d(T)
    real, intent(out) :: foftk     	! Davies-Jones eqn 2.3
    real, intent(out) :: fdT     	! d(f)/d(T)

!
! !CALLED FROM:
! subroutines within this module
!
! !REVISION HISTORY:
! Created by: Jonathan R Buzan 08/08/13
!
! !LOCAL VARIABLES:
!EOP
!
!
    real :: lambd_a = 3.504	! Inverse of Heat Capacity
    real :: alpha = 17.67	! Constant to calculate vapour pressure
    real :: beta = 243.5		! Constant to calculate vapour pressure
    real :: epsilon = 0.6220	! Conversion between pressure/mixing ratio
    real :: es_C = 6.112		! Vapour Pressure at Freezing STD (mb)
    real :: vkp = 0.2854		! Heat Capacity
    real :: y0 = 3036.		! constant
    real :: y1 = 1.78		! constant
    real :: y2 = 0.448		! constant
    real :: refpres = 1000.	! Reference Pressure (mb)
    real :: p_tmb			! Pressure (mb)
    real :: ndimpress		! Non-dimensional Pressure
    real :: prersdt			! Place Holder for derivative humidity
    real :: pminuse			! Vapor Pressure Difference (mb)
    real :: tcfbdiff		! Temp diff ref (C)
    real :: p0ndplam		! dimensionless pressure modified by ref pressure
    
    real :: rsy2rs2			! Constant function of humidity
    real :: oty2rs			! Constant function of humidity
    real :: y0tky1			! Constant function of Temp

    real :: d2e_mbdT2		! d2(es)/d(T)2
    real :: d2rsdT2			! d2(r)/d(T)2
    real :: goftk			! g(T) exponential in f(T)
    real :: gdT			! d(g)/d(T)
    real :: d2gdT2			! d2(g)/d(T)2

    real :: d2fdT2			! d2(f)/d(T)2  (K)
!
!-----------------------------------------------------------------------
! Constants used to calculate es(T)
! Clausius-Clapeyron
    p_tmb = p_t*0.01
    tcfbdiff = T_k - SHR_CONST_TKFRZ + beta
    es_mb = es_C*exp(alpha*(T_k - SHR_CONST_TKFRZ)/(tcfbdiff))
    dlnes_mbdT = alpha*beta/((tcfbdiff)*(tcfbdiff))
    pminuse = p_tmb - es_mb
    de_mbdT = es_mb*dlnes_mbdT
    d2e_mbdT2 = dlnes_mbdT*(de_mbdT - 2*es_mb/(tcfbdiff))

! Constants used to calculate rs(T)
    ndimpress = (p_tmb/refpres)**vkp
    p0ndplam = refpres*ndimpress**lambd_a
    rs = epsilon*es_mb/(p0ndplam - es_mb)
    prersdt = epsilon*p_tmb/((pminuse)*(pminuse))
    rsdT = prersdt*de_mbdT
    d2rsdT2 = prersdt*(d2e_mbdT2 -de_mbdT*de_mbdT*(2./(pminuse)))

! Constants used to calculate g(T)
    rsy2rs2 = rs + y2*rs*rs
    oty2rs = 1. + 2.*y2*rs
    y0tky1 = y0/T_k - y1
    goftk = y0tky1*(rs + y2*rs*rs)
    gdT = - y0*(rsy2rs2)/(T_k*T_k) + (y0tky1)*(oty2rs)*rsdT
    d2gdT2 = 2.*y0*rsy2rs2/(T_k*T_k*T_k) - 2.*y0*rsy2rs2*(oty2rs)*rsdT + &
    y0tky1*2.*y2*rsdT*rsdT + y0tky1*oty2rs*d2rsdT2

! Calculations for used to calculate f(T,ndimpress)
    foftk = ((SHR_CONST_TKFRZ/T_k)**lambd_a)*(1. - es_mb/p0ndplam)**(vkp*lambd_a)* &
      	    exp(-lambd_a*goftk)
! JRB BEGIN
! 20-12-20 Correct derivative error found by Qinqin Kong. Original was dlnf/dTw.
!          Now f(Tw) * dlnf/dTw. 
    fdT = -lambd_a*(1./T_k + vkp*de_mbdT/pminuse + gdT)
!    fdT = -lambd_a*(1./T_k + vkp*de_mbdT/pminuse + gdT) * foftk
!    d2fdT2 = lambd_a*(1./(T_k*T_k) - vkp*de_mbdT*de_mbdT/(pminuse*pminuse) - &
!             vkp*d2e_mbdT2/pminuse - d2gdT2)
! JRB END

  end subroutine QSat_2
