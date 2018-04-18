#include "osqp_configure.h"

PROGRAM TEST_OSQP

  USE OSQP
  USE iso_c_binding
  IMPLICIT NONE

!  integer and real precisions

#ifdef DLONG
    INTEGER, PARAMETER :: ip = c_long_long
#else
    INTEGER, PARAMETER :: ip = c_int
#endif

#ifdef DFLOAT
    INTEGER, PARAMETER :: wp = c_float
#else
    INTEGER, PARAMETER :: wp = c_double
#endif

! set problem components and data

  INTEGER ( KIND = ip ), PARAMETER :: n = 2
  INTEGER ( KIND = ip ), PARAMETER :: m = 3
  INTEGER ( KIND = ip ), PARAMETER :: P_nnz = 4
  INTEGER ( KIND = ip ), DIMENSION( n + 1 ) :: P_ptr = (/ 1, 3, 5 /)
  INTEGER ( KIND = ip ), DIMENSION( P_nnz ) :: P_row = (/ 1, 2, 1, 2 /)
  REAL ( KIND = wp ), DIMENSION( P_nnz ) ::                                    &
    P_val = (/ 4.0_wp, 1.0_wp, 1.0_wp, 2.0_wp /)
  REAL ( KIND = wp ), DIMENSION( n ) :: q = (/ 1.0_wp, 1.0_wp /)
  INTEGER ( KIND = ip ), PARAMETER :: A_nnz = 4
  INTEGER ( KIND = ip ), DIMENSION( n + 1 ) :: A_ptr = (/ 1, 3, 5 /)
  INTEGER ( KIND = ip ), DIMENSION( A_nnz ) :: A_row = (/ 1, 2, 1, 3 /)
  REAL ( KIND = wp ), DIMENSION( A_nnz ) ::                                    &
    A_val = (/ 1.0_wp, 1.0_wp, 1.0_wp, 1.0_wp /)
  REAL ( KIND = wp ), DIMENSION( m ) :: l = (/ 1.0_wp, 0.0_wp, 0.0_wp /)
  REAL ( KIND = wp ), DIMENSION( m ) :: u = (/ 1.0_wp, 0.7_wp, 0.7_wp /)
  REAL ( KIND = wp ), DIMENSION( n ) :: x
  REAL ( KIND = wp ), DIMENSION( m ) :: y
  TYPE ( OSQP_settings_type ) :: settings
  TYPE ( OSQP_info_type ) :: info
  TYPE ( OSQP_data_type ) :: data
  INTEGER ( KIND = ip ) :: status


! change alpha parameter
  settings%alpha = 1.0

!  Change linear system solver
  settings%linsys_solver = 0

!  establish the control settings

  CALL OSQP_settings( settings, data, status )
  IF ( status /= 0 ) THEN
    WRITE( 6, "( ' OSQP_sttings status = ', I0, ' stopping' )" ) status
    ERROR STOP
  END IF

!  solve the problem

  CALL OSQP_solve( m, n, P_ptr, P_row, P_val, q, A_ptr, A_row, A_val, l, u,    &
                   x, y, info, data, status )
  IF ( status /= 0 ) THEN
    WRITE( 6, "( ' OSQP_solve status = ', I0, ' stopping' )" ) status
    STOP
  END IF

  WRITE( 6, "( ' OSQP - Fortran interface' )" )
  WRITE( 6, "( ' objective function', ES12.4 )" ) info%obj_val
  WRITE( 6, "( ' x:', ( 2ES12.4 ) )" ) x
  WRITE( 6, "( ' y:', ( 3ES12.4 ) )" ) y
  WRITE( 6, "( 1X, I0, ' iterations' ) ") info%iter
  WRITE( 6, "( ' status ', A , ' (status value = ', I0, ')' )" )               &
     TRIM( info%status ),  info%status_val

  IF (info%status_val /= 1) THEN
    WRITE(6, "( ' Error. Problem not solved to optimality ' )")
    ERROR STOP
  END IF


!  change vector data and resolve

   q( 1 ) = q( 1 ) + 1.0
   l( 1 ) = l( 1 ) - 0.1
   u( 1 ) = u( 1 ) - 0.1
   x( 1 ) = x( 1 ) + 1.0
   y( 1 ) = y( 1 ) + 1.0

  WRITE( 6, "( /, ' Perturbing problem data and resolving ...', / )" )

  CALL OSQP_resolve( m, n, x, y, info, data, status,                           &
                     q_new = q, l_new = l, u_new = u, x_new = x, y_new = y )
  IF ( status /= 0 ) THEN
    WRITE( 6, "( ' OSQP_solve status = ', I0, ' stopping' )" ) status
    ERROR STOP
  END IF

  WRITE( 6, "( ' modified objective function', ES12.4 )" ) info%obj_val
  WRITE( 6, "( ' x:', ( 2ES12.4 ) )" ) x
  WRITE( 6, "( ' y:', ( 3ES12.4 ) )" ) y
  WRITE( 6, "( 1X, I0, ' iterations' ) ") info%iter
  WRITE( 6, "( ' status ', A , ' (status value = ', I0, ')' )" )               &
     TRIM( info%status ),  info%status_val

  IF (info%status_val /= 1) THEN
    WRITE(6, "( ' Error. Problem not solved to optimality ' )")
    ERROR STOP
  END IF

!  cleanup workspace after use

   CALL OSQP_cleanup( data, status)

  IF ( status /= 0 ) THEN
     WRITE( 6, "( ' OSQP_cleanup status = ', I0, ' stopping' )" ) status
     ERROR STOP
  END IF

  STOP
END PROGRAM TEST_OSQP
