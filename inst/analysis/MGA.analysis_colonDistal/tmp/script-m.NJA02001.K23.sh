#!/bin/bash -l
#SBATCH -J CIMseq-m.NJA02001.K23
#SBATCH -o /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_colonDistal/tmp/CIMseq-m.NJA02001.K23-%j.out
#SBATCH -t 72:00:00
#SBATCH -n 1
#SBATCH -A snic2019-3-84
#SBATCH -p core
Rscript --vanilla /home/jason/Github/CIMseq.testing/inst/analysis/MGA.analysis_colonDistal/scripts/CIMseqSwarm.R m.NJA02001.K23
