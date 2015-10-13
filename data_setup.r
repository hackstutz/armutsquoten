
library(data.table)
library(xlsx)
#poverty_orig <- as.data.table(read.table("C:/Users/Hackstutz/Dropbox/Git/bern_poverty/poverty.csv",header=TRUE,sep=";"))
#poverty_orig <- as.data.table(read.xlsx("C:/Users/Hackstutz/Dropbox/Git/armutsquoten/Poverty Tables/poverty.xlsx",1))
poverty <- as.data.table(read.table("C:/Users/Hackstutz/Dropbox/Git/armutsquoten/poverty_persons.csv",header=TRUE,sep=","))

#poverty[,relPov:=relPov1/(relPov1+relPov0)]
#poverty[,pov_rel_municip:=pov_rel_municip1/(pov_rel_municip1+pov_rel_municip0)]
#poverty[,absPov:=absPov1/(absPov1+absPov0)]

poverty[,abskat:=as.numeric(cut(poverty$absolutpoverty,breaks = c(-Inf,quantile(poverty$absolutpoverty,c(0.05,0.25,0.49,0.51,0.75,0.95)),Inf)))]
poverty[,relkat:=as.numeric(cut(poverty$relativeregionalpoverty,breaks = c(-Inf,quantile(poverty$relativeregionalpoverty,c(0.05,0.25,0.49,0.51,0.75,0.95)),Inf)))]
poverty[,diffkat:=as.numeric(cut(poverty$diff,breaks = c(-Inf,quantile(poverty$diff,c(0.02,0.04,0.06,0.08,0.4,0.7)),Inf)))]
poverty[Bevölkerung<100,c("absolutpoverty","relativeregionalpoverty","diff","abskat","relkat","diffkat"):=NA,with=FALSE]

write.table(poverty,file="C:/Users/Hackstutz/Dropbox/Git/armutsquoten/poverty_persons_kat.csv",sep=",",row.names = FALSE,na="")

# check legend min/max
poverty%>%filter(Bevölkerung>100) %>% summarise(min(absolutpoverty),min(relativeregionalpoverty),min(diff),max(absolutpoverty),max(relativeregionalpoverty),max(diff))

#min(absolutpoverty) min(relativeregionalpoverty) min(diff) max(absolutpoverty) max(relativeregionalpoverty)
#1:           0.3584229                     2.850356 -7.547169            16.66224                     20.52239
#max(diff)
#1:  18.28358


#poverty <- read.table("C:/Users/Hackstutz/Dropbox/Git/bern_poverty/poverty.tsv",header=TRUE)
