cat("\14")
options(java.parameters = "-Xmx64g")  # Set heap space to 4 GB, adjust as needed


if (!require("pacman")) install.packages("pacman")
if (!require("bnstruct")) install.packages("bnstruct")
library(pacman) 
if (!require("DescTools")) install.packages("DescTools")
library(DescTools)
pacman::p_load(pacman, rio)
library(bnstruct)      # version 2.0-2

if (!require("kernlab")) install.packages("kernlab")
library(kernlab)
if (!require("Rtsne")) install.packages("Rtsne")
library(Rtsne)
if (!require("parallel")) install.packages("parallel")
if (!require("bartMachine")) install.packages("bartMachine")
library(BART)
library(parallel)    # version 3.1.3



mydata=import("Data_with_NA_No_Out.csv")



###############A) Do the Imputation
miss_data=mydata
miss_data=as.matrix(miss_data)
ind=which(is.na(miss_data))
rw=row(miss_data)[ind]
rw=unique(rw)
imp_Subs=knn.impute(miss_data,k=1,to.impute =rw,using = 1:nrow(miss_data))
imp_data=miss_data
for (n in 1:length(rw)){
  imp_data[rw[n],]=imp_Subs[n,]
}
write.csv(imp_data,file = "Imputed_Data.csv")
