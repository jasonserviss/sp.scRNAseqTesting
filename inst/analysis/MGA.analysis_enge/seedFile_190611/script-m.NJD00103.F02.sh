#!/bin/bash -l
#SBATCH -J CIMseq-m.NJD00103.F02
#SBATCH -o /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_enge/seedFile_190611_2/CIMseq-m.NJD00103.F02-%j.out
#SBATCH -t 48:00:00
#SBATCH -n 2
#SBATCH -A snic2019-3-84
#SBATCH -p core
Rscript --vanilla /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_enge/scripts/CIMseqSwarm.R m.NJD00103.F02 seedFile_190611_2
