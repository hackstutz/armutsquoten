################################################################
## task:        Plot Regional Poverty Maps
## project:     Inequality of Income and Wealth
## subproject:  Poverty Map
## author:      Oliver Hümbelin
## date:        September2015
####################################


## library
library(ggplot2)



## Clean-Theme

theme_clean<-function(base_size=12) {
  require(grid)
  theme_grey(base_size)
  theme(
    axis.title=element_blank(),
    axis.text=element_blank(),
    panel.background=element_blank(),
    panel.grid=element_blank(),
    axis.ticks.length=unit(0,"cm"),
    axis.ticks.margin=unit(0,"cm"),
    panel.margin=unit(0,"lines"),
    plot.margin=unit(c(0,0,0,0),"lines"),
    complete=TRUE
  )
}


#################################
# Datapreparation
##################################


#### Load Data

## Gemeindedaten-Nontake-daten

poverty<-read.dta("P:/WGS/FBS/ISS/Projekte laufend/SNF Ungleichheit/Valorisierung/Choropleth/armutsquoten/Poverty Tables/poverty")


## Shapefile GeoSchweiz laden

SchweizGeo<-readRDS("\\\\bfhfilerbe01.bfh.ch/hlo1/Desktop/Diss/Inhaltliches/Eigene Arbeit/Paper 3 - Non-Take-Up/Auswertungen/Syntax/Regionale Karte/SchweizGeo.rds")


# Shapefile auf Berner Gemeinden eingrenzen

SchweizGeo<-SchweizGeo[(SchweizGeo$id>300 & SchweizGeo$id<997),]



#### Match Datasets

SchweizGeo<-merge(SchweizGeo, nontakeup, by.x="id",by.y="bfs",all.x=TRUE)


SchweizGeo<-SchweizGeo[order(as.numeric(SchweizGeo$order)),]





#################################
# Plot Maps
##################################


## Version 1

ggplot(SchweizGeo) + 
  aes(long,lat, group=group,fill=nontakeup) + 
  geom_polygon()+
  geom_path(color="black") +
  scale_fill_gradient2(low="#de2d26",mid="grey90",high="#31a354",midpoint=median(SchweizGeo$nontakeup,na.rm=TRUE))+
  coord_equal() +
  labs(fill="Nichtbezugsquote") +
  theme_clean()