# (C) Copyright 2020- ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

macro( ecwam_find_python_mods )
   set(FYPP_FOUND OFF)
   set(PYYAML_FOUND OFF)

   ecbuild_find_python()
   find_program( FYPP_PATH fypp REQUIRED QUIET)
   if( FYPP_PATH )
     ecbuild_info( "${ECWAM_PROJECT_NAME} FOUND fypp" )
     set(FYPP_FOUND ON)
   else()
     ecbuild_info( "${ECWAM_PROJECT_NAME} FAILED to find optional package fypp" )
   endif()
   ecbuild_find_package( fypp QUIET)

   execute_process(
       COMMAND python3 -c "import yaml"
       RESULT_VARIABLE EXIT_CODE
       OUTPUT_QUIET
   )
   
   if( EXIT_CODE EQUAL 0 )
     ecbuild_info("${ECWAM_PROJECT_NAME} FOUND pyyaml")
     set(PYYAML_FOUND ON)
   else()
     ecbuild_info( "${ECWAM_PROJECT_NAME} FAILED to find optional package pyyaml" )
   endif()
   ecbuild_find_package( pyyaml QUIET)
endmacro()
