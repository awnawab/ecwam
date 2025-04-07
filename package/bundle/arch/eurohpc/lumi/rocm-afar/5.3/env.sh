# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

# Source me to get the correct configure/build/run environment

# Store tracing and disable (module is *way* too verbose)
{ tracing_=${-//[^x]/}; set +x; } 2>/dev/null

module_load() {
  echo "+ module load $1"
  module load $1
}
module_unload() {
  echo "+ module unload $1"
  module unload $1
}

# Unload to be certain
module reset

# Load modules
module_load LUMI/24.03
module_load partition/G
module_load PrgEnv-cray/8.4.0
module_load cray-mpich/8.1.29
module_load craype-network-ofi
module_load buildtools/24.03
module_load cray-python/3.10.10
module_load libaec/1.0.6-cpeCray-24.03

### Handling of "magic" cray modules
# 1) Load the cray modules
module_load cray-hdf5/1.12.2.11
# 2) Store variables to locate the packages
_HDF5_ROOT=${CRAY_HDF5_PREFIX}
# 3) Unload the cray modules in reverse order, removing all the magic
module_unload cray-hdf5
# 4) Define variables that CMake introspects
export HDF5_ROOT=${_HDF5_ROOT}

LD_LIBRARY_PATH=/users/nawabahm/rocm-afar-7110-drop-5.3.0/lib:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=/users/nawabahm/rocm-afar-7110-drop-5.3.0/bin:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export PATH=/users/nawabahm/rocm-afar-7110-drop-5.3.0/lib/llvm/bin:/users/nawabahm/rocm-afar-7110-drop-5.3.0/bin:$PATH
export hipfort_ROOT=/users/nawabahm/hipfort/install

# Export environment variable3s
export MPI_HOME=${MPICH_DIR}

export CC=amdclang CXX=amdclang++ FC=amdflang

module list

set -x

# Restore tracing to stored setting
{ if [[ -n "$tracing_" ]]; then set -x; else set +x; fi } 2>/dev/null

path=$BASH_SOURCE
DIR_PATH=$(dirname $path)
export ECBUILD_TOOLCHAIN=$DIR_PATH/toolchain.cmake
