! OSQP V0.6 -> V1.0 upgrade (2026-07-11)

#include "osqp_configure.h"

MODULE OSQP

  USE iso_c_binding
  USE OSQP_types
  IMPLICIT NONE

  PRIVATE
  PUBLIC :: OSQP_settings_type, OSQP_info_type, OSQP_data_type,                &
            OSQP_solve, OSQP_resolve, OSQP_settings, OSQP_cleanup

!  integer and real precisions as defined during osqp installation

#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif

#ifdef OSQP_USE_FLOAT
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
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_settings
    TYPE ( OSQP_settings_type ) :: settings
    TYPE ( C_PTR ) :: c_settings
    END FUNCTION osqp_f2c_settings
  END INTERFACE

!  solve procedure

  INTERFACE
    FUNCTION osqp_f2c_solve( c_solver, n, m, P_nnz, P_val, P_row, P_ptr,       &
                             A_nnz, A_val, A_row, A_ptr, q, l, u, x, y,        &
                             c_settings, info ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
#ifdef OSQP_USE_FLOAT
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
    TYPE ( C_PTR ) :: c_solver
    END FUNCTION osqp_f2c_solve
  END INTERFACE

!  resolve procedure

  INTERFACE
    FUNCTION osqp_f2c_resolve( c_solver, n, m, x, y, info ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
#ifdef OSQP_USE_FLOAT
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
    TYPE ( C_PTR ) :: c_solver
    END FUNCTION osqp_f2c_resolve
  END INTERFACE

!  update linear cost and lower and upper bounds procedure

  INTERFACE
    FUNCTION osqp_f2c_update_data_vec( c_solver, n, m,                         &
                                       q_new, l_new, u_new ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
#ifdef OSQP_USE_FLOAT
    INTEGER, PARAMETER :: wp = c_float
#else
    INTEGER, PARAMETER :: wp = c_double
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_update_data_vec
    TYPE ( C_PTR ) :: c_solver
    INTEGER ( KIND = ip ), VALUE :: n, m
    REAL ( KIND = wp ), OPTIONAL, DIMENSION( n ) :: q_new
    REAL ( KIND = wp ), OPTIONAL, DIMENSION( m ) :: l_new, u_new
    END FUNCTION osqp_f2c_update_data_vec
  END INTERFACE

!  warm start primal and dual variables procedure

  INTERFACE
    FUNCTION osqp_f2c_warm_start( c_solver, n, m, x_new, y_new ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
#ifdef OSQP_USE_FLOAT
    INTEGER, PARAMETER :: wp = c_float
#else
    INTEGER, PARAMETER :: wp = c_double
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_warm_start
    INTEGER ( KIND = ip ), VALUE :: n, m
    TYPE ( C_PTR ) :: c_solver
    REAL ( KIND = wp ), OPTIONAL, DIMENSION( n ) :: x_new
    REAL ( KIND = wp ), OPTIONAL, DIMENSION( m ) :: y_new
    END FUNCTION osqp_f2c_warm_start
  END INTERFACE

!  cleanup procedure

  INTERFACE
    FUNCTION osqp_f2c_cleanup( c_solver, c_settings ) BIND( C )
    USE iso_c_binding
    USE OSQP_types
#ifdef OSQP_USE_LONG
    INTEGER, PARAMETER :: ip = c_int64_t
#else
    INTEGER, PARAMETER :: ip = c_int32_t
#endif
    INTEGER ( KIND = ip ) :: osqp_f2c_cleanup
    TYPE ( C_PTR ), VALUE :: c_settings
    TYPE ( C_PTR ), VALUE :: c_solver
    END FUNCTION osqp_f2c_cleanup
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

  SUBROUTINE OSQP_solve( n, m, P_ptr, P_row, P_val, q, A_ptr, A_row, A_val,    &
                         l, u, x, y, info, data, status )
  INTEGER ( KIND = ip ), INTENT( IN ) :: n, m
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

  status = osqp_f2c_solve( data%c_solver, n, m, P_nnz, P_val, P_row, P_ptr,    &
                           A_nnz, A_val, A_row, A_ptr, q, l, u, x, y,          &
                           data%c_settings, info )

  RETURN
  END SUBROUTINE OSQP_solve

!  resolve the given problem

  SUBROUTINE OSQP_resolve( n, m, x, y, info, data, status,                     &
                           q_new, l_new, u_new, x_new, y_new )
  INTEGER ( KIND = ip ), INTENT( IN ) :: n, m
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

!  if required update the linear cost and  one or both of the constraint bounds

  status = osqp_f2c_update_data_vec( data%c_solver, n, m,                      &
                                     q_new, l_new, u_new )
  IF ( status /= 0 ) RETURN

!  if required choose new primal and/or dual starting point

  status = osqp_f2c_warm_start( data%c_solver, n, m, x_new, y_new )
  IF ( status /= 0 ) RETURN

!  solve the problem provided

  status = osqp_f2c_resolve( data%c_solver, n, m, x, y, info )
  RETURN
  END SUBROUTINE OSQP_resolve

!  clean up after solution

  SUBROUTINE OSQP_cleanup( data, status )
  TYPE( OSQP_data_type ), INTENT( INOUT ) :: data
  INTEGER ( ip ), INTENT( OUT) :: status

!  free outstanding pointers

  status = osqp_f2c_cleanup( data%c_solver, data%c_settings )
  RETURN

  END SUBROUTINE OSQP_cleanup

END MODULE OSQP
