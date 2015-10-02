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

poverty<-read.csv("P:/WGS/FBS/ISS/Projekte laufend/SNF Ungleichheit/Valorisierung/Choropleth/armutsquoten/poverty_persons.csv")


## Shapefile GeoSchweiz laden

SchweizGeo<-readRDS("\\\\bfhfilerbe01.bfh.ch/hlo1/Desktop/Diss/Inhaltliches/Eigene Arbeit/Paper 3 - Non-Take-Up/Auswertungen/Syntax/Regionale Karte/SchweizGeo.rds")


# Shapefile auf Berner Gemeinden eingrenzen

SchweizGeo<-SchweizGeo[(SchweizGeo$id>300 & SchweizGeo$id<997),]



#### Match Datasets

SchweizGeo<-merge(SchweizGeo, poverty, by.x="id",by.y="id",all.x=TRUE)


SchweizGeo<-SchweizGeo[order(as.numeric(SchweizGeo$order)),]


##
# Explore the data

summary(SchweizGeo$absolutpoverty)
summary(SchweizGeo$relativepoverty)
summary(SchweizGeo$relativeregionalpoverty)


#################################
# Plot Maps
##################################

# Absolute Poverty
ggplot(SchweizGeo) + 
  aes(long,lat, group=group,fill=absolutpoverty) + 
  geom_polygon()+
  geom_path(color="black") +
  scale_fill_gradient2(low="#31a354",mid="grey90",high="#de2d26",midpoint=median(SchweizGeo$absolutpoverty,na.rm=TRUE))+
  coord_equal() +
  labs(fill="Absolute Armut") +
  theme_clean()
  
  
# Relative Poverty
ggplot(SchweizGeo) + 
  aes(long,lat, group=group,fill=relativepoverty) + 
  geom_polygon()+
  geom_path(color="black") +
  scale_fill_gradient2(low="#31a354",mid="grey90",high="#de2d26",midpoint=median(SchweizGeo$relativepoverty,na.rm=TRUE))+
  coord_equal() +
  labs(fill="Relative Armut") +
  theme_clean()

# Relative Poverty with regional wealth level
ggplot(SchweizGeo) + 
  aes(long,lat, group=group,fill=relativeregionalpoverty) + 
  geom_polygon()+
  geom_path(color="black") +
  scale_fill_gradient2(low="#31a354",mid="grey90",high="#de2d26",midpoint=median(SchweizGeo$relativeregionalpoverty,na.rm=TRUE))+
  coord_equal() +
  labs(fill="Relative Armut in Bezug \n in Bezug zum regionalen \n Wohlstandsniveau") +
  theme_clean()

# Change from absolute to relativ perspective
ggplot(SchweizGeo) + 
  aes(long,lat, group=group,fill=diff) + 
  geom_polygon()+
  geom_path(color="black") +
  scale_fill_gradient2(low="#de2d26",mid="grey90",high="#31a354",midpoint=median(SchweizGeo$diff,na.rm=TRUE))+
  coord_equal() +
  labs(fill="Differenz der Armutsquoten \n Absolut-RegRelativ") +
  theme_clean()



