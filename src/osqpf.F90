#include "osqp_configure.h"

MODULE OSQP

  USE iso_c_binding
  USE OSQP_types
  IMPLICIT NONE

  PRIVATE
  PUBLIC :: OSQP_settings_type, OSQP_info_type, OSQP_data_type,                &
            OSQP_solve, OSQP_resolve, OSQP_settings, OSQP_cleanup

!  integer and real precisions as defined during osqp installation

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

!  ----------------------------
!  interface blocks for c calls
!  ----------------------------

!  settings procedure

  INTERFACE
    FUNCTION osqp_f2c_settings( settings, c_settings ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef DLONG
    INTEGER, PARAMETER :: ip = c_long_long
#else
    INTEGER, PARAMETER :: ip = c_int
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_settings
    TYPE ( OSQP_settings_type ) :: settings
    TYPE ( C_PTR ) :: c_settings
    END function osqp_f2c_settings
  END INTERFACE

!  solve procedure

  INTERFACE
    FUNCTION osqp_f2c_solve( m, n, P_nnz, P_val, P_row, P_ptr, A_nnz, A_val,   &
                             A_row, A_ptr, q, l, u, x, y, info,                &
                             c_settings, c_work, c_data ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_solve
    INTEGER ( KIND = ip ), VALUE :: n
    INTEGER ( KIND = ip ), VALUE :: m
    INTEGER ( KIND = ip ), VALUE :: P_nnz
    INTEGER ( KIND = ip ), DIMENSION( n + 1 ) :: P_ptr
    INTEGER ( KIND = ip ), DIMENSION( P_nnz ) :: P_row
    REAL ( KIND = wp ), DIMENSION( P_nnz ) :: P_val
    INTEGER ( KIND = ip ), VALUE :: A_nnz
    INTEGER ( KIND = ip ), DIMENSION( n + 1 ) :: A_ptr
    INTEGER ( KIND = ip ), DIMENSION( A_nnz  ) :: A_row
    REAL ( KIND = wp ), DIMENSION( A_nnz ) :: A_val
    REAL ( KIND = wp ), DIMENSION( n ) :: q
    REAL ( KIND = wp ), DIMENSION( m ) :: l
    REAL ( KIND = wp ), DIMENSION( m ) :: u
    REAL ( KIND = wp ), DIMENSION( n ) :: x
    REAL ( KIND = wp ), DIMENSION( m ) :: y
    TYPE ( OSQP_info_type ) :: info
    TYPE ( C_PTR ), VALUE :: c_settings
    TYPE ( C_PTR ) :: c_work
    TYPE ( C_PTR ) :: c_data
    END function osqp_f2c_solve
  END INTERFACE

!  resolve procedure

  INTERFACE
    FUNCTION osqp_f2c_resolve( m, n, x, y, info, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_resolve
    INTEGER ( KIND = ip ), VALUE :: n
    INTEGER ( KIND = ip ), VALUE :: m
    REAL ( KIND = wp ), DIMENSION( n ) :: x
    REAL ( KIND = wp ), DIMENSION( m ) :: y
    TYPE ( OSQP_info_type ) :: info
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_resolve
  END INTERFACE

!  update linear cost procedure

  INTERFACE
    FUNCTION osqp_f2c_update_lin_cost( n, q_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_update_lin_cost
    INTEGER ( KIND = ip ), VALUE :: n
    REAL ( KIND = wp ), DIMENSION( n ) :: q_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_update_lin_cost
  END INTERFACE

!  update lower and upper bounds procedure

  INTERFACE
    FUNCTION osqp_f2c_update_bounds( m, l_new, u_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_update_bounds
    INTEGER ( KIND = ip ), VALUE :: m
    REAL ( KIND = wp ), DIMENSION( m ) :: l_new, u_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_update_bounds
  END INTERFACE

!  update lower bound procedure

  INTERFACE
    FUNCTION osqp_f2c_update_lower_bound( m, l_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_update_lower_bound
    INTEGER ( KIND = ip ), VALUE :: m
    REAL ( KIND = wp ), DIMENSION( m ) :: l_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_update_lower_bound
  END INTERFACE

!  update upper bound procedure

  INTERFACE
    FUNCTION osqp_f2c_update_upper_bound( m, u_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_update_upper_bound
    INTEGER ( KIND = ip ), VALUE :: m
    REAL ( KIND = wp ), DIMENSION( m ) :: u_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_update_upper_bound
  END INTERFACE

!  warm start primal and dual variables procedure

  INTERFACE
    FUNCTION osqp_f2c_warm_start( m, n, x_new, y_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_warm_start
    INTEGER ( KIND = ip ), VALUE :: m, n
    REAL ( KIND = wp ), DIMENSION( n ) :: x_new
    REAL ( KIND = wp ), DIMENSION( m ) :: y_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_warm_start
  END INTERFACE

!  warm start primal variables procedure

  INTERFACE
    FUNCTION osqp_f2c_warm_start_x( n, x_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_warm_start_x
    INTEGER ( KIND = ip ), VALUE :: n
    REAL ( KIND = wp ), DIMENSION( n ) :: x_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_warm_start_x
  END INTERFACE

!  warm start primal variables procedure

  INTERFACE
    FUNCTION osqp_f2c_warm_start_y( m, y_new, c_work ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
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
    INTEGER ( KIND = ip ) :: osqp_f2c_warm_start_y
    INTEGER ( KIND = ip ), VALUE :: m
    REAL ( KIND = wp ), DIMENSION( m ) :: y_new
    TYPE ( C_PTR ) :: c_work
    END function osqp_f2c_warm_start_y
  END INTERFACE

!  cleanup procedure

  INTERFACE
    FUNCTION osqp_f2c_cleanup( c_settings, c_work, c_data ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef DLONG
    INTEGER, PARAMETER :: ip = c_long_long
#else
    INTEGER, PARAMETER :: ip = c_int
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_cleanup
    TYPE ( C_PTR ), VALUE :: c_settings
    TYPE ( C_PTR ), VALUE :: c_work
    TYPE ( C_PTR ), VALUE :: c_data
    END function osqp_f2c_cleanup
  END INTERFACE

CONTAINS

!  copy settings into solver data

  SUBROUTINE OSQP_settings( settings, data, status )
  TYPE( OSQP_settings_type ), INTENT( IN ) :: settings
  TYPE( OSQP_data_type ), INTENT( INOUT ) :: data
  INTEGER ( ip ), INTENT( OUT) :: status

!  copy the fortran solver settings into their C counterparts

  status = osqp_f2c_settings( settings, data%c_settings )
  RETURN
  END SUBROUTINE OSQP_settings

!  solve the given problem

  SUBROUTINE OSQP_solve( m, n, P_ptr, P_row, P_val, q, A_ptr, A_row, A_val, l, &
                         u, x, y, info, data, status )
  INTEGER ( KIND = ip ), INTENT( IN ) :: m, n
  INTEGER ( KIND = ip ), INTENT( IN ), DIMENSION( n + 1 ) :: P_ptr
  INTEGER ( KIND = ip ), INTENT( IN ), DIMENSION( P_ptr( n + 1 ) - 1  ) :: P_row
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( P_ptr( n + 1 ) - 1  ) :: P_val
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( n ) :: q
  INTEGER ( KIND = ip ), INTENT( IN ), DIMENSION( n + 1 ) :: A_ptr
  INTEGER ( KIND = ip ), INTENT( IN ), DIMENSION( A_ptr( n + 1 ) - 1  ) :: A_row
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( A_ptr( n + 1 ) - 1  ) :: A_val
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( m ) :: l
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( m ) :: u
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( n ) :: x
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( m ) :: y
  TYPE( OSQP_info_type ), INTENT( INOUT ) :: info
  TYPE( OSQP_data_type ), INTENT( INOUT ) :: data
  INTEGER ( ip ), INTENT( OUT) :: status

!  local variables

  INTEGER ( ip ) :: P_nnz, A_nnz
  P_nnz = P_ptr( n + 1 ) - 1
  A_nnz = A_ptr( n + 1 ) - 1

!  solve the problem provided

  status = osqp_f2c_solve( m, n, P_nnz, P_val, P_row, P_ptr, A_nnz, A_val,     &
                           A_row, A_ptr, q, l, u, x, y, info,                  &
                           data%c_settings, data%c_work, data%c_data )
  RETURN
  END SUBROUTINE OSQP_solve

!  resolve the given problem

  SUBROUTINE OSQP_resolve( m, n, x, y, info, data, status,                     &
                           q_new, l_new, u_new, x_new, y_new )
  INTEGER ( KIND = ip ), INTENT( IN ) :: m, n
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( n ) :: x
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( m ) :: y
  TYPE( OSQP_info_type ), INTENT( INOUT ) :: info
  TYPE( OSQP_data_type ), INTENT( INOUT ) :: data
  INTEGER ( ip ), INTENT( OUT) :: status
  REAL ( KIND = wp ), OPTIONAL, DIMENSION( n ) :: q_new
  REAL ( KIND = wp ), OPTIONAL, DIMENSION( m ) :: l_new
  REAL ( KIND = wp ), OPTIONAL, DIMENSION( m ) :: u_new
  REAL ( KIND = wp ), OPTIONAL, DIMENSION( n ) :: x_new
  REAL ( KIND = wp ), OPTIONAL, DIMENSION( m ) :: y_new

!  if required update the linear cost

  IF ( PRESENT( q_new ) ) THEN
    status = osqp_f2c_update_lin_cost( n, q_new, data%c_work )
    IF ( status /= 0 ) RETURN
  END IF

!  if required update one or both of the constraint bounds

  IF ( PRESENT( l_new ) .AND. PRESENT( u_new ) ) THEN
    status = osqp_f2c_update_bounds( m, l_new, u_new, data%c_work )
    IF ( status /= 0 ) RETURN
  ELSE IF ( PRESENT( l_new ) ) THEN
    status = osqp_f2c_update_lower_bound( m, l_new, data%c_work )
    IF ( status /= 0 ) RETURN
  ELSE IF ( PRESENT( u_new ) ) THEN
    status = osqp_f2c_update_upper_bound( m, u_new, data%c_work )
    IF ( status /= 0 ) RETURN
  END IF

!  if required choose new primal and/or dual starting point

  IF ( PRESENT( x_new ) .AND. PRESENT( y_new ) ) THEN
    status = osqp_f2c_warm_start( m, n, x_new, y_new, data%c_work )
    IF ( status /= 0 ) RETURN
  ELSE IF ( PRESENT( x_new ) ) THEN
    status = osqp_f2c_warm_start_x( n, x_new, data%c_work )
    IF ( status /= 0 ) RETURN
  ELSE IF ( PRESENT( y_new ) ) THEN
    status = osqp_f2c_warm_start_y( m, y_new, data%c_work )
    IF ( status /= 0 ) RETURN
  END IF

!  solve the problem provided

  status = osqp_f2c_resolve( m, n, x, y, info, data%c_work )
  RETURN
  END SUBROUTINE OSQP_resolve

!  clean up after solution

  SUBROUTINE OSQP_cleanup( data, status )
  TYPE( OSQP_data_type ), INTENT( INOUT ) :: data
  INTEGER ( ip ), INTENT( OUT) :: status

!  free outstanding pointers

  status = osqp_f2c_cleanup( data%c_settings, data%c_work, data%c_data )
  RETURN

  END SUBROUTINE OSQP_cleanup

END MODULE OSQP
