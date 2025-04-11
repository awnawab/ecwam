Instructions to build and offload ecWAM to GPU on LUMI
---------------

1. Change `package/bundle/arch/eurohpc/lumi/rocm-afar/5.3/env.sh` to set the correct rocm-afar root-dir, 
   typically should only involve changing `/users/nawabahm` prefix.

2. Create the bundle:
```
./package/bundle/ecwam-bundle create --bundle package/bundle/bundle.yml
``` 

3. Build GPU enabled ecWAM:
```
./package/bundle/ecwam-bundle build -j 16 --arch package/bundle/arch/eurohpc/lumi/rocm-afar/5.3 --with-fckit  --with-loki --with-loki-mode=scc-hoist --with-omp-offload --with-static-linking [--clean --build-dir=<path-to-builddir>]
```

A CPU only binary can be built by removing all bundle flags other than `--arch <arch> --with-fckit`. Double is the default precision, single precision builds require the `--with-single-precision` bundle flag.

4. The ecWAM test-cases are included in the `tests` directory. Running a test for the first time requires `preproc` and `preset` to be run first. The `etopo1_oper_an_fc_O48.yml` test should be used for development and debugging, whereas performance anaylsis should be carried out on the `etopo1_oper_an_fc_O320.yml` test. Runtime parameters like `NPROMA` can be updated in the test config:
```
cd <build-dir>
. env.sh

srun --account=<account-id> --time=00:10:00 ./bin/ecwam-run-preproc --run-dir=<test-specific-rundir> --config=<path-to-tests-srcdir>/etopo1_oper_an_fc_O48.yml
srun --account=<account-id> --time=00:10:00 ./bin/ecwam-run-preset --run-dir=<test-specific-rundir> --config=<path-to-tests-srcdir>/etopo1_oper_an_fc_O48.yml
```

5. ecWAM should be run using the provided script which takes the launch command as an argument:
```
./bin/ecwam-run-model --run-dir=<test-specific-rundir> --launch="srun ..."
```
