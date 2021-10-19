# install.packages('LDlinkR') # https://ldlink.nci.nih.gov/?tab=snpclip
#install.packages('sjmisc')
library(LDlinkR)

library(parallel)

args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

phenos=read.table("phenotypes.txt")
phenos=as.character(as.vector(phenos[1,]))
print(args[1])
print(phenos)

# function to execute for all phenotypes
LD_prune = function(pheno) {
	hits_file <- paste(pheno,"__topHits.csv",sep='')
	pop <- "GBR" #"GBR" "CEU"
	r2_thresh <- "0.1"
	distance_thresh <- 500000
	# INITIALIZE APPROPRIATELY ####################################################

	# read hits
	start.time <- Sys.time()
	hits <- read.csv(hits_file, header=TRUE,check.names=FALSE)
	hits <- hits[order(hits[[paste(pheno,".log10p",sep="")]], decreasing=TRUE), ] # order by pvalue
	hits["pruned"] = FALSE # add column to keep track of pruned SNPs

	i <- 1; while (i <= nrow(hits)-1) { # check each SNP
	  snp_i <- hits[i,] 
	  if(snp_i$pruned == FALSE){ # if it has not been pruned...
	    j <- i+1; while (j <= nrow(hits)) { # ...then look for SNPs to prune among all other SNPs...
	      snp_j <- hits[j,]
	      if(snp_i$chr == snp_j$chr){ # ...which are in the same chr...
		if(abs(snp_i$pos - snp_j$pos) < distance_thresh){ # ...and which are less than 500Kb away...
		  if(snp_j$pruned == FALSE){ # ...and which have not been pruned...  
		    write(paste(snp_i$rsid, snp_j$rsid), stdout())
		    error = tryCatch({
		      LDLinkOutput <- LDpair(snp_i$rsid, snp_j$rsid, pop, token = "f0c92fa3ea9b", file = FALSE)
		      if(LDLinkOutput$r2 > r2_thresh){ # ...if not in LD...
			hits[j,"pruned"] <- TRUE # ...then prune it away
		      }
		    }, error = function(error_condition) {error = TRUE}) # prune also in case of error
		    if(!is.null(error) && error == TRUE){ 
		      hits[j,"pruned"] <- TRUE 
		    } 
		  }
		}
	      }
	      j <- j+1  
	    }
	  }
	  i <- i+1
	}

	# output thinned list of SNPs
	result <- hits[hits["pruned"]==FALSE,] # only variants that were not pruned
	result[,"pruned"] <- NULL
	result <- result[with(result, order(chr, pos, decreasing = FALSE)), ] # order by chrom and position
	write.csv(result, paste0("GWAS_results_pruned_R2_", r2_thresh,"_",pop,"_",pheno,".csv"), row.names = F)
	end.time <- Sys.time()
	time.taken <- end.time - start.time
	write(paste("execution took", as.integer(time.taken),"seconds"), stdout())
}

mclapply(phenos, LD_prune, mc.cores=200)
