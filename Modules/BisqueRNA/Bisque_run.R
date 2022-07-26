## Bisque deconv script
##
## @zgr2788


#Load Bisque
suppressMessages(library(BisqueRNA))
suppressMessages(library(Biobase))
suppressMessages(library(energy))



#Get args and load files
args <- commandArgs(trailingOnly = TRUE)
filename_T <- args[1]
filename_P <- args[2]
filename_C0 <- args[3]
filename_phenData <- args[4]
filename_O <- args[5]

T <- readRDS(filename_T)
P <- readRDS(filename_P)
C0 <- readRDS(filename_C0)
phenData <- readRDS(filename_phenData)


#Match genes in rows for both references
common <- intersect(rownames(C0), rownames(T))
T <- T[common,]
C0 <- C0[common,]
rm(common)

#Convert to eset
T <- ExpressionSet(T)
C0 <- ExpressionSet(C0, phenoData = as(phenData, "AnnotatedDataFrame"))
C0$SubjectName <- C0$sampleID #BisqueRNA uses hard-coded colname


#Get results and reorder the matrices for correspondence
res <- BisqueRNA::ReferenceBasedDecomposition(T, C0, markers=NULL, use.overlap=FALSE)$bulk.props
if (filename_P != 'Modules/Psuedobulk/dummy_props.rds') res <- res[order(match(rownames(res), rownames(P))),]

#Save and exit
saveRDS(res, file=filename_O)
