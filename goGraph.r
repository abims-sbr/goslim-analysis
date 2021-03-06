#!/usr/bin/env Rscript

# inputs
#

library(ggplot2)
library(RColorBrewer)


wd = "/projet/fr2424/sib/lecorguille/11-03-Susana-GO-Sex/13-06-05-GO-Sex-Mutant/tmp"
datainfile = "DESeq_DE_results_Ec602-603_annotation_GO.goslim_pir.count.tab"


#wd = "/projet/fr2424/informatique/lecorguille/11-03-Susana-GO-Sex/13-06-31-PAR/tmp"
#datainfile = "GO_PAR.goslim_plant.count.tab"

display=T

argv <- commandArgs(TRUE)
if (length(argv) > 0) {
  datainfile = argv[1]
  display=F
} else {
  setwd(wd)
}



mypalette<-brewer.pal(3,"Set1")

data=read.table(datainfile, sep="\t", header=F); colnames(data) = c("GO","spacename","count")

data=merge(data[data$count>=0,], data[data$count<0,], by.x=1, by.y=1, all=T);
data$spacename.x[is.na(data$spacename.x)] = data$spacename.y[is.na(data$spacename.x)]
colnames(data)[colnames(data) == "spacename.x"] = "spacename"; data = data[,!(colnames(data) == "spacename.y")]

data[is.na(data)]=0

#ggplot(data, aes(x=reorder(GO,-(count.x+count.y)))) +
#  geom_bar(aes(y=count.x), position="identity",stat="identity", fill=mypalette[1], colour="black") +
#  geom_bar(aes(y=count.y), position="identity",stat="identity", fill=mypalette[3], colour="black") +
#  geom_text(aes(y=count.x,label=count.x),vjust=-0.5, colour=mypalette[1], size=3.5) +
#  geom_text(aes(y=count.y,label=(-1*count.y)),vjust=1.5, colour=mypalette[3], size=3.5) +
#  guides(fill = guide_legend(title = "FC"))+
#  theme_bw() +
#  theme(axis.text.x = element_text(angle=-90, hjust=0, vjust=0.5), plot.title = element_text(vjust=1.5), axis.title.x = element_blank(), axis.title.y = element_blank()) +
#  labs(title = datainfile)

if (!display) pdf(file=paste(datainfile,"pdf",sep="."), width=15, height=12)
for (spacename in unique(data$spacename)) {
  data_tmp=data[data$spacename==spacename,]

  gg = ggplot(data_tmp, aes(x=reorder(GO,-(count.x+count.y)))) +
    geom_bar(aes(y=count.x), position="identity",stat="identity", fill=mypalette[1], colour="black") +
    geom_text(aes(y=count.x,label=count.x),vjust=-0.5, colour=mypalette[1], size=3.5) +
    facet_grid(. ~ spacename, scales = "free", space = "free") +
    theme_bw() +
    theme(axis.text.x = element_text(angle=-90, hjust=0, vjust=0.5), plot.title = element_text(vjust=1.5), axis.title.x = element_blank(), axis.title.y = element_blank(), panel.grid.major = element_line(colour = "grey")) +
    labs(title = datainfile)

  if (sum(data_tmp$count.y) < 0) {
    gg = gg + geom_bar(aes(y=count.y), position="identity",stat="identity", fill=mypalette[3], colour="black")
    gg = gg + geom_text(aes(y=count.y,label=(-1*count.y)),vjust=1.5, colour=mypalette[3], size=3.5)
    gg = gg + expand_limits(y = c(min(data_tmp$count.y)-1,max(data_tmp$count.x)+1))
  } else {
    gg = gg + expand_limits(y = c(0,max(data_tmp$count.x)+1))
  }

  print(gg)
}
if (!display) dev.off()


