supponiamo che tu abbia un file “myfile.txt” con header con queste colonne
ID sex age age2 pheno covariate
Lo fai leggere a R per normalizzare il tuo tratto

A<-read.table(“myfile.txt",sep=" ",header=F,dec=".")
ID<-A[,1]
sex<-A[,2] 
age<-A[,3]
age2<-A[,4]
pheno<-A[,5]

cov<-A[,6]
pheno_res<-residuals(lm(pheno~age+age2+sex+cov,na.action=na.exclude))
pheno_res_norm<-qnorm((rank(pheno_res,na.last="keep")-0.5)/sum(!is.na(pheno_res)))
write.table(pheno_res_norm,file=“phenofile",sep="\t",dec=".",col.names=F,row.names=F,quote=F)

