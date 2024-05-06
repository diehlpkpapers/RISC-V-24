#!/usr/bin/env bash
#SBATCH -o level5-lock-8.out
#SBATCH -e level5-lock-8.err
#SBATCH -t 08:59:00
#SBATCH -p risc5
#SBATCH -N 1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=pdiehl@cct.lsu.edu

./../OctoTigerBuildChain/build/octotiger/build/octotiger --config_file=rotating_star.ini --hpx:threads=8


