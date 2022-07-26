## dtangle deconv script
##
## @zgr2788


#Load dtangle
suppressMessages(library(dtangle))
suppressMessages(library(energy))
suppressMessages(library(tidyr))



#Get args and load files
args <- commandArgs(trailingOnly = TRUE)
filename_T <- args[1]
filename_P <- args[2]
filename_C1 <- args[3]
filename_C2 <- args[4]
filename_O <- args[5]

T <- readRDS(filename_T)
P <- readRDS(filename_P)
C1 <- readRDS(filename_C1)
C2 <- readRDS(filename_C2)


#Toss out the genes tossed out in T normalization from C as well
common <- intersect(rownames(C1), rownames(T))
common <- intersect(common, rownames(C2))
C1 <- C1[common,]
C2 <- C2[common,]
T  <- T[common,]

#Preprocess
mixtures <- t(T)
refs <- t(C1)
C2 <- tidyr::separate_rows(C2,"cellType",sep="\\|")
C2 <- C2[C2$geneName %in% rownames(C1),]
MD <- tapply(C2$geneName,C2$cellType,list)
MD <- lapply(MD,function(x) sapply(x, function(y) which(y==rownames(C1))))

#Get results and reorder the matrices for correspondence
res <- t(dtangle::dtangle(Y=mixtures, reference=refs, markers = MD)$estimates)
if (filename_P != 'Modules/Psuedobulk/dummy_props.rds') res <- res[order(match(rownames(res), rownames(P))),]

#Save and exit
saveRDS(res, file=filename_O)
