
#PACKAGES
packages <- c("CIMseq", "CIMseq.data", "tidyverse", "future")
purrr::walk(packages, library, character.only = TRUE)
rm(packages)

currPath <- getwd()

#load data
if(file.exists(file.path(currPath, 'data/CIMseqData.rda'))) {
  load(file.path(currPath, 'data/CIMseqData.rda'))
}

#testing
idx <- sample(1:ncol(getData(cObjMul, "counts")), 120, FALSE)
cObjMul.small <-  CIMseqMultiplets(
  getData(cObjMul, "counts")[, idx], 
  getData(cObjMul, "counts.ercc")[, idx], 
  getData(cObjMul, "features")
)

print(paste0("Starting deconvolution at ", Sys.time()))
future::plan(multiprocess)
sObj <- CIMseqSwarm(
  cObjSng, cObjMul.small, maxiter = 100, swarmsize = 500, nSyntheticMultiplets = 400
)
print(paste0("Finished deconvolution at ", Sys.time()))
save(sObj, file = file.path(currPath, "data/sObj.rda"))

writeLines(capture.output(sessionInfo()), file.path(currPath, "logs/sessionInfo_CIMseqSwarm.txt"))
print("finished")
