library(data.table)
library(xlsx)
#poverty_orig <- as.data.table(read.table("C:/Users/Hackstutz/Dropbox/Git/bern_poverty/poverty.csv",header=TRUE,sep=";"))
poverty_orig <- as.data.table(read.xlsx("C:/Users/Hackstutz/Dropbox/Git/armutsquoten/Poverty Tables/poverty.xlsx",1))

poverty_orig[,relPov:=relPov1/(relPov1+relPov0)]
poverty_orig[,pov_rel_municip:=pov_rel_municip1/(pov_rel_municip1+pov_rel_municip0)]
poverty_orig[,absPov:=absPov1/(absPov1+absPov0)]
poverty_orig[,nHH:=relPov1+relPov0]
poverty_orig[nHH<50,c("relPov","absPov","pov_rel_municip"):=NA,with=FALSE]


write.table(poverty_orig,file="C:/Users/Hackstutz/Dropbox/Git/armutsquoten/poverty.tsv",sep="\t",row.names = FALSE,na="")
write.table(poverty_orig,file="C:/Users/Hackstutz/Dropbox/Git/armutsquoten/poverty.csv",sep=",",row.names = FALSE,na="")


poverty <- read.table("C:/Users/Hackstutz/Dropbox/Git/bern_poverty/poverty.tsv",header=TRUE)
