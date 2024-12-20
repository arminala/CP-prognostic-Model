cat("\14")
options(java.parameters = "-Xmx64g")  # Set heap space to 4 GB, adjust as needed
library(rJava)  # Load rJava library
if (!require("pacman")) install.packages("pacman")
if (!require("glmnet")) install.packages("glmnet")

if (!require("DescTools")) install.packages("DescTools")
library(DescTools)
pacman::p_load(pacman, rio)
library(glmnet)      # version 2.0-2

if (!require("kernlab")) install.packages("kernlab")
library(kernlab)
if (!require("Rtsne")) install.packages("Rtsne")
library(Rtsne)
if (!require("parallel")) install.packages("parallel")
if (!require("bartMachine")) install.packages("bartMachine")
library(BART)
library(parallel)    # version 3.1.3
mydata=import("MotorCP2_Full_Comp.xlsx")
mydata=mydata[,-1]




#######################STEP2: Evaluation#######################




mydata1=mydata
####### A) Apparent Performance

xx=as.matrix(mydata1[,1:(ncol(mydata1)-1)])
yy=as.matrix(mydata$motor_cp2)
model <- ksvm(xx, yy, type = "C-svc", kernel = "laplacedot")
o=predict(model,newdata = xx, type = "decision")

Cstat(o,yy)
tr=seq(min(o),max(o), length.out=50)
sen1=rep(0,length(tr))
spe1=rep(0,length(tr))
acc1=rep(0,length(tr))
cin1=rep(0,length(tr))
d=rep(0,length(tr))


for (m in 1:length(tr)){
  tr1=tr[m]
  tp=0
  tn=0
  fp=0
  fn=0
  
  for (i in 1:nrow(o)){
    if (o[i]>=tr1 & yy[i]==1){tp=tp+1}
    if (o[i]>=tr1 & yy[i]==0){fp=fp+1}
    if (o[i]<tr1 & yy[i]==1){fn=fn+1}
    if (o[i]<tr1 & yy[i]==0){tn=tn+1}
  }
  sen1[m]=tp/(tp+fn)
  spe1[m]=tn/(tn+fp)
  acc1[m]=(tp+tn)/(tn+tp+fn+fp)
  p1=c(sen1[m], (1-spe1[m]))
  p2=c(1,0)
  d[m]=sen1[m]-(1-spe1[m])
  
  
}
btr=as.numeric(which(d==max(d)))
Appsen=sen1[btr[1]]
Appspe=spe1[btr[1]]
Appacc=acc1[btr[1]]
tr2=tr[btr[1]]
tr1=tr2
tp=0
tn=0
fp=0
fn=0

for (i in 1:length(o)){
  if (o[i]>=tr1 & yy[i]==1){tp=tp+1}
  if (o[i]>=tr1 & yy[i]==0){fp=fp+1}
  if (o[i]<tr1 & yy[i]==1){fn=fn+1}
  if (o[i]<tr1 & yy[i]==0){tn=tn+1}
}
Apptp=tp
Apptn=tn
Appfp=fp
Appfn=fn
AppPPV=tp/(tp+fp)
AppNPV=tn/(tn+fn)
AppLRpluse=Appsen/(1-Appspe)
AppLRminus=(1-Appsen)/Appspe
yyh=NULL
for (i in 1:length(o)){
  if (o[i]>=tr1) {yyh[i]=1}
  if (o[i]<tr1) {yyh[i]=0}
}
AppAUC=Cstat(yyh,yy)
AppBrier=mean((yyh-yy)^2)
################ B) Bootstrap Performance
BSAUC=NULL
BSacc=NULL
BSsen=NULL
BSspe=NULL
BSPPV=NULL
BSNPV=NULL
BSBrier=NULL
BSLRpluse=NULL
BSLRminus=NULL



TPAUC=NULL
TPacc=NULL
TPsen=NULL
TPspe=NULL
TPPPV=NULL
TPNPV=NULL
TPBrier=NULL
TPLRpluse=NULL
TPLRminus=NULL

nsub=nrow(mydata)
nboot=1000
cc=NULL
cind=matrix(0,nboot)
nets=list()
for (n1 in 1:nboot) {
  print(n1)
  A<- sample(nsub,replace=TRUE)
  mydata2=mydata1[A,]
  x1 <- as.matrix(mydata2[,1:(ncol(mydata2)-1)])
  y1 <- as.matrix(mydata2[,ncol(mydata2)])
  model <- ksvm(x1, y1,  type = "C-svc",kernel = "laplacedot")
  o1=predict(model,newdata = x1, type = "decision")
  
  tr=seq(min(o1),max(o1), length.out=50)
  sen1=rep(0,length(tr))
  spe1=rep(0,length(tr))
  acc1=rep(0,length(tr))
  cin1=rep(0,length(tr))
  d=rep(0,length(tr))
  
  
  for (m in 1:length(tr)){
    tr1=tr[m]
    tp=0
    tn=0
    fp=0
    fn=0
    
    for (i in 1:nrow(o)){
      if (o1[i]>=tr1 & y1[i]==1){tp=tp+1}
      if (o1[i]>=tr1 & y1[i]==0){fp=fp+1}
      if (o1[i]<tr1 & y1[i]==1){fn=fn+1}
      if (o1[i]<tr1 & y1[i]==0){tn=tn+1}
    }
    sen1[m]=tp/(tp+fn)
    spe1[m]=tn/(tn+fp)
    acc1[m]=(tp+tn)/(tn+tp+fn+fp)
    p1=c(sen1[m], (1-spe1[m]))
    p2=c(1,0)
    d[m]=sen1[m]-(1-spe1[m])
    
  }
  btr=as.numeric(which(d==max(d)))
  BSsen[n1]=sen1[btr[1]]
  BSspe[n1]=spe1[btr[1]]
  BSacc[n1]=acc1[btr[1]]
  tr2=tr[btr[1]]
  y1h=NULL
  for (i in 1:length(o1)){
    if (o1[i]>=tr2) {y1h[i]=1}
    if (o1[i]<tr2) {y1h[i]=0}
  }
  BSAUC[n1]=Cstat(y1h,y1)
  BSBrier[n1]=mean((y1h-y1)^2)
  tr1=tr2
  tr1=tr2
  tp=0
  tn=0
  fp=0
  fn=0
  
  for (i in 1:length(o1)){
    if (o1[i]>=tr1 & y1[i]==1){tp=tp+1}
    if (o1[i]>=tr1 & y1[i]==0){fp=fp+1}
    if (o1[i]<tr1 & y1[i]==1){fn=fn+1}
    if (o1[i]<tr1 & y1[i]==0){tn=tn+1}
  }
  BStp=tp
  BStn=tn
  BSfp=fp
  BSfn=fn
  BSPPV[n1]=tp/(tp+fp)
  BSNPV[n1]=tn/(tn+fn)
  BSLRpluse[n1]=BSsen[n1]/(1-BSspe[n1])
  BSLRminus[n1]=(1-BSsen[n1])/BSspe[n1]
  
  ###### Test Performance
  x <- as.matrix(mydata1[,1:(ncol(mydata1)-1)])
  y <- as.matrix(mydata1[,ncol(mydata1)])
  oo=predict(model,newdata = x, type = "decision")
  
  tp=0
  tn=0
  fp=0
  fn=0
  for (i in 1:nrow(o)){
    if (oo[i]>=tr2 & y[i]==1){tp=tp+1}
    if (oo[i]>=tr2 & y[i]==0){fp=fp+1}
    if (oo[i]<tr2 & y[i]==1){fn=fn+1}
    if (oo[i]<tr2 & y[i]==0){tn=tn+1}
  }
  TPsen[n1]=tp/(tp+fn)
  TPspe[n1]=tn/(tn+fp)
  TPacc[n1]=(tp+tn)/(tn+tp+fn+fp)
  TPtp=tp
  TPtn=tn
  TPfp=fp
  TPfn=fn
  TPPPV[n1]=tp/(tp+fp)
  TPNPV[n1]=tn/(tn+fn)
  yh=NULL
  for (i in 1:length(oo)){
    if (oo[i]>=tr1) {yh[i]=1}
    if (oo[i]<tr1) {yh[i]=0}
  }
  TPAUC[n1]=Cstat(yh,y)
  TPBrier[n1]=mean((yh-y)^2)
  
  TPLRpluse[n1]=TPsen[n1]/(1-TPspe[n1])
  TPLRminus[n1]=(1-TPsen[n1])/TPspe[n1]
}
OCsen=Appsen-(BSsen-TPsen)
OCspe=Appspe-(BSspe-TPspe)
OCAUC=AppAUC-(BSAUC-TPAUC)
OCacc=Appacc-(BSacc-TPacc)
OCPPV=AppPPV-(BSPPV-TPPPV)
OCNPV=AppNPV-(BSNPV-TPNPV)
OCLRp=OCsen/(1-OCspe)
OCLRn=(1-OCsen)/OCspe
OCBrier=AppBrier-(BSBrier-TPBrier)





mean(OCsen)
mean(OCspe)
mean(OCAUC)
mean(OCacc)
mean(OCPPV)
mean(OCNPV)
mean(OCBrier)


perf=rbind(OCsen,OCspe,OCAUC,OCacc,OCPPV,OCNPV,OCLRp,OCLRn,OCBrier)
rownames(perf)=c("Sen","Spe","AUC","acc","PPV","NPV","LRp","LRn","Brier")
write.csv(perf,file = "Optimism_Corrected_NMF_All.csv")
