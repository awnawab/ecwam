# (C) Copyright 2022- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

if( NOT ${CMAKE_CURRENT_SOURCE_DIR} MATCHES "ecwam/src/ecwam$" )

   # Only set project-wide flags when called from top-level CMakeLists.txt

   # Capture ecbuild flags set by a toolchain
   set( ${PNAME}_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} " )
   set( ${PNAME}_Fortran_FLAGS_BIT "${ECBUILD_Fortran_FLAGS_BIT} " )
   set( ${PNAME}_Fortran_FLAGS_DEBUG "${ECBUILD_Fortran_FLAGS_DEBUG} " )
   
   if(CMAKE_Fortran_COMPILER_ID MATCHES "Cray")
     set(autopromote_flags   "-sreal64")
     set(checkbounds_flags   "-Rb")
     set(fpe_flags           "-Ktrap=fp")
     set(initsnan_flags      "-ei")
   
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
     set(autopromote_flags   "-fdefault-real-8 -fdefault-double-8")
     set(checkbounds_flags   "-fcheck=bounds")
     set(fpe_flags           "-ffpe-trap=invalid,zero,overflow")
     set(initsnan_flags      "-finit-real=snan")
     set(optimization_flags  "-O2")
   
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
     set(autopromote_flags   "-real-size 64")
     set(checkbounds_flags   "-check bounds")
     set(initsnan_flags      "-init=snan")
     set(fpe_flags           "-fpe0")
     set(vectorization_flags "-march=core-avx2 -no-fma")
     set(fpmodel_flags       "-fp-model precise -fp-speculation=safe")
     set(transcendentals_flags "-fast-transcendentals")
     set(heap_arrays_flags   "-heap-arrays 32")
     set(optimization_flags  "-O2")
   
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "PGI|NVHPC")
     set(autopromote_flags   "-r8")
     set(fpe_flags           "-Ktrap=fp")
     set(vectorization_flags "-O3 -fast")
     string(REPLACE "-O2" "" ${PNAME}_Fortran_FLAGS_BIT ${${PNAME}_Fortran_FLAGS_BIT})
     set(checkbounds_flags   "-Mbounds")
   
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Flang")
     set(autopromote_flags   "-fdefault-real-8")
     set(fpe_flags           "-ffp-exception-behavior=strict")
   
   endif()
   
   ecbuild_add_fortran_flags( "-g -O0"   NAME base_debug BUILD DEBUG)
   if( NOT HAVE_SINGLE_PRECISION )
     ecbuild_add_fortran_flags( "${autopromote_flags}"   NAME autopromote )
   endif()
   if( DEFINED optimization_flags )
     ecbuild_add_fortran_flags( "${optimization_flags}"   NAME optimization BUILD BIT)
   endif()
   if( DEFINED vectorization_flags )
     # vectorization flags must be per-sourcefile overrideable, so are set via ${PNAME}_Fortran_FLAGS
     set( ${PNAME}_Fortran_FLAGS_BIT "${${PNAME}_Fortran_FLAGS_BIT} ${vectorization_flags}" )
   endif()
   if( DEFINED fpmodel_flags )
     ecbuild_add_fortran_flags( "${fpmodel_flags}"   NAME fpmodel BUILD BIT)
   endif()
   if( DEFINED transcendentals_flags )
     ecbuild_add_fortran_flags( "${transcendentals_flags}"   NAME transcendentals BUILD BIT)
   endif()
   if( DEFINED heap_arrays_flags )
     ecbuild_add_fortran_flags( "${heap_arrays_flags}"   NAME heap_arrays )
   endif()
   
   if( CMAKE_BUILD_TYPE MATCHES "Debug" )
     foreach( debug_flag    fpe initsnan checkbounds )
       if( ${debug_flag}_flags )
         set( ${PNAME}_Fortran_FLAGS_DEBUG "${${PNAME}_Fortran_FLAGS_DEBUG} ${${debug_flag}_flags}" )
       endif()
     endforeach()
     if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
       # In case '-check all' has been added, we need to remove the '-check arg_temp_created' warnings
       set( ${PNAME}_Fortran_FLAGS_DEBUG "${${PNAME}_Fortran_FLAGS_DEBUG} -check noarg_temp_created" )
     endif()
   endif()
   
   if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
     if( NOT CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 10 )
       ecbuild_add_fortran_flags( "-fallow-argument-mismatch" NAME argument_mismatch )
     endif()
     if( NOT CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "aarch64" )
       ecbuild_add_fortran_flags( "-m64" NAME gnu_arch )
     endif()
     if( LOKI_MODE MATCHES "idem-stack|scc-stack" AND HAVE_LOKI )
       ecbuild_add_fortran_flags( "-fcray-pointer" NAME cray_pointer )
     endif()
   endif()
   
   if(CMAKE_Fortran_COMPILER_ID MATCHES "Flang")
     # Linker complains of unknown arguments:
     #    warning: argument unused during compilation: '-fdefault-real-8' [-Wunused-command-line-argument]
     foreach( LINKER_FLAGS CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS CMAKE_STATIC_LINKER_FLAGS )
       set( ${LINKER_FLAGS} "${${LINKER_FLAGS}} -Wno-unused-command-line-argument")
     endforeach()
   endif()

else()
   ####=============== Source file specific flags ===============####
   
   ### The file mubuf.F90, which is only used for "preproc" is sensitive to optimisations
   #   possibly leading to different wam_grid_<1,2,3> files.
   #   This in turn leads to non-neglibible differences
   #   of average 'swh' when running "chief".
   
   if( CMAKE_Fortran_COMPILER_ID MATCHES Intel )
     set_source_files_properties( mubuf.F90 PROPERTIES COMPILE_OPTIONS "-fp-model;strict" )
     set_source_files_properties( propconnect.F90 PROPERTIES COMPILE_OPTIONS "-fp-model;strict" )
   elseif( CMAKE_Fortran_COMPILER_ID MATCHES GNU )
     set_source_files_properties( mubuf.F90 PROPERTIES COMPILE_OPTIONS "-ffp-contract=off" )
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "PGI|NVHPC" AND CMAKE_BUILD_TYPE MATCHES "Bit")
     set_source_files_properties(
         sbottom.F90 PROPERTIES OVERRIDE_COMPILE_FLAGS " -g -O1 -Mflushz -Mno-signed-zeros "
     )
     set_source_files_properties( mubuf.F90 PROPERTIES COMPILE_OPTIONS "-Mnofma" )
     if( HAVE_SINGLE_PRECISION )
        set_source_files_properties( aki.F90 PROPERTIES OVERRIDE_COMPILE_FLAGS " -g -O1 -Mflushz -Mno-signed-zeros " )
        set_source_files_properties( kurtosis.F90 PROPERTIES OVERRIDE_COMPILE_FLAGS " -g -O1 -Mflushz -Mno-signed-zeros " )
        set_source_files_properties( stat_nl.F90 PROPERTIES OVERRIDE_COMPILE_FLAGS " -g -O1 -Mflushz -Mno-signed-zeros " )
        set_source_files_properties( transf_bfi.F90 PROPERTIES OVERRIDE_COMPILE_FLAGS " -g -O1 -Mflushz -Mno-signed-zeros " )
     endif()
   elseif(CMAKE_Fortran_COMPILER_ID MATCHES "PGI|NVHPC" AND CMAKE_BUILD_TYPE MATCHES "Debug")
     string(REPLACE "-Ktrap=fp" "" ${PNAME}_Fortran_FLAGS_DEBUG ${${PNAME}_Fortran_FLAGS_DEBUG})
     set_source_files_properties( outbeta.F90 PROPERTIES COMPILE_OPTIONS "${${PNAME}_Fortran_FLAGS_DEBUG} -Ktrap=divz")
     set_source_files_properties( secondhh.F90 PROPERTIES COMPILE_OPTIONS "${${PNAME}_Fortran_FLAGS_DEBUG} -Ktrap=inv,ovf")
   endif()
   
   ### The file grib2wgrid.F90 is sensitive to optimizations in single precision builds.
   #   This leads to non-neglibible differences
   #   of average 'swh' when running "chief".
   
   if( CMAKE_Fortran_COMPILER_ID MATCHES Intel AND HAVE_SINGLE_PRECISION )
     set_source_files_properties( grib2wgrid.F90 PROPERTIES COMPILE_OPTIONS "-fp-model;strict" )
   endif()
endif()

