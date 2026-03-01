# Source me to get the correct configure/build/run environment

# Store tracing and disable (module is *way* too verbose)
{ tracing_=${-//[^x]/}; set +x; } 2>/dev/null

module_load() {
  echo "+ module load $*"
  module load $*
}
module_unload() {
  echo "+ module unload $*"
  module unload $*
}
module_purge() {
  echo "+ module purge"
  module purge
}

# Unload all modules to be certain
[[ ${IFS_RUNTIME_ENV:-unset} == "unset" ]] && module_purge

# Load modules
module_load prgenv/expert
module_load nvidia/25.9
module_load hpcx-openmpi/2.21.3-cuda:nvidia:25.9
module_load openblas
# Don't load these modules if env.sh is used as part of the IFS runtime environment - only the modules above are required
if [[ ${IFS_RUNTIME_ENV:-unset} == "unset" ]]; then
  module_load python3/3.12.9-01
  module_load cmake/3.31.6
  module_load ninja
  module_load aec/1.1.3
fi

export FC=nvfortran
export CC=nvc
export CXX=nvc++

# MKL envs
export MKL_CBWR=AUTO,STRICT
# export MKL_NUM_THREADS=1
# export MKL_DYNAMIC=FALSE # Using capital letters
# export MKL_VERBOSE=${MKL_VERBOSE:-0} # if eq to 1, then each MKL func call as we go along will be output to ifs.out (stdout)
# export KMP_DETERMINISTIC_REDUCTION=true

# Record the RPATH in the executable
export LD_RUN_PATH=$LD_LIBRARY_PATH

# Increase stack size to maximum
ulimit -S -s unlimited
ulimit -S -l unlimited

# Restore tracing to stored setting
{ if [[ -n "$tracing_" ]]; then set -x; else set +x; fi } 2>/dev/null

export ECBUILD_TOOLCHAIN="./toolchain.cmake"
