/* OSQP V0.6 -> V1.0 upgrade (2026-07-11) */

#include "osqp.h"
#include "auxil.h"
#include <stdio.h>
#include "printing.h"

/* Settings struct (see osqp documentation) */

typedef struct {
    OSQPInt device;
    OSQPInt linsys_solver;
    OSQPInt allocate_solution;
    OSQPInt verbose;
    OSQPInt profiler_level;
    OSQPInt warm_starting;
    OSQPInt scaling;
    OSQPInt polishing;
    OSQPFloat rho;
    OSQPInt rho_is_vec;
    OSQPFloat sigma;
    OSQPFloat alpha;
    OSQPInt cg_max_iter;
    OSQPInt cg_tol_reduction;
    OSQPFloat cg_tol_fraction;
    OSQPInt cg_precond;
    OSQPInt adaptive_rho;
    OSQPInt adaptive_rho_interval;
    OSQPFloat adaptive_rho_fraction;
    OSQPFloat adaptive_rho_tolerance;
    OSQPInt max_iter;
    OSQPFloat eps_abs;
    OSQPFloat eps_rel;
    OSQPFloat eps_prim_inf;
    OSQPFloat eps_dual_inf;
    OSQPInt scaled_termination;
    OSQPInt check_termination;
    OSQPInt check_dualgap;
    OSQPFloat time_limit;
    OSQPFloat delta;
    OSQPInt polish_refine_iter;
} OSQPFSettings;

/* Solver return information  (see osqp documentation) */

typedef struct {
    char status[32];
    OSQPInt status_val;
    OSQPInt status_polish;
    OSQPFloat obj_val;
    OSQPFloat dual_obj_val;
    OSQPFloat prim_res;
    OSQPFloat dual_res;
    OSQPFloat duality_gap;
    OSQPInt iter;
    OSQPInt rho_updates;
    OSQPFloat rho_estimate;
    OSQPFloat setup_time;
    OSQPFloat solve_time;
    OSQPFloat update_time;
    OSQPFloat polish_time;
    OSQPFloat run_time;
    OSQPFloat primdual_int;
    OSQPFloat rel_kkt_error;
} OSQPFInfo;

/* interface to settings */

OSQPInt osqp_f2c_settings( OSQPFSettings *f_settings, OSQPSettings **settings ){

    // allocate space for c settings

    *settings = OSQPSettings_new();
    OSQPSettings *star_settings = *settings;
    star_settings->device = f_settings->device;
    star_settings->linsys_solver = f_settings->linsys_solver;
    star_settings->allocate_solution = f_settings->allocate_solution;
    star_settings->verbose = f_settings->verbose;
    star_settings->profiler_level = f_settings->profiler_level;
    star_settings->warm_starting = f_settings->warm_starting;
    star_settings->scaling = f_settings->scaling;
    star_settings->polishing = f_settings->polishing;
    star_settings->rho = f_settings->rho;
    star_settings->rho_is_vec = f_settings->rho_is_vec;
    star_settings->sigma = f_settings->sigma;
    star_settings->alpha = f_settings->alpha;
    star_settings->cg_max_iter = f_settings->cg_max_iter;
    star_settings->cg_tol_reduction = f_settings->cg_tol_reduction;
    star_settings->cg_tol_fraction = f_settings->cg_tol_fraction;
    star_settings->cg_precond = f_settings->cg_precond;
    star_settings->adaptive_rho = f_settings->adaptive_rho;
    star_settings->adaptive_rho_interval = f_settings->adaptive_rho_interval;
    star_settings->adaptive_rho_fraction = f_settings->adaptive_rho_fraction;
    star_settings->adaptive_rho_tolerance = f_settings->adaptive_rho_tolerance;
    star_settings->max_iter = f_settings->max_iter;
    star_settings->eps_abs = f_settings->eps_abs;
    star_settings->eps_rel = f_settings->eps_rel;
    star_settings->eps_prim_inf = f_settings->eps_prim_inf;
    star_settings->eps_dual_inf = f_settings->eps_dual_inf;
    star_settings->scaled_termination = f_settings->scaled_termination;
    star_settings->check_termination = f_settings->check_termination;
    star_settings->check_dualgap = f_settings->check_dualgap;
    star_settings->time_limit = f_settings->time_limit;
    star_settings->delta = f_settings->delta;
    star_settings->polish_refine_iter = f_settings->polish_refine_iter;
    return 0 ;
}

/* interface to solver */

OSQPInt osqp_f2c_solve( OSQPSolver **solver, OSQPInt n, OSQPInt m,
                        OSQPInt P_nnz, OSQPFloat *P_val, 
                        OSQPInt *P_row, OSQPInt *P_ptr,
                        OSQPInt A_nnz, OSQPFloat *A_val, 
                        OSQPInt *A_row, OSQPInt *A_ptr,
                        OSQPFloat *q, OSQPFloat *l, OSQPFloat *u,
                        OSQPFloat *x, OSQPFloat *y, 
                        OSQPSettings *settings, OSQPFInfo *f_info ){

    OSQPInt i, exitflag, osqp_status;

    // Move from fortran to c indexing

    for (i = 0 ; i < n+1 ; i++) {
      P_ptr[i] = P_ptr[i]-1;
    }

    for (i = 0 ; i < P_nnz ; i++) {
      P_row[i] = P_row[i]-1;
    }

    for (i = 0 ; i < n+1 ; i++) {
      A_ptr[i] = A_ptr[i]-1;
    }

    for (i = 0 ; i < A_nnz ; i++) {
      A_row[i] = A_row[i]-1;
    }

    // Populate data

    OSQPCscMatrix* P = OSQPCscMatrix_new(n, n,
                              P_nnz, P_val, P_row, P_ptr);
    OSQPCscMatrix* A = OSQPCscMatrix_new(m, n,
                              A_nnz, A_val, A_row, A_ptr);

  /*
    OSQPInt cap = osqp_capabilities();

    printf("This OSQP library supports:\n");
    if(cap & OSQP_CAPABILITY_DIRECT_SOLVER) {
      printf("    A direct linear algebra solver\n");
    }
    if(cap & OSQP_CAPABILITY_INDIRECT_SOLVER) {
      printf("    An indirect linear algebra solver\n");
    }
    if(cap & OSQP_CAPABILITY_CODEGEN) {
      printf("    Code generation\n");
    }
    if(cap & OSQP_CAPABILITY_DERIVATIVES) {
      printf("    Derivatives calculation\n");
    }
    printf("\n");
   */ 

   /* Setup solver */
    *solver = NULL;
   exitflag = osqp_setup(solver, P, q, A, l, u, m, n, settings);

  /* Solve problem */

   OSQPSolver *star_solver = *solver;
  if (!exitflag) osqp_status = osqp_solve(star_solver);

    if (osqp_status) {
      /*     printf( "osqp_status %7d\n", osqp_status ); */
        exit(osqp_status);
    }

    // Record solution and dual variables

    for (i = 0 ; i < n ; i++) {
      x[i] = star_solver->solution->x[i];
    }

    for (i = 0 ; i < m ; i++) {
      y[i] = star_solver->solution->y[i];
    }

    // Record remaining output information

    /*     printf( "osqp_status %7d\n", osqp_status ); */

    update_status( (OSQPInfo *)f_info, star_solver->info->status_val );
    f_info->iter = star_solver->info->iter;
    f_info->status_val = star_solver->info->status_val;
#ifndef OSQP_EMBEDDED_MODE
    f_info->status_polish = star_solver->info->status_polish;
#endif
    f_info->obj_val = star_solver->info->obj_val;
    f_info->dual_obj_val = star_solver->info->dual_obj_val;
    f_info->prim_res = star_solver->info->prim_res;
    f_info->dual_res = star_solver->info->dual_res;
    f_info->duality_gap = star_solver->info->duality_gap;
#ifdef OSQP_ENABLE_PROFILING
    f_info->setup_time = star_solver->info->setup_time;
    f_info->solve_time = star_solver->info->solve_time;
    f_info->update_time = star_solver->info->update_time;
    f_info->polish_time = star_solver->info->polish_time;
    f_info->run_time = star_solver->info->run_time;
#endif
#if OSQP_EMBEDDED_MODE != 1
    f_info->rho_updates = star_solver->info->rho_updates;
    f_info->rho_estimate = star_solver->info->rho_estimate;
    f_info->primdual_int = star_solver->info->primdual_int;
    f_info->rel_kkt_error = star_solver->info->rel_kkt_error;
#endif

    // Restore fortran indexing

    for (i = 0 ; i < n+1 ; i++) {
      P_ptr[i] = P_ptr[i]+1;
    }

    for (i = 0 ; i < P_nnz ; i++) {
      P_row[i] = P_row[i]+1;
    }

    for (i = 0 ; i < n+1 ; i++) {
      A_ptr[i] = A_ptr[i]+1;
    }

    for (i = 0 ; i < A_nnz ; i++) {
      A_row[i] = A_row[i]+1;
    }

    // cleanup A and P

    OSQPCscMatrix_free(A);
    OSQPCscMatrix_free(P);

    /*    return f_info->status_val ;*/
    return 0 ;
}

/* interface to cleanup */

OSQPInt osqp_f2c_cleanup( OSQPSolver *solver, OSQPSettings *settings ){

    // Cleanup

    osqp_cleanup(solver);
    OSQPSettings_free(settings);

    return 0 ;
}

/* interface to update data vectors */

OSQPInt osqp_f2c_update_data_vec( OSQPSolver **solver, OSQPInt n, OSQPInt m, 
                                  OSQPFloat *q_new, OSQPFloat *l_new, OSQPFloat *u_new ){

     OSQPInt osqp_status;

    // recall solver data

    OSQPSolver *star_solver = *solver;

    // update data vectors

    osqp_status = osqp_update_data_vec( star_solver, q_new, l_new, u_new ) ;

    if (osqp_status) {
      /*     printf( "osqp_status %7d\n", osqp_status ); */
        exit(osqp_status);
    }

    return 0 ;
}

/* interface to warm start primal and dual variables */

OSQPInt osqp_f2c_warm_start( OSQPSolver **solver, OSQPInt n, OSQPInt m, 
                             OSQPFloat *x_new, OSQPFloat *y_new ){

     OSQPInt osqp_status;

    // recall solver data

    OSQPSolver *star_solver = *solver;

    // update bounds

    osqp_status = osqp_warm_start( star_solver, x_new, y_new ) ;

    if (osqp_status) {
      /*     printf( "osqp_status %7d\n", osqp_status ); */
        exit(osqp_status);
    }

    return 0 ;
}

/* interface to resolver */

OSQPInt osqp_f2c_resolve( OSQPSolver **solver, OSQPInt n, OSQPInt m, 
                          OSQPFloat *x, OSQPFloat *y, OSQPFInfo *f_info ){

    OSQPInt i, osqp_status;

    // recall solver data

    OSQPSolver *star_solver = *solver;

    // Solve Problem

    osqp_status = osqp_solve(star_solver);

    if (osqp_status) {
      /*     printf( "osqp_status %7d\n", osqp_status ); */
        exit(osqp_status);
    }

    // Record solution and dual variables

    for (i = 0 ; i < n ; i++) {
      x[i] = star_solver->solution->x[i];
    }

    for (i = 0 ; i < m ; i++) {
      y[i] = star_solver->solution->y[i];
    }

    // Record remaining output information

    update_status( (OSQPInfo *)f_info, star_solver->info->status_val );
    f_info->iter = star_solver->info->iter;
    f_info->status_val = star_solver->info->status_val;
#ifndef OSQP_EMBEDDED_MODE
    f_info->status_polish = star_solver->info->status_polish;
#endif
    f_info->obj_val = star_solver->info->obj_val;
    f_info->dual_obj_val = star_solver->info->dual_obj_val;
    f_info->prim_res = star_solver->info->prim_res;
    f_info->dual_res = star_solver->info->dual_res;
    f_info->duality_gap = star_solver->info->duality_gap;
#ifdef OSQP_ENABLE_PROFILING
    f_info->setup_time = star_solver->info->setup_time;
    f_info->solve_time = star_solver->info->solve_time;
    f_info->update_time = star_solver->info->update_time;
    f_info->polish_time = star_solver->info->polish_time;
    f_info->run_time = star_solver->info->run_time;
#endif
#if OSQP_EMBEDDED_MODE != 1
    f_info->rho_updates = star_solver->info->rho_updates;
    f_info->rho_estimate = star_solver->info->rho_estimate;
    f_info->primdual_int = star_solver->info->primdual_int;
    f_info->rel_kkt_error = star_solver->info->rel_kkt_error;
#endif

    /*    return f_info->status_val ;*/
    return 0 ;
}




















