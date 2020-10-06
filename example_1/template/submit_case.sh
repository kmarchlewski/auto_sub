#!/bin/bash
#
#SBATCH --output=case_log.txt
#
#SBATCH --time=01:00:00
#SBATCH --partition=cpus
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

sleep 20
echo "x_1;x_2;state" > solver_output.csv
echo "$(cat solver_input.csv | sed '2q;d');done" >> solver_output.csv
echo "Done!"

