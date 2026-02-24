PASC 26 mini-symposium guidelines
-------

The following contains some guidelines for building, running and post-processing ecWAM.


## Building

Bundle builds are the recommended way to build ecWAM. This comprises of two main steps:

1. create - clone all of ecWAM's dependencies
```console
./package/bundle/ecwam-bundle create --bundle bundle.yaml
```

[optional
For building on offline systems, we must also prefetch all python dependencies
```console
./package/bundle/ecwam-bundle populate
```
]

2. build - build ecWAM together with all of its dependencies

A baseline CPU build can be performed as follows:
```console
./package/bundle/ecwam-bundle build -j <n-threads> --arch <arch-file, e.g. package/bundle/arch/ecmwf/hpc2020/default> --with-fckit [--build-type=<CMAKE_BUILD_TYPE, default: Bit>] [--ninja] [--clean] [--with-single-precision]
```

For building on Nvidia GPUs, the following flags must be added:
```console
--with-acc --with-cuda --with-loki --with-gpu-aware-mpi --with-static-linking
```

## Running ecWAM

Three tests configs are provided in the current ecWAM benchmark:
1. etopo1_oper_an_fc_O48.yml - unit test.
2. etopo1_oper_an_fc_O320.yml - quarter of operational resolution, ~ 36km, appropriate for single node benchmarking.
3. etopo1_oper_an_fc_O1280_benchmark.yml - operational resolution, ~ 9km, appropriate for multi-node benchmarking.

Each config contains reference values in SP/DP (O1280 only in SP) that will be compared against at the end of a successful run.

To run, ecWAM downloads some input files. By default, these are placed in `$HOME/cache/ecwam`. To change this location, you can change 
`ECWAM_CACHE_PATH_DEFAULT` in `share/ecwam/scripts/ecwam_runtime.sh`. Running comprises of three main steps:

1. preproc - serial
```console
./bin/ecwam-run-preproc --run-dir=<run-dir> --prec=dp/sp --config=<ecwam-source-dir>/tests/<test-config.yml>
```

2. preset - serial
```console
./bin/ecwam-run-preset --run-dir=<run-dir> --prec=dp/sp 
```

3. model - parallel
```console
DR_HOOK=1 DR_HOOK_OPT="prof" ./bin/ecwam-run-model --run-dir=<run-dir> --prec=dp/sp --launch="<launch-command, srun/mpirun etc."
```

The dr_hook environment variables ensure dr_hook profiles are created in `<run-dir>/logs/model` upon run completion. Note that
DR_HOOK enables FPE trapping, which can trigger on false positives. For the purposes of benchmarking, this can be disabled via
`DR_HOOK_TRAPFPE=0`.

## Post-processing

The relevant timings for ecWAM can be extracted using the script provided in `post-process/extract_ecwam_drhook.py`, which is explained 
in more detail in `post-process/README.md`.
