#!/usr/bin/env bash
#SBATCH -o v1309-cpu-1.out
#SBATCH -e v1309-cpu-1.err
#SBATCH -t 44:59:00
#SBATCH -p risc5
#SBATCH -N 1
#SBATCH --mail-user=pdiehl@cct.lsu.edu
#SBATCH --exclusive
#SBATCH -c 64

 module load mpi/openmpi-riscv64

 mpirun   ./../OctoTigerBuildChain/build/octotiger/build/octotiger --config_file=v1309.ini --hpx:ini=hpx.stacks.use_guard_pages=0   



