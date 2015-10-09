// program: 	poverty.do
// task: 		Calculate Poverty Measures for Bern
// project: 	Inequality in Switzerland
// Subprojet: 	Choropleth
// author(s):  	Oliver H�mbelin
// date:    	August-October 2015


** Working directory
cd "C:\Users\hlo1\Daten\Bern"


///// Data Prepartion

** Datensatz laden
clear
use "taxdata_BE.dta"
set more off

** Prepare Data

* Reduce to releva
keep if stj==2012

* Household charateristics
gen paare=1 
recode paare (1=2) if GEBURTSJAHR_P2>0 
gen anz_kinder = ANZAHL_KINDER + ANZAHL_UNTERSTUETZTE_PERS
gen age=2012-GEBURTSJAHR_P1

* Drop missing household ID
drop if hh_id==. 

** Collpase tax unit over households 

* Consider Ermtaxed 
collapse (max) BFS=BFS (sum) sumpaare=paare sumkind=anz_kinder sumtoteink=TOTEINK erm=erm sumverfeink=verfeink sumverfeinka=verfeinka sumtotverm=TOTVERM sumschulden=SCHULDEN sumverm_bew=VERM_bew (count) counthh=pid (max) oldestmember=age, by(hh_id)

* drop ermtaxed with only ermincome
drop if erm!=0 & sumverfeinka==0

* consider erm income as real income
*replace sumverfeink=sumverfeink+erm

** (inlcuding Ermtax, not considering their income but still counting them)
*collapse (max) BFS=BFS (sum) sumpaare=paare sumkind=anz_kinder sumtoteink=TOTEINK sumverfeink=verfeink sumverfeinka=verfeinka sumtotverm=TOTVERM sumschulden=SCHULDEN sumverm_bew=VERM_bew (count) counthh=pid (max) oldestmember=age, by(hh_id)

gen hhmitglieder=sumpaare+sumkind
replace hhmitglieder=round(hhmitglieder) 

* Drop poor youngster (who live from partents)
drop if oldestmember<26 

* Weil die Steuerdaten ebenfalls Kollektivhaushalte umfassen (Wohnheime, Altersheime etc.), die h�ufig f�r Verteilungsanalysen ausgeschlossen werden, werden Haushalte mit hoher Anzahl Haushaltsmitglieder ausgeschlossen
drop if hhmitglieder>8 /* betrifft 0.46 Prozent aller Haushalte */


///// Calculate Poverty measures 



// absoluter Ansatz
// gem�ss SKOS-Richtlinien Materielle grunsicherung (Pauschale+Wohnkosten(gemittelt f�r Hoch und Tiefpreisgemeinden)+medizinische Grundversorgung)

gen pov_abs=0
recode pov_abs (0=1) if hhmitglieder==1 & sumverfeink<12*(977+850+1*400)
recode pov_abs (0=1) if hhmitglieder==2 & sumverfeink<12*(1495+1100+2*400)
recode pov_abs (0=1) if hhmitglieder==3 & sumverfeink<12*(1818+1350+3*400)
recode pov_abs (0=1) if hhmitglieder==4 & sumverfeink<12*(2090+1550+4*400)
recode pov_abs (0=1) if hhmitglieder==5 & sumverfeink<12*(2364+1750+5*400)
recode pov_abs (0=1) if hhmitglieder==6 & sumverfeink<12*(2638+1800+6*400)
recode pov_abs (0=1) if hhmitglieder==7 & sumverfeink<12*(2912+1850+7*400)
recode pov_abs (0=1) if hhmitglieder==8 & sumverfeink<12*(2912+274+1900+8*400)

recode pov_abs (1=0) if sumverm_bew>10000 /* Personen mit mindestens 10'000 CHF beweglichem Verm�gen gelten nicht als arm */

tab pov_abs

// Output to Excel
*tab BFS pov_abs, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute H�ufigketen, rows=Value label BFS, col= Value label pov_abs */
*cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth\armutsquoten\Poverty Tables"
*putexcel A1=("Gemeinde") B1=("absPov0") C1=("absPov1")using "poverty.xlsx", replace
*putexcel A2=matrix(rows) B2=matrix(cell) using "poverty.xlsx", modify

// Relativer Ansatz - Medianes Einkommen Kanton 

gen verfeinka=sumverfeink + 0.05*(sumtotverm-sumschulden) 	/* inklusive 5% des Reinverm�gens */
replace verfeinka=verfeinka/1 		if hhmitglieder==1 		/* �quivalenzeinkommen berechnen Quadrat-Wurzel-Skala OECD */
replace verfeinka=verfeinka/1.41 	if hhmitglieder==2
replace verfeinka=verfeinka/1.73 	if hhmitglieder==3
replace verfeinka=verfeinka/2 		if hhmitglieder==4
replace verfeinka=verfeinka/2.24 	if hhmitglieder==5
replace verfeinka=verfeinka/2.45 	if hhmitglieder==6
replace verfeinka=verfeinka/2.65 	if hhmitglieder==7
replace verfeinka=verfeinka/2.83 	if hhmitglieder==8

sum verfeinka, d
gen pov_rel=cond(verfeinka<0.5*r(p50),1,0) 
tab pov_rel

// Output to Excel
*tab BFS pov_rel, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute H�ufigketen, rows=Value label BFS, col= Value label pov_abs */
*cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth\armutsquoten\Poverty Tables"
*putexcel D1=("relPov0") E1=("relPov1")using "poverty.xlsx", modify
*putexcel D2=matrix(cell) using "poverty.xlsx", modify

// Relativer Ansatz - Medianes Einkommen Kanton inklusive 5% des Reinverm�gens - Kommunale Median Einkommen

egen medianincome=median(verfeinka),by(BFS)
gen pov_rel_municip=cond(verfeinka<0.5*medianincome,1,0) 
tab pov_rel_municip

// Output to Excel
*tab BFS pov_rel_municip, row matcell(cell) matrow(rows) matcol(col) /* cell= absolute H�ufigketen, rows=Value label BFS, col= Value label pov_abs */
*cd "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth\armutsquoten\Poverty Tables"
*putexcel F1=("pov_rel_municip0") G1=("pov_rel_municip1")using "poverty.xlsx", modify
*putexcel F2=matrix(cell) using "poverty.xlsx", modify

// Transform housholdcounts to persons
replace pov_abs=pov_abs*hhmitglieder
replace pov_rel=pov_rel*hhmitglieder
replace pov_rel_municip=pov_rel_municip*hhmitglieder


// Collapse over municipalities 
collapse (sum) pov_abs=pov_abs pov_rel=pov_rel pov_rel_municip=pov_rel_municip Bev�lkerung=hhmitglieder (max) medianincome=medianincome, by(BFS)


// Calculate Poverty Quotas
gen absolutpoverty=pov_abs*100/Bev�lkerung
gen relativepoverty=pov_rel*100/Bev�lkerung
gen relativeregionalpoverty=pov_rel_municip*100/Bev�lkerung




//Labels

label define BFSlab ///
301	"	Aarberg	"	///
302	"	Bargen (BE)	"	///
303	"	Grossaffoltern	"	///
304	"	Kallnach	"	///
305	"	Kappelen	"	///
306	"	Lyss	"	///
307	"	Meikirch	"	///
309	"	Radelfingen	"	///
310	"	Rapperswil (BE)	"	///
311	"	Sch�pfen	"	///
312	"	Seedorf (BE)	"	///
321	"	Aarwangen	"	///
322	"	Auswil	"	///
323	"	Bannwil	"	///
324	"	Bleienbach	"	///
325	"	Busswil bei Melchnau	"	///
326	"	Gondiswil	"	///
329	"	Langenthal	"	///
331	"	Lotzwil	"	///
332	"	Madiswil	"	///
333	"	Melchnau	"	///
334	"	Obersteckholz	"	///
335	"	Oeschenbach	"	///
336	"	Reisiswil	"	///
337	"	Roggwil (BE)	"	///
338	"	Rohrbach	"	///
339	"	Rohrbachgraben	"	///
340	"	R�tschelen	"	///
341	"	Schwarzh�usern	"	///
342	"	Thunstetten	"	///
344	"	Ursenbach	"	///
345	"	Wynau	"	///
351	"	Bern	"	///
352	"	Bolligen	"	///
353	"	Bremgarten bei Bern	"	///
354	"	Kirchlindach	"	///
355	"	K�niz	"	///
356	"	Muri bei Bern	"	///
357	"	Oberbalm	"	///
358	"	Stettlen	"	///
359	"	Vechigen	"	///
360	"	Wohlen bei Bern	"	///
361	"	Zollikofen	"	///
362	"	Ittigen	"	///
363	"	Ostermundigen	"	///
371	"	Biel/Bienne	"	///
372	"	Evilard	"	///
381	"	Arch	"	///
382	"	B�etigen	"	///
383	"	B�ren an der Aare	"	///
385	"	Diessbach bei B�ren	"	///
386	"	Dotzigen	"	///
387	"	Lengnau (BE)	"	///
388	"	Leuzigen	"	///
389	"	Meienried	"	///
390	"	Meinisberg	"	///
391	"	Oberwil bei B�ren	"	///
392	"	Pieterlen	"	///
393	"	R�ti bei B�ren	"	///
394	"	Wengi	"	///
401	"	Aefligen	"	///
402	"	Alchenstorf	"	///
403	"	B�riswil	"	///
404	"	Burgdorf	"	///
405	"	Ersigen	"	///
406	"	Hasle bei Burgdorf	"	///
407	"	Heimiswil	"	///
408	"	Hellsau	"	///
409	"	Hindelbank	"	///
410	"	H�chstetten	"	///
411	"	Kernenried	"	///
412	"	Kirchberg (BE)	"	///
413	"	Koppigen	"	///
414	"	Krauchthal	"	///
415	"	Lyssach	"	///
416	"	M�tschwil	"	///
417	"	Nieder�sch	"	///
418	"	Oberburg	"	///
419	"	Ober�sch	"	///
420	"	R�dtligen-Alchenfl�h	"	///
421	"	Rumendingen	"	///
422	"	R�ti bei Lyssach	"	///
423	"	Willadingen	"	///
424	"	Wynigen	"	///
431	"	Corg�mont	"	///
432	"	Cormoret	"	///
433	"	Cort�bert	"	///
434	"	Courtelary	"	///
435	"	La Ferri�re	"	///
436	"	La Heutte	"	///
437	"	Mont-Tramelan	"	///
438	"	Orvin	"	///
439	"	P�ry	"	///
441	"	Renan (BE)	"	///
442	"	Romont (BE)	"	///
443	"	Saint-Imier	"	///
444	"	Sonceboz-Sombeval	"	///
445	"	Sonvilier	"	///
446	"	Tramelan	"	///
448	"	Villeret	"	///
449	"	Sauge	"	///
491	"	Br�ttelen	"	///
492	"	Erlach	"	///
493	"	Finsterhennen	"	///
494	"	Gals	"	///
495	"	Gampelen	"	///
496	"	Ins	"	///
497	"	L�scherz	"	///
498	"	M�ntschemier	"	///
499	"	Siselen	"	///
500	"	Treiten	"	///
501	"	Tschugg	"	///
502	"	Vinelz	"	///
532	"	Bangerten	"	///
533	"	B�tterkinden	"	///
535	"	Deisswil bei M�nchenbuchsee	"	///
536	"	Diemerswil	"	///
538	"	Fraubrunnen	"	///
540	"	Jegenstorf	"	///
541	"	Iffwil	"	///
543	"	Mattstetten	"	///
544	"	Moosseedorf	"	///
546	"	M�nchenbuchsee	"	///
551	"	Urtenen-Sch�nb�hl	"	///
552	"	Utzenstorf	"	///
553	"	Wiggiswil	"	///
554	"	Wiler bei Utzenstorf	"	///
556	"	Zielebach	"	///
557	"	Zuzwil (BE)	"	///
561	"	Adelboden	"	///
562	"	Aeschi bei Spiez	"	///
563	"	Frutigen	"	///
564	"	Kandergrund	"	///
565	"	Kandersteg	"	///
566	"	Krattigen	"	///
567	"	Reichenbach im Kandertal	"	///
571	"	Beatenberg	"	///
572	"	B�nigen	"	///
573	"	Brienz (BE)	"	///
574	"	Brienzwiler	"	///
575	"	D�rligen	"	///
576	"	Grindelwald	"	///
577	"	Gsteigwiler	"	///
578	"	G�ndlischwand	"	///
579	"	Habkern	"	///
580	"	Hofstetten bei Brienz	"	///
581	"	Interlaken	"	///
582	"	Iseltwald	"	///
584	"	Lauterbrunnen	"	///
585	"	Leissigen	"	///
586	"	L�tschental	"	///
587	"	Matten bei Interlaken	"	///
588	"	Niederried bei Interlaken	"	///
589	"	Oberried am Brienzersee	"	///
590	"	Ringgenberg (BE)	"	///
591	"	Saxeten	"	///
592	"	Schwanden bei Brienz	"	///
593	"	Unterseen	"	///
594	"	Wilderswil	"	///
602	"	Arni (BE)	"	///
603	"	Biglen	"	///
605	"	Bowil	"	///
606	"	Brenzikofen	"	///
607	"	Freimettigen	"	///
608	"	Grossh�chstetten	"	///
609	"	H�utligen	"	///
610	"	Herbligen	"	///
611	"	Kiesen	"	///
612	"	Konolfingen	"	///
613	"	Landiswil	"	///
614	"	Linden	"	///
615	"	Mirchel	"	///
616	"	M�nsingen	"	///
617	"	Niederh�nigen	"	///
619	"	Oberdiessbach	"	///
620	"	Oberthal	"	///
622	"	Oppligen	"	///
623	"	Rubigen	"	///
624	"	Schlosswil	"	///
625	"	T�gertschi	"	///
626	"	Walkringen	"	///
627	"	Worb	"	///
628	"	Z�ziwil	"	///
629	"	Oberh�nigen	"	///
630	"	Allmendingen	"	///
632	"	Wichtrach	"	///
661	"	Clavaleyres	"	///
662	"	Ferenbalm	"	///
663	"	Frauenkappelen	"	///
664	"	Golaten	"	///
665	"	Gurbr�	"	///
666	"	Kriechenwil	"	///
667	"	Laupen	"	///
668	"	M�hleberg	"	///
669	"	M�nchenwiler	"	///
670	"	Neuenegg	"	///
671	"	Wileroltigen	"	///
681	"	Belprahon	"	///
682	"	B�vilard	"	///
683	"	Champoz	"	///
684	"	Ch�telat	"	///
687	"	Corcelles (BE)	"	///
690	"	Court	"	///
691	"	Cr�mines	"	///
692	"	Eschert	"	///
694	"	Grandval	"	///
696	"	Loveresse	"	///
697	"	Malleray	"	///
699	"	Monible	"	///
700	"	Moutier	"	///
701	"	Perrefitte	"	///
702	"	Pontenet	"	///
703	"	Reconvilier	"	///
704	"	Roches (BE)	"	///
706	"	Saicourt	"	///
707	"	Saules (BE)	"	///
708	"	Schelten	"	///
709	"	Seehof	"	///
710	"	Sornetan	"	///
711	"	Sorvilier	"	///
712	"	Souboz	"	///
713	"	Tavannes	"	///
715	"	Reb�velier	"	///
723	"	La Neuveville	"	///
724	"	Nods	"	///
726	"	Plateau de Diesse	"	///
731	"	Aegerten	"	///
732	"	Bellmund	"	///
733	"	Br�gg	"	///
734	"	B�hl	"	///
735	"	Epsach	"	///
736	"	Hagneck	"	///
737	"	Hermrigen	"	///
738	"	Jens	"	///
739	"	Ipsach	"	///
740	"	Ligerz	"	///
741	"	Merzligen	"	///
742	"	M�rigen	"	///
743	"	Nidau	"	///
744	"	Orpund	"	///
745	"	Port	"	///
746	"	Safnern	"	///
747	"	Scheuren	"	///
748	"	Schwadernau	"	///
749	"	Studen (BE)	"	///
750	"	Sutz-Lattrigen	"	///
751	"	T�uffelen	"	///
754	"	Walperswil	"	///
755	"	Worben	"	///
756	"	Twann-T�scherz	"	///
761	"	D�rstetten	"	///
762	"	Diemtigen	"	///
763	"	Erlenbach im Simmental	"	///
766	"	Oberwil im Simmental	"	///
767	"	Reutigen	"	///
768	"	Spiez	"	///
769	"	Wimmis	"	///
770	"	Stocken-H�fen	"	///
782	"	Guttannen	"	///
783	"	Hasliberg	"	///
784	"	Innertkirchen	"	///
785	"	Meiringen	"	///
786	"	Schattenhalb	"	///
791	"	Boltigen	"	///
792	"	Lenk	"	///
793	"	St. Stephan	"	///
794	"	Zweisimmen	"	///
841	"	Gsteig	"	///
842	"	Lauenen	"	///
843	"	Saanen	"	///
852	"	Guggisberg	"	///
853	"	R�schegg	"	///
855	"	Schwarzenburg	"	///
861	"	Belp	"	///
863	"	Burgistein	"	///
865	"	Gelterfingen	"	///
866	"	Gerzensee	"	///
867	"	Gurzelen	"	///
868	"	Jaberg	"	///
869	"	Kaufdorf	"	///
870	"	Kehrsatz	"	///
872	"	Kirchdorf (BE)	"	///
873	"	Kirchenthurnen	"	///
874	"	Lohnstorf	"	///
875	"	M�hledorf (BE)	"	///
876	"	M�hlethurnen	"	///
877	"	Niedermuhlern	"	///
878	"	Noflen	"	///
879	"	Riggisberg	"	///
880	"	R�eggisberg	"	///
881	"	R�mligen	"	///
883	"	Seftigen	"	///
884	"	Toffen	"	///
885	"	Uttigen	"	///
886	"	Wattenwil	"	///
888	"	Wald (BE)	"	///
901	"	Eggiwil	"	///
902	"	Langnau im Emmental	"	///
903	"	Lauperswil	"	///
904	"	R�thenbach im Emmental	"	///
905	"	R�derswil	"	///
906	"	Schangnau	"	///
907	"	Signau	"	///
908	"	Trub	"	///
909	"	Trubschachen	"	///
921	"	Amsoldingen	"	///
922	"	Blumenstein	"	///
923	"	Buchholterberg	"	///
924	"	Eriz	"	///
925	"	Fahrni	"	///
927	"	Heiligenschwendi	"	///
928	"	Heimberg	"	///
929	"	Hilterfingen	"	///
931	"	Homberg	"	///
932	"	Horrenbach-Buchen	"	///
934	"	Oberhofen am Thunersee	"	///
935	"	Oberlangenegg	"	///
936	"	Pohlern	"	///
937	"	Schwendibach	"	///
938	"	Sigriswil	"	///
939	"	Steffisburg	"	///
940	"	Teuffenthal (BE)	"	///
941	"	Thierachern	"	///
942	"	Thun	"	///
943	"	Uebeschi	"	///
944	"	Uetendorf	"	///
945	"	Unterlangenegg	"	///
946	"	Wachseldorn	"	///
947	"	Zwieselberg	"	///
948	"	Forst-L�ngenb�hl	"	///
951	"	Affoltern im Emmental	"	///
952	"	D�rrenroth	"	///
953	"	Eriswil	"	///
954	"	Huttwil	"	///
955	"	L�tzelfl�h	"	///
956	"	R�egsau	"	///
957	"	Sumiswald	"	///
958	"	Trachselwald	"	///
959	"	Walterswil (BE)	"	///
960	"	Wyssachen	"	///
971	"	Attiswil	"	///
972	"	Berken	"	///
973	"	Bettenhausen	"	///
975	"	Farnern	"	///
976	"	Graben	"	///
977	"	Heimenhausen	"	///
978	"	Hermiswil	"	///
979	"	Herzogenbuchsee	"	///
980	"	Inkwil	"	///
981	"	Niederbipp	"	///
982	"	Nieder�nz	"	///
983	"	Oberbipp	"	///
985	"	Ochlenberg	"	///
987	"	Rumisberg	"	///
988	"	Seeberg	"	///
989	"	Th�rigen	"	///
990	"	Walliswil bei Niederbipp	"	///
991	"	Walliswil bei Wangen	"	///
992	"	Wangen an der Aare	"	///
993	"	Wangenried	"	///
995	"	Wiedlisbach	"	///
996	"	Wolfisberg	"	///
308	"	Niederried bei Kallnach	"	///
327	"	Gutenburg	"	///
328	"	Kleindietwil	"	///
330	"	Leimiswil	"	///
343	"	Untersteckholz	"	///
384	"	Busswil bei B�ren	"	///
440	"	Plagne	"	///
447	"	Vauffelin	"	///
531	"	Ballmoos	"	///
534	"	B�ren zum Hof	"	///
537	"	Etzelkofen	"	///
539	"	Grafenried	"	///
542	"	Limpach	"	///
545	"	M�lchi	"	///
547	"	M�nchringen	"	///
548	"	Ruppodsried	"	///
549	"	Schalunen	"	///
550	"	Scheunen	"	///
555	"	Zauggenried	"	///
601	"	Aeschlen	"	///
604	"	Bleiken bei Oberdiessbach	"	///
618	"	Niederwichtrach	"	///
621	"	Oberwichtrach	"	///
631	"	Trimstein	"	///
721	"	Diesse	"	///
722	"	Lamboing	"	///
725	"	Pr�les	"	///
752	"	T�scherz-Alferm�e	"	///
753	"	Twann	"	///
764	"	Niederstocken	"	///
765	"	Oberstocken	"	///
781	"	Gadmen	"	///
851	"	Albligen	"	///
854	"	Wahlern	"	///
862	"	Belpberg	"	///
864	"	Englisberg	"	///
871	"	Kienersr�ti	"	///
882	"	R�ti bei Riggisberg	"	///
887	"	Zimmerwald	"	///
926	"	Forst	"	///
930	"	H�fen	"	///
933	"	L�ngenb�hl	"	///
974	"	Bollodingen	"	///
984	"	Ober�nz	"	///
986	"	R�thenbach bei Herzogenbuchsee	"	///
994	"	Wanzwil	"	

label values BFS BFSlab 

gen id=BFS

// Generate variable that catches change from absolute to relative perspective
gen diff= relativeregionalpoverty-absolutpoverty  


// Drop Monible (many cases missing)
drop if absolutpoverty>80

export delimited using "P:\WGS\FBS\ISS\Projekte laufend\SNF Ungleichheit\Valorisierung\Choropleth\armutsquoten\poverty_persons.csv", replace





