## Building ecWAM
ecwam is built via its bundle entry-point in `package/bundle/ecwam-bundle` and bundle config in `package/bundle/bundle.yml`. The arch files,
containing the relevant modules and env vars per system per compiler toolchain, are in `package/bundle/arch`. The default build is double
precision, to build with single precision we add the `--with-single-precision` bundle flag.

## Running ecWAM
Before running, the env.sh in the build-dir should be sourced to ensure the correct modules are loaded and paths set.
This has three steps:
1. preproc - ./bin/ecwam-run-preproc --run-dir=<path-to-rundir> --config=<test-config> (run serially)
   The config is one of the yml test configs defined in tests/
2. preset - ./bin/ecwam-run-preset --run-dir=<path-to-rundir> (run serially)
3. model - OMP_PLACES=cores ./bin/ecwan-run-model --run-dir=<path-to-rundir> --launch="ecwam-launch -np 4 -nt 32 --hint=nomultithread" (parallel on one full ECMWF AC node)

The ecwam_run_model script runs a validation test at the end of the run. This compares references values and hashes against computed norms in run-dir/logs/model/statistics.log
