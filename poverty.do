// program: 	poverty.do
// task: 		Calculate Poverty Measures for Switzerland
// project: 	Inequality in Switzerland
// Subprojet: 	Choropleth
// author(s):  	Oliver Hümbelin
// date:    	August 2015


** Working directory
cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Schlussbericht\Daten\Bern\"


///// Data Prepartion

** Datensatz laden
clear
use "taxdata_BE.dta"
set more off

** Prepare Data

* Reduce to releva
keep if stj==2012

* Household
gen paare=1 
recode paare (1=2) if GEBURTSJAHR_P2>0 
gen anz_kinder = ANZAHL_KINDER + ANZAHL_UNTERSTUETZTE_PERS

* Drop missing household ID
drop if hh_id==. 

** Collpase tax unit over households
collapse (max) BFS=BFS (sum) sumpaare=paare sumkind=anz_kinder sumtoteink=TOTEINK sumverfeink=verfeink sumverfeinka=verfeinka sumtotverm=TOTVERM sumschulden=SCHULDEN sumverm_bew=VERM_bew (count) counthh=pid, by(hh_id)

gen hhmitglieder=sumpaare+sumkind
replace hhmitglieder=round(hhmitglieder) 

** Weil die Steuerdaten ebenfalls Kollektivhaushalte umfassen (Wohnheime, Altersheime etc.), die häufig für Verteilungsanalysen ausgeschlossen werden, werden Haushalte mit hoher Anzahl Haushaltsmitglieder ausgeschlossen

drop if hhmitglieder>8 /* betrifft 0.46 Prozent aller Haushalte */

///// Calculate Poverty measures 

// absoluter Ansatz
// gemäss SKOS-Richtlinien Materielle grunsicherung (Pauschale+Wohnkosten(gemittelt für Hoch und Tiefpreisgemeinden)+medizinische Grundversorgung)

gen pov_abs=0
recode pov_abs (0=1) if hhmitglieder==1 & sumtoteink<(977+850+1*400)
recode pov_abs (0=1) if hhmitglieder==2 & sumtoteink<(1495+1100+2*400)
recode pov_abs (0=1) if hhmitglieder==3 & sumtoteink<(1818+1350+3*400)
recode pov_abs (0=1) if hhmitglieder==4 & sumtoteink<(2090+1550+4*400)
recode pov_abs (0=1) if hhmitglieder==5 & sumtoteink<(2364+1750+5*400)
recode pov_abs (0=1) if hhmitglieder==6 & sumtoteink<(2638+1800+6*400)
recode pov_abs (0=1) if hhmitglieder==7 & sumtoteink<(2912+1850+7*400)
recode pov_abs (0=1) if hhmitglieder==8 & sumtoteink<(2912+274+1900+8*400)

// Output to Excel
tab BFS pov_abs, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute Häufigketen, rows=Value label BFS, col= Value label pov_abs */
cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth"
putexcel A1=("Gemeinde") B1=("absPov0") C1=("absPov1")using "poverty.xlsx", replace
putexcel A2=matrix(rows) B2=matrix(cell) using "poverty.xlsx", modify

// relativer Ansatz

drop verfeinka
gen verfeinka=. /* Äquivalenzeinkommen berechnen Quadrat-Wurzel-Skala OECD */
replace verfeinka=sumverfeink/1 	if hhmitglieder==1
replace verfeinka=sumverfeink/1.41 	if hhmitglieder==2
replace verfeinka=sumverfeink/1.73 	if hhmitglieder==3
replace verfeinka=sumverfeink/2 	if hhmitglieder==4
replace verfeinka=sumverfeink/2.24 	if hhmitglieder==5
replace verfeinka=sumverfeink/2.45 	if hhmitglieder==6
replace verfeinka=sumverfeink/2.65 	if hhmitglieder==7
replace verfeinka=sumverfeink/2.83 	if hhmitglieder==8

sum verfeinka, d
gen pov_rel=cond(verfeinka<0.6*r(p50),1,0) 
tab pov_rel

// Output to Excel
tab BFS pov_rel, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute Häufigketen, rows=Value label BFS, col= Value label pov_abs */
cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth"
putexcel D1=("relPov0") E1=("relPov1")using "poverty.xlsx", modify
putexcel D2=matrix(cell) using "poverty.xlsx", modify

// mit Prüfung der Bedürftigkeit

gen reinverm=sumtotverm+sumschulden
gen pov_absVerm=cond(reinverm>100000,0,pov_abs)

// Output to Excel
tab BFS pov_absVerm, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute Häufigketen, rows=Value label BFS, col= Value label pov_abs */
cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth"
putexcel F1=("pov_absVerm0") G1=("pov_absVerm1")using "poverty.xlsx", modify
putexcel F2=matrix(cell) using "poverty.xlsx", modify

