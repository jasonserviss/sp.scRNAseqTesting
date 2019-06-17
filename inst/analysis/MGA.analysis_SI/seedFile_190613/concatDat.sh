#!/bin/bash -l
#SBATCH -J concat
#SBATCH -o /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_SI/logs/concat.out
#SBATCH -t 00:10:00
#SBATCH -n 1
#SBATCH -A snic2019-3-84
#SBATCH -p devcore
Rscript --vanilla ~/scripts/uppmax.concat.swarm.R /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_SI/logs/seedFile_190613.txt
