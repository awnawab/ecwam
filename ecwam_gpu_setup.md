ecWAM GPU build and run instructions
************

<br>

Before beginning, please ensure you are logged in to the AC cluster partition.

1. Create bundle:
```console
./package/bundle/ecwam-bundle create --bundle package/bundle/bundle.yml
```

2. Reference CPU build:
```console
srun -c 64 --mem=120GB ./package/bundle/ecwam-bundle build -j 64 --arch package/bundle/arch/ecmwf/hpc2020/nvhpc/22.11 --with-fckit --build-dir=build_cpu --clean
```

3. GPU build:
```console
srun -c 64 --mem=120GB ./package/bundle/ecwam-bundle build -j 64 --arch package/bundle/arch/ecmwf/hpc2020/nvhpc/22.11 --with-loki --with-acc --with-fckit --with-gpu-aware-mpi --build-dir=build_gpu --clean
```

4. With the builds complete, we can now set up the runs. First we must run preproc:
```console
cd build_cpu (or build_gpu)
source env.sh

./bin/ecwam-run-preproc --run-dir=../wamrun_320_cy49r1 --config=../tests/etopo1_oper_an_fc_O320_cy49r1.yml
```

5. Preset:
```console
./bin/ecwam-run-preset --run-dir=../wamrun_320_cy49r1
```

6. CPU model run:
```console
OMP_STACKSIZE=512M OMP_PLACES=cores ./bin/ecwam-run-model --run-dir=../wamrun_320_cy49r1 --launch="ecwam-launch -np 4 -nt 32 --hint=nomultithread"
```

(4 MPI ranks, 32 OpenMP threads per rank)

7. GPU model run:
```console
cd ../build_gpu
OMP_STACKSIZE=512M OMP_PLACES=cores OMP_NUM_THREADS=32 ./bin/ecwam-run-model --run-dir=../wamrun_320_cy49r1 --launch="srun --hint=nomultithread -q dg --gpus=4 -n 4 -c 32 --mem=0"
```

## Notes

- Two test configurations have `LLGCBZ0 = TRUE`: "etopo1_open_an_fc_O48_cy49r1.yml" and "etopo1_open_an_fc_O320_cy49r1.yml". The O48 test validation norms are based on a debug build for ecWAM 1.2.0 i.e. CY49R1. The O320 test validation norms are based on an optimised CPU build of the modified `TAUT_Z0` (commit id ac2a5f4e0690d49c).
- Fortran `PRINT *,` and `STOP` statements are supported on GPUs, although the prints will not necessarily be in the order you expect.
- Adding module imports in offloaded code can be a little tricky, so if you wish to add module imports (e.g. to print `IRANK`), please import them in `WAMINTGR_LOKI_GPU` and pass them down as an argument to `IMPLSCH`.
