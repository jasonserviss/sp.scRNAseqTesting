#ARGS
args <- commandArgs(TRUE)

#PACKAGES
library(CIMseq, lib.loc = '~/tmp.packages')
packages <- c("CIMseq.data", "tidyverse", "future")
purrr::walk(packages, library, character.only = TRUE)
rm(packages)

currPath <- getwd()

#load data
if(file.exists(file.path(currPath, 'data/CIMseqData.rda'))) {
  load(file.path(currPath, 'data/CIMseqData.rda'))
}

if(!is.na(args[1])) {
  plan(sequential)
  sample <- as.character(args[1])
  print(paste0("Running ", sample))
  counts <- getData(cObjMul, "counts")
  counts.ercc <- getData(cObjMul, "counts.ercc")
  cObjMul <- CIMseqMultiplets(
    matrix(counts[, sample], ncol = 1, dimnames = list(rownames(counts), sample)),
    matrix(counts.ercc[, sample], ncol = 1, dimnames = list(rownames(counts.ercc), sample)),
    getData(cObjMul, "features")
  )

  #run deconvolution
  print(paste0("Starting deconvolution at ", Sys.time()))
  sObj <- CIMseqSwarm(
    cObjSng, cObjMul, maxiter = 100, swarmsize = 500, nSyntheticMultiplets = 400, e = 0.1
  )
  print(paste0("Finished deconvolution at ", Sys.time()))
  save(sObj, file = file.path(currPath, paste0("tmp/sObj_", sample, "_uppmax.rda")))

} else {
  #future::plan(multiprocess)
  options(future.wait.interval = 10000.0)
  options(future.wait.timeout = 1e9)
  future::plan(
    future.batchtools::batchtools_slurm,
    template = "/crex/proj/snic2018-8-151/private/batchtools.slurm.tmpl",
    resources = list(
      account = "snic2018-8-151", partition = "core", ntasks = 1L,
      time = "24:00:00", jobname = "testingPoissonSorted",
      modules = "R_packages/3.5.0", R = "R/3.5.0", log.file = file.path(currPath, "logs/slurm.txt")
    ),
    workers = 100
  )

  #run deconvolution
  print(paste0("Starting deconvolution at ", Sys.time()))
  sObj <- CIMseqSwarm(
    cObjSng, cObjMul, maxiter = 100, swarmsize = 500, nSyntheticMultiplets = 400
  )
  print(paste0("Finished deconvolution at ", Sys.time()))
  save(sObj, file = file.path(currPath, "data/sObj.rda"))
}

writeLines(capture.output(sessionInfo()), file.path(currPath, "logs/sessionInfo_spSwarm.txt"))
print("finished")
