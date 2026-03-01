####################################################################
# COMPILER
####################################################################

set( CMAKE_C_COMPILER nvc )
set( CMAKE_CXX_COMPILER nvc++ )
set( CMAKE_Fortran_COMPILER nvfortran )

####################################################################
# OpenMP FLAGS
####################################################################

set( OpenMP_C_FLAGS             "-mp -mp=bind,allcores,numa" )
set( OpenMP_CXX_FLAGS           "-mp -mp=bind,allcores,numa" )
set( OpenMP_Fortran_FLAGS       "-mp -mp=bind,allcores,numa" )

####################################################################
# OpenAcc FLAGS
####################################################################

set( OpenACC_Fortran_FLAGS "-acc=gpu -gpu=cc90,lineinfo,fastmath,rdc" )

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
  set(CMAKE_CUDA_ARCHITECTURES 90)
endif()

####################################################################
# COMMON FLAGS
####################################################################

set( ECBUILD_Fortran_FLAGS "-Mframe" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mbyteswapio" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mstack_arrays" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mrecursive" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Kieee" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mdaz" )

# Necessary when CUDA math libs are installed in a different location to cudart
set( CMAKE_EXE_LINKER_FLAGS "-L/$ENV{NVHPC_ROOT}/math_libs/13.0/lib64" )
set( CMAKE_SHARED_LINKER_FLAGS "-L/$ENV{NVHPC_ROOT}/math_libs/13.0/lib64" )
