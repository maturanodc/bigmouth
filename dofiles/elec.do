* IBGE Correspondence
import delimited using "${raw}codmun_tse_ibge.txt", clear encoding("UTF-8")
tempfile correspondencia
save `correspondencia'

* Presidential elections
* 2010 election
import delimited using "${raw}votacao_candidato_munzona_2010_BR", clear delimiter(";")
gen pt10 = qt_votos_nominais if nm_urna_candidato == "DILMA"
replace pt10 = 0 if nm_urna_candidato != "DILMA"
rename qt_votos_nominais votos10
gcollapse (sum) pt10 votos10, by(cd_municipio nr_turno)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren pt10 pt10_2t
ren votos10 votos10_2t
drop nr_turno
tempfile elec2010
save `elec2010'

restore 

keep if nr_turno == 1

ren pt10 pt10_1t
ren votos10 votos10_1t
drop nr_turno

merge 1:1 codmun7 using `elec2010', nogen		// Junta numa base com 1o e 2o turno

*	Cria fracao de votos validos e abstencoes por turno
gen pt_2010_1 = 100 * pt10_1t / votos10_1t
gen pt_2010_2 = 100 * pt10_2t / votos10_2t

keep pt_* nome_municipio codmun7 capital
tempfile elec2010
save `elec2010', replace

* 2014 election
import delimited using "${raw}votacao_candidato_munzona_2014_BR", clear delimiter(";")
gen pt14 = qt_votos_nominais if nm_urna_candidato == "DILMA"
replace pt14 = 0 if nm_urna_candidato != "DILMA"
rename qt_votos_nominais votos14
gcollapse (sum) pt14 votos14, by(cd_municipio nr_turno)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren pt14 pt14_2t
ren votos14 votos14_2t
drop nr_turno
tempfile elec2014
save `elec2014'

restore 

keep if nr_turno == 1

ren pt14 pt14_1t
ren votos14 votos14_1t
drop nr_turno

merge 1:1 codmun7 using `elec2014', nogen		// Junta numa base com 1o e 2o turno

*	Cria fracao de votos validos e abstencoes por turno
gen pt_2014_1 = 100 * pt14_1t / votos14_1t
gen pt_2014_2 = 100 * pt14_2t / votos14_2t

keep pt_* nome_municipio codmun7 capital
tempfile elec2014
save `elec2014', replace

* 2018 election
import delimited using "${raw}votacao_candidato_munzona_2018_BR", clear delimiter(";")
gen bolsonaro18 = qt_votos_nominais if nm_urna_candidato == "JAIR BOLSONARO"
replace bolsonaro18 = 0 if nm_urna_candidato != "JAIR BOLSONARO"
gen pt18 = qt_votos_nominais if nm_urna_candidato == "FERNANDO HADDAD"
replace pt18 = 0 if nm_urna_candidato != "FERNANDO HADDAD"
rename qt_votos_nominais_validos votos18
gcollapse (sum) bolsonaro18 pt18 votos18, by(cd_municipio nr_turno)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren bolsonaro18 bolsonaro18_2t
ren pt18 pt18_2t
ren votos18 votos18_2t
drop nr_turno
tempfile elec2018
save `elec2018'

restore 

keep if nr_turno == 1

ren bolsonaro18 bolsonaro18_1t
ren pt18 pt18_1t
ren votos18 votos18_1t
drop nr_turno

merge 1:1 codmun7 using `elec2018', nogen		// Junta numa base com 1o e 2o turno

gen bolsonaro_2018_1 = 100 * bolsonaro18_1t / votos18_1t
gen bolsonaro_2018_2 = 100 * bolsonaro18_2t / votos18_2t
gen pt_2018_1 = 100 * pt18_1t / votos18_1t
gen pt_2018_2 = 100 * pt18_2t / votos18_2t

keep bolsonaro_2018_1-pt_2018_2 nome_municipio codmun7 capital

tempfile elec2018
save `elec2018', replace

* 2022 election
import delimited using "${raw}votacao_candidato_munzona_2022_BR", clear delimiter(";")
gen bolsonaro22 = qt_votos_nominais if nm_urna_candidato == "JAIR BOLSONARO"
replace bolsonaro22 = 0 if nm_urna_candidato != "JAIR BOLSONARO"
rename qt_votos_nominais votos22
gcollapse (sum) bolsonaro22 votos22, by(cd_municipio nr_turno)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren bolsonaro22 bolsonaro22_2t
ren votos22 votos22_2t
drop nr_turno
tempfile elec2022
save `elec2022'

restore 

keep if nr_turno == 1

ren bolsonaro22 bolsonaro22_1t
ren votos22 votos22_1t
drop nr_turno

merge 1:1 codmun7 using `elec2022', nogen		// Junta numa base com 1o e 2o turno

gen bolsonaro_2022_1 = 100 * bolsonaro22_1t / votos22_1t
gen bolsonaro_2022_2 = 100 * bolsonaro22_2t / votos22_2t

keep bolsonaro_2022_1 bolsonaro_2022_2 nome_municipio codmun7 capital

tempfile elec2022
save `elec2022', replace

* Municipal elections
* Ideological party score
import delimited using "${raw}BLS9_full.csv", clear delimiter(",")
destring *, replace force
drop if lrclass == -999 | party_survey == -999 
ren party_survey nr_partido
replace nr_partido = 17 if nr_partido == 172
tostring wave, replace
gen year = substr(wave, 3,.)
gcollapse (mean) iscore = lrclass, by(nr_partido year)
reshape wide iscore, i(nr_partido) j(year) string
tempfile ideologia
save `ideologia'

* 2008 election 
import delimited using "${raw}votacao_candidato_munzona_2008_BRASIL.csv", clear delimiter(";")
keep if nr_turno == 1 & cd_cargo == 11
merge m:1 nr_partido using `ideologia'
gen x = (iscore09 >= 5.5) if _merge == 3
gen direita08 = qt_votos_nominais * x
ren qt_votos_nominais votos08
gcollapse (sum) direita08 votos08, by(cd_municipio)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

gen right_2008 = 100 * direita08 / votos08		// fracao de votos validos em prefeitos de direita

keep right_2008 nome_municipio codmun7 capital

tempfile elec2008
save `elec2008'

* 2012 election
import delimited using "${raw}votacao_candidato_munzona_2012_BRASIL.csv", clear delimiter(";")
keep if nr_turno == 1 & cd_cargo == 11
merge m:1 nr_partido using `ideologia'
gen x = (iscore13 >= 5.5) if _merge == 3
gen direita12 = qt_votos_nominais * x
ren qt_votos_nominais votos12
gcollapse (sum) direita12 votos12, by(cd_municipio)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

gen right_2012 = 100 * direita12 / votos12		// fracao de votos validos em prefeitos de direita

keep right_2012 nome_municipio codmun7 capital

tempfile elec2012
save `elec2012'

* 2016 election
import delimited using "${raw}votacao_candidato_munzona_2016_BRASIL.csv", clear delimiter(";")
keep if nr_turno == 1 & cd_cargo == 11
merge m:1 nr_partido using `ideologia'
gen x = (iscore17 >= 5.5) if _merge == 3
gen y = (iscore17 >= 7) if _merge == 3
gen z = (sg_partido == "PSC")
gen direita16 = qt_votos_nominais * x
gen edireita16 = qt_votos_nominais * y
gen psc16 = qt_votos_nominais * z
ren qt_votos_nominais votos16
gcollapse (sum) direita16 edireita16 psc16 votos16, by(cd_municipio)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

gen right_2016 = 100 * direita16 / votos16
gen farright_2016 = 100 * edireita16 / votos16
gen psc_2016 = 100 * psc16 / votos16
	
keep right_2016-psc_2016 nome_municipio codmun7 capital

tempfile elec2016
save `elec2016'

* 2020 election 
import delimited using "${raw}votacao_candidato_munzona_2020_BRASIL", clear delimiter(";")
keep if nr_turno == 1 & cd_cargo == 11
merge m:1 nr_partido using `ideologia'
gen x = (iscore21 >= 5.5) if _merge == 3
gen y = (iscore21 >= 7) if _merge == 3
gen z = (sg_partido == "PSL")
gen direita20 = qt_votos_nominais * x
gen edireita20 = qt_votos_nominais * y
gen psl20 = qt_votos_nominais * z
ren qt_votos_nominais votos20
gcollapse (sum) direita20 edireita20 psl20 votos20, by(cd_municipio)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

gen right_2020 = 100 * direita20 / votos20
gen farright_2020 = 100 * edireita20 / votos20
gen psl_2020 = 100 * psl20 / votos20
	
keep right_2020-psl_2020 nome_municipio codmun7 capital
	
tempfile elec2020
save `elec2020'


* State elections
* 2018 election
import delimited using "${raw}votacao_candidato_munzona_2018_BRASIL", clear delimiter(";")
keep if cd_cargo == 3 & ( ///
	sg_uf == "AC" | sg_uf == "AM" | sg_uf == "DF" | sg_uf == "ES" | ///
	sg_uf == "GO" | sg_uf == "MT" | sg_uf == "MG" | sg_uf == "PA" | ///
	sg_uf == "PB" | sg_uf == "PR" | sg_uf == "RJ" | sg_uf == "RN" | ///
	sg_uf == "RS" | sg_uf == "RO" | sg_uf == "RR" | sg_uf == "SC" )
gen x = (	///
	( nm_urna_candidato == "GLADSON CAMELI" & sg_uf == "AC" ) | ///				1
	( nm_urna_candidato == "WILSON LIMA" & sg_uf == "AM" ) | ///				2
	( nm_urna_candidato == "IBANEIS" & sg_uf == "DF" ) | ///					3
	( nm_urna_candidato == "RENATO CASAGRANDE" & sg_uf == "ES" ) | ///			4
	( nm_urna_candidato == "RONALDO CAIADO" & sg_uf == "GO" ) | ///				5
	( nm_urna_candidato == "MAURO MENDES" & sg_uf == "MT" ) | ///				6
	( nm_urna_candidato == "ROMEU ZEMA" & sg_uf == "MG" ) | ///					7
	( nm_urna_candidato == "HELDER" & sg_uf == "PA" ) | ///						8
	( nm_urna_candidato == "JOÃO" & sg_uf == "PB" ) | ///						9
	( nm_urna_candidato == "RATINHO JUNIOR" & sg_uf == "PR" ) | ///				10
	( nm_urna_candidato == "WILSON WITZEL" & sg_uf == "RJ" ) | ///				11
	( nm_urna_candidato == "FATIMA BEZERRA" & sg_uf == "RN" ) | ///				12
	( nm_urna_candidato == "EDUARDO LEITE" & sg_uf == "RS" ) | ///				13
	( nm_urna_candidato == "CORONEL MARCOS ROCHA" & sg_uf == "RO" ) | ///		14
	( nm_urna_candidato == "ANTONIO DENARIUM" & sg_uf == "RR" ) | ///			15
	( nm_urna_candidato == "COMANDANTE MOISÉS" & sg_uf == "SC" ) ///			16
)
gen gov18 = qt_votos_nominais * x
ren qt_votos_nominais votos18
gcollapse (sum) gov18 votos18 , by(cd_municipio nr_turno)

ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren gov18 gov18_2t
ren votos18 votos18_2t
drop nr_turno
tempfile elec2018g
save `elec2018g'

restore 

keep if nr_turno == 1

ren gov18 gov18_1t
ren votos18 votos18_1t
drop nr_turno

merge 1:1 codmun7 using `elec2018g', nogen		// Junta numa base com 1o e 2o turno

*	Cria fracao de votos validos e abstencoes por turno
gen gov_2018_1 = 100 * gov18_1t / votos18_1t
gen gov_2018_2 = 100 * gov18_2t / votos18_2t

keep gov_2018_1 gov_2018_2 nome_municipio codmun7 capital
tempfile elec2018g
save `elec2018g', replace

* 2022 election
import delimited using "${raw}votacao_candidato_munzona_2022_BRASIL", clear delimiter(";")
keep if cd_cargo == 3 & ( ///
	sg_uf == "AC" | sg_uf == "AM" | sg_uf == "DF" | sg_uf == "ES" | ///
	sg_uf == "GO" | sg_uf == "MT" | sg_uf == "MG" | sg_uf == "PA" | ///
	sg_uf == "PB" | sg_uf == "PR" | sg_uf == "RJ" | sg_uf == "RN" | ///
	sg_uf == "RS" | sg_uf == "RO" | sg_uf == "RR" | sg_uf == "SC" )
gen x = (	///
	( nm_urna_candidato == "GLADSON CAMELI" & sg_uf == "AC" ) | ///				1
	( nm_urna_candidato == "WILSON LIMA" & sg_uf == "AM" ) | ///				2
	( nm_urna_candidato == "IBANEIS ROCHA" & sg_uf == "DF" ) | ///				3
	( nm_urna_candidato == "RENATO CASAGRANDE" & sg_uf == "ES" ) | ///			4
	( nm_urna_candidato == "RONALDO CAIADO" & sg_uf == "GO" ) | ///				5
	( nm_urna_candidato == "MAURO MENDES" & sg_uf == "MT" ) | ///				6
	( nm_urna_candidato == "ZEMA" & sg_uf == "MG" ) | ///						7
	( nm_urna_candidato == "HELDER" & sg_uf == "PA" ) | ///						8
	( nm_urna_candidato == "JOÃO" & sg_uf == "PB" ) | ///						9
	( nm_urna_candidato == "CARLOS MASSA RATINHO JUNIOR" & sg_uf == "PR" ) | ///10
	( nm_urna_candidato == "CLÁUDIO CASTRO" & sg_uf == "RJ" ) | ///				11
	( nm_urna_candidato == "FATIMA BEZERRA" & sg_uf == "RN" ) | ///				12
	( nm_urna_candidato == "EDUARDO LEITE" & sg_uf == "RS" ) | ///				13
	( nm_urna_candidato == "CORONEL MARCOS ROCHA" & sg_uf == "RO" ) | ///		14
	( nm_urna_candidato == "ANTONIO DENARIUM" & sg_uf == "RR" ) | ///			15
	( nm_urna_candidato == "MOISÉS" & sg_uf == "SC" ) ///						16
)
gen gov22 = qt_votos_nominais * x
ren qt_votos_nominais votos22
gcollapse (sum) gov22 votos22 , by(cd_municipio nr_turno)


ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren gov22 gov22_2t
ren votos22 votos22_2t
drop nr_turno
tempfile elec2022g
save `elec2022g'

restore 

keep if nr_turno == 1

ren gov22 gov22_1t
ren votos22 votos22_1t
drop nr_turno

merge 1:1 codmun7 using `elec2022g', nogen		// Junta numa base com 1o e 2o turno

*	Cria fracao de votos validos e abstencoes por turno
gen gov_2022_1 = 100 * gov22_1t / votos22_1t
gen gov_2022_2 = 100 * gov22_2t / votos22_2t

keep gov_2022_1 gov_2022_2 nome_municipio codmun7 capital
tempfile elec2022g
save `elec2022g'

* Merging
use `elec2008', clear
merge 1:1 codmun7 using `elec2010', nogen
merge 1:1 codmun7 using `elec2012', nogen
merge 1:1 codmun7 using `elec2014', nogen
merge 1:1 codmun7 using `elec2016', nogen
merge 1:1 codmun7 using `elec2018', nogen
merge 1:1 codmun7 using `elec2018g', nogen
merge 1:1 codmun7 using `elec2020', nogen
merge 1:1 codmun7 using `elec2022', nogen
merge 1:1 codmun7 using `elec2022g', nogen

* Bolsonaro
gen bolso_1 = bolsonaro_2022_1 - bolsonaro_2018_1
gen bolso_2 = bolsonaro_2022_2 - bolsonaro_2018_2

* Rightwing mayors
gen right = right_2020 - right_2016
gen fright = farright_2020 - farright_2016
gen bparty = psl_2020 - psc_2016

* Incumbent governors
gen gov_1 = gov_2022_1 - gov_2018_1
gen gov_2 = gov_2022_2 - gov_2018_2

* Prior elections
gen vshare_1814_1 = pt_2018_1 - pt_2014_1
gen vshare_1814_2 = pt_2018_2 - pt_2014_2
gen vshare_1410_1 = pt_2014_1 - pt_2010_1
gen vshare_1410_2 = pt_2014_2 - pt_2010_2
gen vshare_1612 = right_2016 - right_2012
gen vshare_1208 = right_2012 - right_2008

keep codmun7 nome_municipio capital bolsonaro_* bolso_1-vshare_1208
save "${dat}elecs", replace