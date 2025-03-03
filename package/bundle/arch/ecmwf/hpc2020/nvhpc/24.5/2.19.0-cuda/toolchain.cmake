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

set( OpenACC_Fortran_FLAGS "-acc=gpu -gpu=gvmode,lineinfo,fastmath,rdc" )

####################################################################
# COMMON FLAGS
####################################################################

set( ECBUILD_Fortran_FLAGS "-fpic" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mframe" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mbyteswapio" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mstack_arrays" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mrecursive" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Ktrap=fp" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Kieee" )
set( ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Mdaz" )

set( ECBUILD_Fortran_FLAGS_BIT "-O2 -gopt" )

set( ECBUILD_C_FLAGS "-O2 -gopt -traceback" )

set( ECBUILD_CXX_FLAGS "-O2 -gopt" )
