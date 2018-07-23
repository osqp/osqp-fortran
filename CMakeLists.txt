cmake_minimum_required(VERSION 3.2)


# Project name
project (osqp-fortran)

# Fortran interface compilation
enable_language(Fortran)

# Set the output folder where your program will be created
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/out)
set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/out)

# Set options
# ----------------------------------------------
message(STATUS "Fortran interface configuration -----")

# Fortran interface option
option (FORTRAN "Build Fortran interface" ON)
message(STATUS "Fortran interface build: ${FORTRAN}")

# ----------------------------------------------

# Add useful libraries
set(CMAKE_FORTRAN_STANDARD_LIBRARIES "${CMAKE_FORTRAN_STANDARD_LIBRARIES} -lm -ldl")      # Include math

# Include this directory for library handler
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

# Include OSQP sources
message(STATUS "OSQP sources configuration -----")
add_subdirectory(osqp_sources EXCLUDE_FROM_ALL)

# Add shared Fortran library
add_library(osqpf SHARED
	${CMAKE_CURRENT_SOURCE_DIR}/src/osqp_f2c.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/osqpf_types.F90
	${CMAKE_CURRENT_SOURCE_DIR}/src/osqpf.F90)
target_link_libraries(osqpf osqp)

# Force osqplib to be in the same output directory as this project
# This is needed in Windows because it is too stupid to look for shared
# libraries in other folders
set_target_properties(osqp
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/out"
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/out"
)

# Add test executable
add_executable(osqp_demo_fortran ${CMAKE_CURRENT_SOURCE_DIR}/demo/osqp_demo_fortran.F90)
target_link_libraries(osqp_demo_fortran osqpf)
