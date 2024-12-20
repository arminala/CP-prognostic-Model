cat("\14")
if (!require("pacman")) install.packages("pacman")
if (!require("miselect")) install.packages("miselect")
if (!require("mice")) install.packages("mice")
pacman::p_load(pacman, rio)
library(miselect)      # version 2.0-2
library(mice)
if (!require("kernlab")) install.packages("kernlab")
library(kernlab)
if (!require("Rtsne")) install.packages("Rtsne")
library(Rtsne)
if (!require("metrica")) install.packages("metrica")
library(metrica)
library(miselect)      # version 2.0-2
library(mice)
library(DescTools)
mydata <- import("Motor_Scale_Comp_without_interaction.xlsx")
mydata=mydata[,-1]


#######################STEP2: Evaluation#######################




mydata1=mydata
####### A) Apparent Performance

xx=as.matrix(mydata1[,1:(ncol(mydata1)-1)])
yy=as.matrix(mydata1[,ncol(mydata1)])
model <- ksvm(xx, yy, type = "eps-svr", kernel = "anovadot",kpar=list(sigma=100))
o=predict(model,newdata = xx)

AppAUC=Cstat(o,yy)
res=yy-o
SSR=sum((res)^2)
SST=sum((yy-mean(yy))^2)
AppR2=1-(SSR/SST)
OrgAppR2=AppR2
AppR2=1-((1-AppR2)*(nrow(xx)-1))/(nrow(xx)-ncol(xx)-1)
Appmse=mean((res/max(yy))^2)
write.csv(AppR2,file="App.csv")
Appmse1=(mean((res)^2))^0.5
Apprrmse=RRMSE(obs =yy,pred = o)
################ B) Bootstrap Performance
BSAUC=NULL
BSR2=NULL
OrgBSR2=NULL
BSmse=NULL
BSmse1=NULL
BSrrmse=NULL


TPAUC=NULL
TPR2=NULL
OrgTPR2=NULL
TPmse=NULL
TPmse1=NULL
TPrrmse=NULL
nsub=nrow(mydata)
boot=500

for (n1 in 1:nboot) {
  print(n1)
  A<- sample(nsub,replace=TRUE)
  mydata2=mydata1[A,]
  x1 <- as.matrix(mydata2[,1:(ncol(mydata2)-1)])
  y1 <- as.matrix(mydata2[,ncol(mydata2)])
  model <- ksvm(x1, y1, type = "eps-svr", kernel = "anovadot",kpar=list(sigma=100))
  o1=predict(model,newdata = x1)
  BSAUC[n1]=Cstat(o1,y1)
  res=y1-o1
  SSR=sum((res)^2)
  SST=sum((y1-mean(y1))^2)
  BSR2[n1]=1-(SSR/SST)
  OrgBSR2[n1]=BSR2[n1]
  BSR2[n1] <- 1-((1-BSR2[n1])*(nrow(xx)-1))/(nrow(xx)-ncol(xx)-1)
  BSmse[n1]=mean((res/max(y1))^2)
  BSmse1[n1]=(mean((res)^2))^0.5
  BSrrmse[n1]=RRMSE(obs =y1,pred = o1)
  x <- as.matrix(mydata1[,1:(ncol(mydata1)-1)])
  y <- as.matrix(mydata1[,ncol(mydata1)])
  oo=predict(model,newdata = x)
  TPAUC[n1]=Cstat(oo,y)
  res=y-oo
  SSR=sum((res)^2)
  SST=sum((y-mean(y))^2)
  TPR2[n1]=1-(SSR/SST)
  OrgTPR2[n1]=TPR2[n1]
  TPR2[n1] <- 1-((1-TPR2[n1])*(nrow(xx)-1))/(nrow(xx)-ncol(xx)-1)
  TPmse[n1]=mean((res/max(y))^2)
  TPmse1[n1]=(mean((res)^2))^0.5
  TPrrmse[n1]=RRMSE(obs =y,pred = oo)
}
OCmse=Appmse-(BSmse-TPmse)
OCR2=AppR2-(BSR2-TPR2)
OrgOCR2=OrgAppR2-(OrgBSR2-OrgTPR2)
OCAUC=AppAUC-(BSAUC-TPAUC)
OCmse1=Appmse1-(BSmse1-TPmse1)
mean(OCmse)
mean(OCR2)
mean(OCAUC)
mean(OCmse1)
write.csv(BSR2,file="BS.csv")
write.csv(TPR2,file = "TP.csv")

perf=rbind(OCmse,OCmse1,OCR2,OCAUC,OrgOCR2)
write.csv(perf,file = "Optimism_Corrected_NMF_All.csv")
