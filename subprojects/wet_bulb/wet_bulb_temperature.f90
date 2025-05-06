subroutine wet_bulb_temperature(T_dry, RH, P, tolerance, A, max_iter, T_wet)
  implicit none
  real, intent(in) :: T_dry
  real, intent(in) :: RH
  real, intent(in) :: P
  real, intent(in) :: tolerance
  real, intent(in) :: A
  integer, intent(in) :: max_iter
  real, intent(out) :: T_wet
  real :: T_guess, T_new, delta_T
  integer :: iter

  ! 
  T_guess = T_dry   ! 

  ! 
  iter = 0
  delta_T = tolerance + 1.0
  T_new = T_guess

  do while (delta_T > tolerance .and. iter < max_iter)
     T_guess = T_new
     T_new = T_guess - (f(T_guess, T_dry, RH, P, A) / df_dT(T_guess, T_dry, RH, P, A))
     delta_T = abs(T_new - T_guess)
     iter = iter + 1
  end do

  T_wet = T_new

contains

  ! 
  real function e_s(T)
    real, intent(in) :: T
    e_s = 6.112 * exp(17.67 * T / (T + 243.5))
  end function e_s

  ! 
  real function e_a(T_dry, RH)
    real, intent(in) :: T_dry, RH
    e_a = (RH / 100.0) * e_s(T_dry)
  end function e_a

  ! 
  real function f(T_w, T_dry, RH, P, A)
    real, intent(in) :: T_w, T_dry, RH, P, A
    real :: e_w, e_d
    e_w = e_s(T_w)
    e_d = e_a(T_dry, RH)
    f = e_w - e_d - (A * P * (T_dry - T_w))
  end function f

  ! 
  real function df_dT(T_w, T_dry, RH, P, A)
    real, intent(in) :: T_w, T_dry, RH, P, A
    real :: dT = 0.001
    df_dT = (f(T_w + dT, T_dry, RH, P, A) - f(T_w - dT, T_dry, RH, P, A)) / (2.0 * dT)
  end function df_dT

end subroutine wet_bulb_temperature