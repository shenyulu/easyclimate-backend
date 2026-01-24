subroutine wet_bulb_temperature(T_dry, RH, P, tolerance, A, max_iter, T_wet)
  use, intrinsic :: iso_fortran_env, only: real64
  implicit none

  ! Inputs
  real(real64), intent(in) :: T_dry
  real(real64), intent(in) :: RH
  real(real64), intent(in) :: P
  real(real64), intent(in) :: tolerance
  real(real64), intent(in) :: A
  integer,      intent(in) :: max_iter

  ! Output
  real(real64), intent(out) :: T_wet

  ! Locals
  real(real64) :: T_guess, T_new, delta_T
  real(real64) :: fval, dfdT
  real(real64) :: f_tolerance
  integer :: iter

  ! ---- configuration (residual tolerance in hPa) ----
  ! Equation is in hPa because e_s returns hPa and P is passed in hPa.
  ! 1e-6 hPa is quite strict; you can relax to 1e-4 if you want.
  f_tolerance = 1.0e-6_real64

  ! Initial guess
  T_new   = T_dry
  delta_T = huge(1.0_real64)
  iter    = 0

  do while (iter < max_iter)

     T_guess = T_new

     fval = f(T_guess, T_dry, RH, P, A)

     ! Dual convergence: temperature step AND residual
     if (abs(fval) <= f_tolerance .and. delta_T <= tolerance) exit

     dfdT = df_dT(T_guess, T_dry, RH, P, A)

     ! Derivative too small => avoid blow-up
     if (abs(dfdT) < 1.0e-12_real64) exit

     ! Newton update
     T_new = T_guess - fval / dfdT

     ! Physical constraint: wet-bulb temperature should not exceed dry-bulb
     if (T_new > T_dry) T_new = T_dry

     delta_T = abs(T_new - T_guess)
     iter = iter + 1
  end do

  T_wet = T_new

contains

  ! Saturation vapor pressure (hPa)
  real(real64) function e_s(T)
    real(real64), intent(in) :: T
    real(real64) :: t_k
    real(real64), parameter :: a = 17.2693882_real64
    real(real64), parameter :: b = 35.86_real64
    real(real64), parameter :: t0 = 273.16_real64
    t_k = T + t0
    e_s = 6.1078_real64 * exp(a * (t_k - t0) / (t_k - b))
  end function e_s

  ! Actual vapor pressure (hPa)
  real(real64) function e_a(T_dry_in, RH_in)
    real(real64), intent(in) :: T_dry_in, RH_in
    e_a = (RH_in / 100.0_real64) * e_s(T_dry_in)
  end function e_a

  ! Nonlinear equation f(Tw)=0 in hPa
  ! f = e_s(Tw) - e_a(Tdry,RH) - A*P*(Tdry-Tw)
  real(real64) function f(T_w, T_dry_in, RH_in, P_in, A_in)
    real(real64), intent(in) :: T_w, T_dry_in, RH_in, P_in, A_in
    real(real64) :: e_w, e_d
    e_w = e_s(T_w)
    e_d = e_a(T_dry_in, RH_in)
    f = e_w - e_d - (A_in * P_in * (T_dry_in - T_w))
  end function f

  ! Numerical derivative df/dT via central difference
  real(real64) function df_dT(T_w, T_dry_in, RH_in, P_in, A_in)
    real(real64), intent(in) :: T_w, T_dry_in, RH_in, P_in, A_in
    real(real64), parameter :: dT = 1.0e-3_real64
    df_dT = ( f(T_w + dT, T_dry_in, RH_in, P_in, A_in) - &
              f(T_w - dT, T_dry_in, RH_in, P_in, A_in) ) / (2.0_real64 * dT)
  end function df_dT

end subroutine wet_bulb_temperature
