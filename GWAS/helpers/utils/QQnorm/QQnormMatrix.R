args = commandArgs(trailingOnly=TRUE)
input <- args[1]
output <- args[2]

matrix <- read.csv(input, header=TRUE, sep=" ",check.names=FALSE)
matrix[matrix=="-999"]<-NA
for (i in names(matrix)) {
  column <- matrix[i]
  qq <- qnorm((rank(column,na.last="keep")-0.5)/sum(!is.na(column)))
  matrix[i]<-qq
}

matrix[is.na(matrix)]<-"-999"
write.table(matrix,file=output,row.names=FALSE,sep=" ",quote =FALSE)
