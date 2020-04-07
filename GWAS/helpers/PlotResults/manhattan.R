pdf("Manhattan.pdf",width = 14, height = 7)

x <-read.table("YOURFILE",header=T,sep=" ",dec=".");

####### YOURFILE should be contain the columns "P", "CHR", "POS". Other columns will be ignored.


 pvalue=round(-log10(x$P),digits=2)
 chr =x$CHR
 p<-x$POS

 ## defined chromosomes boundaries
 limit<-c()
 GWpos<-c()

 c<-which(chr == 1)
 limit[1]<-max(p[c])/1000000
 GWpos[c]= p[c]/1000000
 
 for (i in 2:22){
 c<-which(chr  == i)
 a = limit[i-1]
 GWpos[c]= (p[c]/1000000)+a
 limit[i]<-max(GWpos[c])
}

## round position and pvalues
pos=round(GWpos,digits=0)
table<-unique(matrix(c(pos,pvalue,chr),ncol=3))
r<-max(pvalue)+3
extr<-c(min(table[,1]),max(table[,1]))
# plot frame ## 19 is the max pvalue among all 3 traits- change if necessary
plot(extr,c(0,0),ylim=c(0,r),xlim=extr,tcl =-0.35, xaxt="n",cex.axis=0.9,cex.lab=1,font.axis=1,bty="n",frame.plot=TRUE, pch="",  ylab=expression(-log[10]*' p-value'),xlab="Chromosome",mgp=c(2.5,1,0));
# plot chromosomes
odd<-seq(1,21,2)
for (i in 1:length(odd) ){
c<-which(table[,3] == odd[i] )
points(table[c,1],table[c,2],pch=20,cex=0.5, col= "slategray1")
}
even<-seq(2,22,2)
for (i in 1:length(even) ){
c<-which(table[,3] == even[i] )
points(table[c,1],table[c,2],pch=20,cex=0.5, col= "slategray3")

}

abline(h = -log10(0.00000005),col='red',lty=3)


## write chromosomes number
labs<-c()
labs[1]=limit[1]/2

for (i in 2:22){
 labs[i]=(limit[i]+limit[i-1])/2
}




axis(1,labels=odd,line=-1.5,lty='blank',tcl=0,cex.axis=0.8,font.axis=1,at=labs[odd],padj=0)
axis(1,labels=even,line=-1.5,lty='blank',tcl=0,cex.axis=0.8,font.axis=1,at=labs[even],padj=0)




dev.off();














