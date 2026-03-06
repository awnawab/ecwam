#!/usr/bin/env python3

import click
import yaml
from pathlib import Path
from ifsbench import DrHookRecord


@click.command()
@click.option('--log-dir', type=click.Path(), default=None,
              help='Path to DRHOOK logs.')
@click.option('--out-file', type=click.Path(), default=None,
              help='File to write extracted timings to')
@click.option('--gpu/--no-gpu', default=False,
              help='Extract cpu-gpu data transfer times. Defaults to --no-gpu.')
def cli(log_dir, out_file, gpu):

    log_dir_path = Path(log_dir)
    if not log_dir_path.exists():
        raise RuntimeError('Please specify a valid path containing log files.')
    if not out_file:
        raise RuntimeError('Please provide a filename to output timings to.')

    metric = 'avgTimeTotal'
    drhook_record = DrHookRecord.from_raw(log_dir_path/'drhook.prof.*').data

    propag = drhook_record.loc[drhook_record['routine'] == 'PROPAG_WAM'][metric].values[0]
    src = drhook_record.loc[drhook_record['routine'] == 'IMPLSCH'][metric].values[0]
    mpi = drhook_record.loc[drhook_record['routine'] == 'MPI_TIME'][metric].values[0]
    propag -= mpi
    norms = drhook_record.loc[drhook_record['routine'] == 'OUTBS'][metric].values[0]
    norms -= drhook_record.loc[drhook_record['routine'] == 'OUTWNORM'][metric].values[0]
    advection_loop = drhook_record.loc[drhook_record['routine'] == 'ADVECTION_LOOP'][metric].values[0]
    wamintgr = drhook_record.loc[drhook_record['routine'] == 'WAMINTGR'][metric].values[0]
    propags2 = drhook_record.loc[drhook_record['routine'] == 'PROPAGS2'][metric].values[0]
    time1 = drhook_record.loc[drhook_record['routine'] == 'RUNWAM:TIME_1'][metric].values[0]

    times = {
      'propag' : propag,
      'src' : src,
      'mpi' : mpi,
      'norms' : norms,
      'advection_loop': advection_loop,
      'wamintgr': wamintgr,
      'propags2': propags2,
      'time1': time1
    }

    if gpu:
        offload = drhook_record.loc[drhook_record['routine'] == 'DATA_OFFLOAD'][metric].values[0]
        times['offload'] = offload

    times = {k: float(v) for k, v in times.items()}
    with open(Path(out_file), mode="w") as file:
        yaml.dump(times, file)

if __name__ == "__main__":
    cli()
