#ARGS
args <- commandArgs(TRUE)

#PACKAGES
packages <- c("tidyverse", "future")
purrr::walk(packages, library, character.only = TRUE)
rm(packages)

currPath <- getwd()

#load data
if(file.exists(file.path(currPath, 'data/CIMseqData.rda'))) {
  load(file.path(currPath, 'data/CIMseqData.rda'))
}

if(!is.na(args[1])) {
  library(CIMseq, lib.loc = "/home/jason/R/x86_64-redhat-linux-gnu-library/3.5")
  library(CIMseq.data, lib.loc = "/home/jason/R/x86_64-redhat-linux-gnu-library/3.5")
  library(CIMseq.testing, lib.loc = "/home/jason/R/x86_64-redhat-linux-gnu-library/3.5")
  
  runSwarmUppmax(
    cObjSng, cObjMul, swarmInit = NULL, maxiter = 100,
    nSyntheticMultiplets = 400, eps.stagnate = 1, maxit.stagnate = 5,
    currPath = getwd(), args = args
  )
  
} else {
  library(CIMseq)
  library(CIMseq.data)
  library(CIMseq.testing)
  
  runSwarmMultiprocess(
    cObjSng, cObjMul, swarmInit = NULL, maxiter = 100,
    nSyntheticMultiplets = 400, eps.stagnate = 1, maxit.stagnate = 5,
    currPath = getwd()
  )
}

writeLines(capture.output(sessionInfo()), file.path(currPath, "logs/sessionInfo_CIMseqSwarm.txt"))
print("finished")
