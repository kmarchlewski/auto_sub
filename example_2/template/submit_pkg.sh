#!/bin/bash
#
#SBATCH --output=pkg_log.txt
#
#SBATCH --time=14-00:00:00
#SBATCH --partition=cpus
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

echo "x_1;x_2;state" > solver_output.csv

for i in $(seq 2 $(cat solver_input.csv | wc -l))
do
  echo "$(cat solver_input.csv | sed "${i}q;d");done" >> solver_output.csv
  echo "Done!"
done

