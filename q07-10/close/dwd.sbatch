#!/usr/bin/env bash
#SBATCH -o dwd-gregor-1.out
#SBATCH -e dwd-gregor-1.err
#SBATCH -t 24:59:00
#SBATCH -p risc5
#SBATCH -N 1
#SBATCH --mail-user=pdiehl@cct.lsu.edu
#SBATCH --exclusive
#SBATCH -c 64

 module load mpi/openmpi-riscv64

 ./../../OctoTigerBuildChain/build/octotiger/build/octotiger --config_file=dwd.ini --print_times_per_timestep=1 --hpx:print-counter=/octotiger*/compute/cpu*kokkos* --hpx:print-counter=/arithmetics/add@/octotiger*/compute/cpu/hydro_kokkos --hpx:print-counter=/arithmetics/add@/octotiger*/compute/cpu/hydro_kokkos_aggregated --hpx:threads=1



