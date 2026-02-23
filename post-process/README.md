ecWAM post-processing
---------

The relevant performance timings for ecWAM can be extracted using the `extract_ecwam_drhook.py` script included herein.
The following times are extracted:
- propag - Wave propagation kernel, `PROPAG_WAM`, minus the MPI comms.
- src - Implicit source-term integration scheme, `IMPLSCH`.
- mpi - MPI comms in wave propagation kernel, `MPEXCHNG`.
- norms - Global norms computation, `OUTBLOCK`.
- wamintgr - Total time spent in both the wave propagation kernel and source-term integration, `WAMINTGR/WAMINTGR_LOKI_GPU`.
- advection_loop - Total time minus setup and teardown, `ADVECTION_LOOP` markers in `WAMODEL`.
- offload - Total time spent in CPU<->GPU data-transfers.


Timings, averaged across all MPI ranks, can be extracted using the provided `extract_ecwam_drhook.py` CLI script, which requires
[ifsbench](https://github.com/ecmwf-ifs/ifsbench.git):

```console
source <build-dir>/ifsbench/ifsbench_env/bin/activate
$ (ifsbench_env) python3 extract_ecwam_drhook.py --help
Usage: extract_ecwam_drhook.py [OPTIONS]

Options:
  --log-dir PATH   Path to DRHOOK logs.
  --out-file PATH  File to write extracted timings to
  --gpu / --no-gpu Extract cpu-gpu data transfer times. Defaults to --no-gpu.
  --help           Show this message and exit.
```

drhook profiles are used to extract the above timings. To gather these, please set the `DR_HOOK=1 DR_HOOK_OPT=prof` environment variables.
Upon completion the drhook profiles will then be in <run-dir>/logs/model.
