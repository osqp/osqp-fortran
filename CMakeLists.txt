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

# Is the code generated for embedded platforms?
#   1 :   Yes. Matrix update not allowed.
#   2 :   Yes. Matrix update allowed.
if (NOT DEFINED EMBEDDED)
    message(STATUS "Embedded is OFF")
else()
    message(STATUS "Embedded is ${EMBEDDED}")
endif()

# Is printing enabled?
option (PRINTING "Enable solver printing" ON)
if (DEFINED EMBEDDED)
    message(STATUS "Disabling printing for embedded")
    set(PRINTING OFF)
endif()
message(STATUS "Printing is ${PRINTING}")

option (PROFILING "Enable solver profiling (timing)" ON)
if (DEFINED EMBEDDED)
    message(STATUS "Disabling profiling for embedded")
    set(PROFILING OFF)
endif()
message(STATUS "Profiling is ${PROFILING}")

# Is user interrupt enabled?
option (CTRLC "Enable user interrupt (Ctrl-C)" ON)
if (DEFINED EMBEDDED)
    message(STATUS "Disabling user interrupt for embedded")
    set(CTRLC OFF)
endif()
message(STATUS "User interrupt is ${CTRLC}")

# Use floats instead of integers
option (DFLOAT "Use float numbers instead of doubles" OFF)
message(STATUS "Floats are ${DFLOAT}")

# Use long integers for indexing
option (DLONG "Use long integers (64bit) for indexing" ON)
if (NOT (CMAKE_SIZEOF_VOID_P EQUAL 8))
	message(STATUS "Disabling long integers (64bit) on 32bit machine")
	set(DLONG OFF)
endif()
message(STATUS "Long integers (64bit) are ${DLONG}")

# Add code coverage
option (COVERAGE "Perform code coverage" OFF)
message(STATUS "Code coverage is ${COVERAGE}")

# Fortran interface option
option (FORTRAN "Build Fortran interface" ON)
message(STATUS "Fortran interface build: ${FORTRAN}")

# Disable C Unittests
option (UNITTESTS "Enable C unittests generation" OFF)

# Detect operating system
# ----------------------------------------------
message(STATUS "We are on a ${CMAKE_SYSTEM_NAME} system")
if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(IS_LINUX ON)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    set(IS_MAC ON)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    set(IS_WINDOWS ON)
endif()

# Linear solvers dependencies
# ---------------------------------------------
option (ENABLE_MKL_PARDISO "Enable MKL Pardiso solver" ON)
message(STATUS "MKL Pardiso: ${ENABLE_MKL_PARDISO}")

# --------------------------------------------------------------------------
# Generate configure file for constants
configure_file(${PROJECT_SOURCE_DIR}/configure/glob_optsf.h.in
               ${PROJECT_SOURCE_DIR}/src/glob_optsf.h)


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
	       
# Add test executable
add_executable(osqp_demo_fortran ${CMAKE_CURRENT_SOURCE_DIR}/demo/osqp_demo_fortran.F90)
target_link_libraries(osqp_demo_fortran osqpf)
