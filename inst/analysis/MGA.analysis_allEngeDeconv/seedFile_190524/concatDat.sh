#!/bin/bash -l
#SBATCH -J concat
#SBATCH -o /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_allEngeDeconv/logs/concat.out
#SBATCH -t 00:10:00
#SBATCH -n 1
#SBATCH -A snic2019-3-84
#SBATCH -p devcore
Rscript --vanilla ~/scripts/uppmax.concat.swarm.R /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_allEngeDeconv/logs/seedFile_190524.txt
