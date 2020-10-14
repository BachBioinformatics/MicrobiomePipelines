rm(list=ls())

## First specify the packages of interest
packages = c("stringr", "ggplot2")

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)


## First of all define a function to perform some operations in each file 
percent_filter <- function(df) {
  
  df[,"R1.af.size.unpaired"]<- df[,"R1.af.size"]+ df[,"R1_Orphan"]
  df[,"R2.af.size.unpaired"]<- df[,"R2.af.size"]+ df[,"R2_Orphan"]
  df[,"R1_Filtred"]<- (df[,"R1.af.size.unpaired"]) * 100 / (df[,"R1.bf.size"]) 
  df[,"R2_Filtred"]<- (df[,"R2.af.size.unpaired"]) * 100 / (df[,"R2.bf.size"])
  df[,"R1_lost_in_overlap"]<- df[,"size.ovelap.avg"]-df[,"R1.af.size.unpaired"]
  df[,"R2_lost_in_overlap"]<- df[,"size.ovelap.avg"]-df[,"R2.af.size.unpaired"]
  df[,"R1_overlap"]<- (df[,"size.ovelap.avg"]) * 100 / (df[,"R1.af.size"]) 
  df[,"R2_overlap"]<- (df[,"size.ovelap.avg"]) * 100 / (df[,"R2.af.size"])
  
  return(df)
}

setwd(getwd())

### import all stat files 
Statfiles<-list.files(getwd())

### select the stat files of R1 and R2
Statfiles<-grep("Stats.Filtation", Statfiles, value=TRUE)

list_resumate=list()

for (i in 1:length(Statfiles)){
  
  print (Statfiles[i])
  statfiledata<-read.csv2(file=paste(Statfiles[i], sep=""), check.names = FALSE, header=TRUE, row.names = 1, sep=":", stringsAsFactors=FALSE)
  statfilename<-stringr::str_extract( paste(Statfiles[i], sep=""), "Q.[0-9]+.O.[0-9]+")
  dim(statfiledata)
  ncol(statfiledata)
  rownames(statfiledata)<-gsub("\\s", "",rownames (statfiledata))
  rownames(statfiledata)<-gsub("_S[0-9]+_L[0-9]+_Q_[0-9]+", "",rownames (statfiledata))
  rownames(statfiledata)
  
  ### treat singles files 
  singleR1<-read.csv2(file=paste("all.Singles.R1", statfilename, "csv", sep="."), check.names = FALSE, header=FALSE, row.names = 1, sep=":", stringsAsFactors=FALSE)
  dim(singleR1)
  singleR2<-read.csv2(file=paste("all.Singles.R2", statfilename, "csv", sep="."), check.names = FALSE, header=FALSE, row.names = 1, sep=":", stringsAsFactors=FALSE)
  dim(singleR2)
  
  rownames(singleR1)<-gsub("\\s", "",rownames(singleR1))
  rownames(singleR1)<-gsub("_S[0-9]+_L[0-9]+.singles.fastq", "",rownames(singleR1))
  rownames(singleR2)<-gsub("\\s", "",rownames(singleR2))
  rownames(singleR2)<-gsub("_S[0-9]+_L[0-9]+.singles.fastq", "",rownames(singleR2))
  
  statfiledata<-statfiledata[order(row.names(statfiledata)),]
  singleR1<-singleR1[order(row.names(singleR1)),]
  singleR2<-singleR2[order(row.names(singleR2)),]
  rownames(statfiledata)
  rownames(singleR1)
  rownames(singleR2)
  
  statfiledata["R1_Orphan"]<-singleR1
  statfiledata["R2_Orphan"]<-singleR2
  
  ### discard samples having lower then 1000 reads 
  statfiledata[]<-sapply(statfiledata, as.numeric)
  statfiledata<-statfiledata[statfiledata$R1.bf.size>=1000,]
  
  ### apply function to perform operations
  treateddata<-percent_filter(statfiledata)
  
  p=ggplot(data=treateddata, aes(x=R1.bf.size, label =rownames(treateddata)))+ 
    
    geom_point(aes(y=R1_Filtred,color="R1_%_Filtred"), alpha=0.8, size=3) +
    geom_point(aes(y=R1_overlap,color="R1_%_overlap"), alpha=0.8, size=4) +
    geom_point(aes(y=R2_Filtred,color="R2_%_Filtred"), alpha=0.8, size=3) +
    geom_point(aes(y=R2_overlap,color="R2_%_overlap"), alpha=0.8, size=2) +
    scale_colour_manual("",
                        breaks = c("R1_%_Filtred","R1_%_overlap", "R2_%_Filtred","R2_%_overlap"),
                        values = c("black", "grey", "red",  "orange")) +
  
    ylab('%_of_good_quality_reads')+xlab('Sample Size (R1=R2) of raw reads')+
   labs(title=paste(statfilename))+
   theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5))+
   theme(panel.grid.major.x = element_line(colour = "blue",size=0.1, linetype = "dotted"))+
   theme(panel.grid.major.y = element_line(colour = "blue",size=0.1, linetype = "dotted"))
  
  ggsave(paste(statfilename, "pdf",sep="."), p, dpi=400)
  
  
  list_resumate[[paste(statfilename,sep="")]]<-as.data.frame(lapply(statfiledata,mean))
  
}

library(plyr)
all_stats=rbind.fill(list_resumate)
rownames(all_stats)<-names(list_resumate)
library(ggplot2)
library(reshape2)


### select the needed columns 

all_stats<-all_stats[,c(2,4,6,8,10)]
write.table(all_stats, "Resumate_Short_Stats.csv", sep = "\t", col.names=NA)

all_stats<-as.matrix(all_stats)
df2 <- melt(all_stats)
head(df2)

barplot.df2<-ggplot(df2, aes(x=Var1, y=value, fill=Var2)) +
  geom_bar(stat='identity', position='dodge')+
  labs(title = "\nThe length variation through  diffrent conditions of Quality && Overlapping \n")+
  theme(plot.title = element_text(size =14, face="bold", colour="black",hjust = 0.5))+
  theme(axis.line= element_line(colour="black", size=0.5, linetype="solid"))+
  theme(legend.key.size = unit(0.5, "cm"))+ 
  theme(legend.text= element_text(size =12, face="bold"))+
  theme(legend.box="vertical")+
  theme(legend.box.just='right')+
  theme(legend.title = element_blank())+
  theme(plot.background = element_rect(fill = "white"))+
  theme(axis.text = element_text(size="12", colour="black"))+
  theme(axis.title = element_text(face="bold", size="12", colour ="black"))+
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))+
  labs(x="Average Reads Length of samples per Quality Threshold && Overlap", y="Length in bp")
barplot.df2

ggsave(barplot.df2, filename = "Length_Variation_Barplots.pdf", width=16, height =8)


