**# Census data

* 2022 Census
* Number of residents per municipality
import delimited "${raw}tabela4714_populacao.csv", clear delimiter(",")
drop if _n < 5 | _n > 5574
destring v1, gen(codmun7)
destring v3, gen(populacao)
gen codmun6 = trunc(codmun7/10)
drop v*
tempfile id
save `id'

* Densidade populacional
import delimited "${raw}tabela4714_densidade.csv", clear delimiter(",")
drop if _n < 5 | _n > 5574
destring v1, gen(codmun7)
destring v3, gen(density)
drop v*
merge 1:1 codmun7 using `id', nogen

save "${dat}id.dta", replace

* 2010 Census
foreach b in "11" "12" "13" "14" "15" "16" "17" "21" "22" "23" "24" ///
	"25" "26" "27" "28" "29" "31" "32" "33" "35_outras" "35_rmsp" ///
	"41" "42" "43" "50" "51" "52" "53" {
	
	use "${cap}amostra_pessoas_`b'" , clear
	rename V0001 uf
	generate double codmun7 = uf * 10^5 + V0002
	generate urbano = V1006 == 1
	generate masculino = V0601 == 1
	generate crianca = inrange(V6036,0,14)
	generate jovem = inrange(V6036,15,29)
	generate adulto = inrange(V6036,30,59)
	generate idoso = inrange(V6036,60,.)
	generate branco = V0606 == 1 if V0606 != 9
	generate preto = V0606 == 2 if V0606 != 9
	generate amarelo = V0606 == 3 if V0606 != 9
	generate pardo = V0606 == 4 if V0606 != 9
	generate indigena = V0606 == 5 if V0606 != 9
	generate sabe_ler = V0627 == 1 if V0627 != .
	generate ef1_completo = (V0629 > 6 & V0629 !=.) | ///
		((V0629 == 5 | V0629 == 6) & V0630 > 5 & V0630 != . & V0629 != .) | ///
		(V0633 > 4 & V0634 == 1 & V0633 != . & V0634 != .)
	generate ef2_completo = (V0629 > 6 & V0629 !=.) | ///
		(V0633 > 6 & V0634 == 1 & V0633 != . & V0634 != .)
	generate em_completo = (V0629 > 9 & V0629 !=.) | ///
		(V0633 > 8 & V0634 == 1 & V0633 != . & V0634 != .)
	generate es_completo = (V0629 > 10 & V0629 !=.) | ///
		(V0633 > 10 & V0634 == 1 & V0633 != . & V0634 != .)
	generate rendimento_pessoa = V6527
	generate rendimento_domicilio = V6529
	generate horastrabalho = V0653
	generate buscatrabalho = V0654 == 1 if V0654 != .
	generate beneficiario = (V0656 == 1 | V0657 == 1 | V0658 == 1) if ///
		V0656 != 9 & V0656 != . & V0657 != 9 & V0657 != . & V0658 != 9 & V0658 != .
	generate trabalhafora = V0660 > 2 if V0660 != .
	generate retornadiar = V0661 == 1 if V0661 != .
	generate fecundidade = V6633
	generate pea = V6900 == 1 if V6900 != .
	generate trabformal = (V6930 == 1 | V6930 == 2) if V6930 != .
	generate funcionpub = V6930 == 2 if V6930 != .
	generate trabinformal = (V6930 == 3 | V6930 == 4 | V6930 == 6 | V6930 == 7) if V6930 != .
	generate employers = V6930 == 3 if V6930 != .
	generate evangelicos = V6121 > 200 & V6121 < 500
	generate migrante = !missing(V0622)
	generate idademedia = V6036
	
	generate gini = .
	sort codmun7
	levelsof codmun7, local(codlist)
	qui: ineqdec0 V6531 [aw = V0010], by(codmun7)
	foreach i of local codlist {
		replace gini = r(gini_`i') if codmun7 == `i'
	}
	
	gcollapse (mean) urbano-gini [iw=V0010] , by(codmun7)
	
	tempfile pessoas_`b'
	save `pessoas_`b''
}

foreach b in "11" "12" "13" "14" "15" "16" "17" "21" "22" "23" "24" ///
	"25" "26" "27" "28" "29" "31" "32" "33" "35_outras" "35_rmsp" ///
	"41" "42" "43" "50" "51" "52" "53" {

	use "${cad}Amostra_Domicilios_`b'" , clear
	rename V0001 uf
	generate double codmun7 = uf * 10^5 + V0002
	generate privado = (V4001 == 1 | V4001 == 2)
	generate improvisado = V4001 == 5
	generate coletivo = V4001 == 6
	generate casa = (V4002 == 11 | V4002 == 12)
	generate apartamento = (V4002 == 13)
	generate residnconv = inrange(V4002,14,.)
	generate casapropria = (V0201 == 1 | V0201 == 2) if V0201 != .
	generate aluguel = V0201 == 3 if V0201 != .
	generate valaluguel = V2011
	generate outrosmot = inrange(V0201,4,6) if V0201 != .
	generate saneamento = (V0205 > 0 | V0206 == 1) & (V0207 == 1 | V0207 == 2) if V0207 != .
	replace saneamento = 0 if V0206 == 2 & V0207 == .
	generate aguaencanada = (V0209 == 1 | V0209 == 2) if V0209 != .
	generate coletalixo = (V0210 == 1 | V0210 == 2) if V0210 != .
	generate eletricidade = (V0211 == 1| V0211 == 2) if V0211 != .
	generate radio = (V0213 == 1) if V0213 != .
	generate tv = (V0214 == 1) if V0214 != .
	generate lavaroupa = (V0215 == 1) if V0215 != .
	generate geladeira = (V0216 == 1) if V0216 != .
	generate telefone = (V0217 == 1 | V0218 == 1) if (V0217 != . & V0218 != .)
	generate computador = V0219 == 1 if V0219 != .
	generate internet = V0220 == 1 if V0220 != .
	replace internet = 0 if computador == 0
	generate veiculo = (V0221 == 1 | V0222 == 1) if V0221 != . & V0222 != .
	generate dens_morador = V6203
	
	gcollapse (mean) privado-dens_morador [iw=V0010] , by(codmun7)
	
	tempfile domicilio_`b'
	save `domicilio_`b''
	
	}

* Merge
foreach b in "11" "12" "13" "14" "15" "16" "17" "21" "22" "23" "24" ///
	"25" "26" "27" "28" "29" "31" "32" "33" "35_outras" "35_rmsp" ///
	"41" "42" "43" "50" "51" "52" "53" {
	
	use `pessoas_`b'', clear
	join , from(`domicilio_`b'') by(codmun7) unique nogen
	tempfile censo_`b'
	save `censo_`b''
	
}

clear
foreach b in "11" "12" "13" "14" "15" "16" "17" "21" "22" "23" "24" ///
	"25" "26" "27" "28" "29" "31" "32" "33" "35_outras" "35_rmsp" ///
	"41" "42" "43" "50" "51" "52" "53" {
	
	append using `censo_`b''

}

la var urbano "Share of urban pop."
la var masculino "Share of male pop."
la var crianca "Share of < 15 yo pop."
la var jovem "Share of 15 |- 30 yo pop."
la var adulto "Share of 30 |- 60 yo pop."
la var idoso "Share of >= 60 yo pop."
la var branco "Share of white pop."
la var preto "Share of black pop."
la var amarelo "Share of yellow pop."
la var pardo "Share of mixed race pop."
la var indigena "Share of indigenous pop."
la var sabe_ler "Share of lieterate pop."
la var ef1_completo "Share of Elementary-School educated pop."
la var ef2_completo "Share of Middle-School educated pop."
la var em_completo "Share of High-School educated pop."
la var es_completo "Share of University educated pop."
la var rendimento_pessoa "Average total personal income"
la var rendimento_domicilio "Avearge total household income"
la var horastrabalho "Average total working hours per week"
la var buscatrabalho "Share of pop. looking for work"
la var beneficiario "Share of pop. receiving government benefits"
la var trabalhafora "Share of pop. who commute to work"
la var retornadiar "Share of pop. who go to and back from work daily"
la var fecundidade "Average number of children per woman"
la var pea "Share of pop. in the workforce"
la var trabformal "Share of workforce formally employed"
la var funcionpub "Share of workforce employed by the public sector"
la var trabinformal "Share of workforce informally employed"
la var evangelicos "Share of evangelicals of any denomination"
la var migrante "Share of migrants at state"
la var gini "Household per capita income Gini-index"
la var idademedia "Average age of pop."
la var privado "Share of households in private residences"
la var improvisado "Share of households in improvised residences"
la var coletivo "Share of households in colective residences"
la var casa "Share of households located at houses"
la var apartamento "Share of households located at apartment complexes"
la var residnconv "Share of households in non conventional households"
la var casapropria "Share of households who own their residence"
la var aluguel "Share of households renting their residence"
la var valaluguel "Mean expenditure on rents"
la var outrosmot "Share of households who do not own or rent their residence"
la var saneamento "Share of households served by the waste disposal network"
la var aguaencanada "Share of households served by the water distribution network"
la var coletalixo "Share of households served by the garbage disposal network"
la var eletricidade "Share of households with access to electricity"
la var radio "Share of households who own a radio"
la var tv "Share of households who own a television"
la var lavaroupa "Share of households who own a washing machine"
la var geladeira "Share of households who own a fridge"
la var telefone "Share of households who own a phone"
la var computador "Share of households who own a computer"
la var internet "Share of households with access to the internet"
la var veiculo "Share of households who own a vehicle"
la var dens_morador "Average density of households' rooms"

save "${dat}census.dta", replace

**# Geography
import excel using "${raw}RELATORIO_DTB_BRASIL_MUNICIPIO.xlsx", ///
	sheet("DTB_2022_Municipio") cellrange(A7:M5577) firstrow clear
keep RegiãoGeográficaIntermediária RegiãoGeográficaImediata CódigoMunicípioCompleto UF
destring *, replace
rename RegiãoGeográficaIntermediária meso
rename RegiãoGeográficaImediata micro
rename CódigoMunicípioCompleto codmun7
rename UF uf
gen macro = trunc(uf/10)
gen codmun6 = trunc(codmun7/10)

join, from("${dat}id") by(codmun6 codmun7) nogen unique
join, from("${dat}distancias.dta") by(codmun7) nogen unique
join, from("${dat}contato.dta") by(codmun7) nogen unique

* Identify NLM
sort codmun6
levelsof codmun6, local(codlist)

gen distance = .
gen borders = .
gen z = .
foreach i of local codlist {
	egen x1 = min(dist_`i') if populacao > 50000 & codmun6 != `i'
	egen x2 = max(x1)
	replace distance = x2 if codmun6 == `i'
	
	gen x3 = codmun6 if x1 == dist_`i'
	egen x4 = max(x3)
	local v = x4
	replace borders = (adj_`v' == 1) if codmun6 == `i'
		
	gen x5 = meso if x1 == dist_`i'
	egen x6 = max(x5)
	replace z = x6 if codmun6 == `i'
		
	drop x* 
}
	
gen ldist = ln(distance)
gen samereg = (meso == z)
	
la var distance "Distance to NLM (km)"
la var ldist "Ln distance to NLM"
la var borders "Dummy for munic. bordering NLM"
la var samereg "Dummy for munic. in same region of NLM"
	
drop z

foreach a in "25" "100" {
	
	gen distance_alt`a' = .
	gen borders_alt`a' = .
	gen z = .
	foreach i of local codlist {
		egen x1 = min(dist_`i') if populacao > `a'000 & codmun6 != `i'
		egen x2 = max(x1)
		replace distance_alt`a' = x2 if codmun6 == `i'
		
		gen x3 = codmun6 if x1 == dist_`i'
		egen x4 = max(x3)
		local v = x4
		replace borders_alt`a' = (adj_`v' == 1) if codmun6 == `i'
			
		gen x5 = meso if x1 == dist_`i'
		egen x6 = max(x5)
		replace z = x6 if codmun6 == `i'
			
		drop x* 
	}
		
	gen ldist_alt`a' = ln(distance_alt`a')
	gen samereg_alt`a' = (meso == z)
	drop distance_alt`a'
		
	la var ldist_alt`a' "Ln distance to alternative NLM (`a' pop.)"
	la var borders_alt`a' "Dummy for munic. bordering alternative NLM (`a' pop.)"
	la var samereg_alt`a' "Dummy for munic. in same region of alternative NLM (`a' pop.)"
	
drop z
	
}

keep codmun7 codmun6 micro meso uf macro distance-samereg_alt100 lat lon
save "${dat}geografia.dta", replace

**# Mortality data
forval t = 2008/2022 {
	import delimited using "${raw}Mortalidade_Geral_`t'.csv", ///
		delimiter(";") varnames(1) encoding(utf8) clear
	
	tostring dtobito, gen(x)
	gen y = trunc(dtobito/10^7)
	replace x = "0" + x if y == 0
	gen date = date(x, "DMY")
	
	gen covid19 = causabas == "B342"
	gen allelse = causabas != "B342"
		
	keep date codmunres covid19 allelse
	rename codmunres codmun6
	
	preserve
	
	gcollapse (sum) allelse , by(codmun6)
	gen year = `t'
	save "${dat}sim_`t'_year", replace
	
	restore 
	
	if `t' > 2019 {
	gcollapse (sum) covid19 , by(codmun6 date)
	
	save "${dat}sim_`t'_dia", replace
	
	}
}

clear
forval t = 2008/2022 {
	append using "${dat}sim_`t'_year"
}
greshape wide allelse, i(codmun6) j(year)
tempfile allelse
save `allelse'

clear
forval t = 2020/2022 {
	append using "${dat}sim_`t'_dia"
}
join, from(`allelse') by(codmun6) keep(3) nogen
save "${dat}mortes" , replace

* Vaccine data
import delimited using ///
	"${raw}part-00000-7ac67d00-ef1a-4ce3-89b2-486f806d5027-c000.csv", ///
	delimiter(";") encoding(utf8) varnames(1) clear
gen date = date(vacina_dataaplicacao, "YMD")
keep paciente_endereco_coibge date
destring paciente_endereco_coibge, gen(codmun6) force
drop if missing(codmun6)
gen vacina = 1
gcollapse (sum) vacina, by(codmun6 date)
save "${dat}vacina" , replace

* Infection data
foreach i in "2020_Parte1" "2020_Parte2" "2021_Parte1" "2021_Parte2" ///
	"2022_Parte1" "2022_Parte2" {
	import delimited using "${raw}HIST_PAINEL_COVIDBR_`i'_08set2023", clear delimiter(";")
	keep if codmun != . & municipio != ""
	ren codmun codmun6
	gen date = date(data, "YMD")
	keep codmun6 date casosnovos
	tempfile b`i'
	save `b`i''
}

clear
foreach i in "2020_Parte1" "2020_Parte2" "2021_Parte1" "2021_Parte2" ///
	"2022_Parte1" "2022_Parte2" {
	append using `b`i''
}

forval t = 23009(-1)22001 {
	local k = `t' + 1
	
	replace casos = casos[_n] + casos[_n + 1] if casos[_n + 1] < 0 & date == `t'
	replace casos = 0 if casos[_n ] < 0 & date == `k'
	
}
save "${dat}casos", replace

use "${dat}mortes", clear
join , into("${dat}casos") by(codmun6 date) unique nogen
join , into("${dat}vacina") by(codmun6 date) unique nogen

foreach v of varlist casos covid19 vacina allelse* {
	replace `v' = 0 if `v' == .
}

replace casos = 0 if date < 21971 // First infection in Brazil, 26Feb2020
replace covid = 0 if date < 21986 // First death in Brazil, 12Mar2020
replace vacin = 0 if date < 22297 // First vaccine in Brazil, 17Jan2021

sort codmun6 date

forval i = 2008/2022 {
	local j = `i' - 2007
	by codmun6: egen x_`j' = max(allelse`i')
	replace allelse`i' = x_`j' 
}
by codmun6: egen x_16 = min(date) if casos > 0
by codmun6: egen firstinfec = max(x_16)
by codmun6: egen x_17 = min(date) if covid19 > 0
by codmun6: egen firstcovid = max(x_17)
by codmun6: egen x_18 = min(date) if vacina > 0
by codmun6: egen firstvaccine = max(x_18)
format %td firstinfec firstcovid firstvaccine
drop x_*

gen pre20 = (date <= 22233)		// 14/11/2020
gen pre22 = (date <= 22919)		// 01/10/2022

gen covid = covid19 * pre22
gen covid_alt = covid19 * pre20
gen infec = casos * pre22
gen infec_alt = casos * pre20

gcollapse (sum) covid-infec_alt, ///
	by(codmun6 firstinfec firstcovid firstvaccine allelse*)
	
join populacao, from("${dat}id") unique nogen keep(3) by(codmun6)

foreach v of varlist allelse2008-allelse2022 covid-infec_alt {
	replace `v' = 100000 * `v' / populacao
}
drop populacao
gen delay_di = firstcovid - firstinfec
gen delay_dv = firstvaccine - firstcovid
gen delay_vi = firstvaccine - firstinfec

save "${dat}covid", replace


**# Election data
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
import delimited using "${raw}detalhe_votacao_munzona_2018_BR", clear delimiter(";")
gen nvalidos18 = qt_votos_brancos + qt_votos_nulos 
gcollapse (sum) nvalidos18, by(cd_municipio nr_turno)
	tempfile detalhe
	save `detalhe', replace

import delimited using "${raw}votacao_candidato_munzona_2018_BR", clear delimiter(";")
gen bolsonaro18 = qt_votos_nominais if nm_urna_candidato == "JAIR BOLSONARO"
replace bolsonaro18 = 0 if nm_urna_candidato != "JAIR BOLSONARO"
gen pt18 = qt_votos_nominais if nm_urna_candidato == "FERNANDO HADDAD"
replace pt18 = 0 if nm_urna_candidato != "FERNANDO HADDAD"
gen pdt18 = qt_votos_nominais if nm_urna_candidato == "CIRO GOMES"
replace pdt18 = 0 if nm_urna_candidato != "CIRO GOMES"
gen novo18 = qt_votos_nominais if nm_urna_candidato == "JOÃO AMOÊDO"
replace novo18 = 0 if nm_urna_candidato != "JOÃO AMOÊDO"
gen mdb18 = qt_votos_nominais if nm_urna_candidato == "HENRIQUE MEIRELLES"
replace mdb18 = 0 if nm_urna_candidato != "HENRIQUE MEIRELLES"
gen dc18 = qt_votos_nominais if nm_urna_candidato == "EYMAEL"
replace dc18 = 0 if nm_urna_candidato != "EYMAEL"
gen pstu18 = qt_votos_nominais if nm_urna_candidato == "VERA"
replace pstu18 = 0 if nm_urna_candidato != "VERA"
rename qt_votos_nominais_validos votos18
gcollapse (sum) bolsonaro18-pstu18 votos18, by(cd_municipio nr_turno)

merge 1:1 cd_municipio nr_turno using `detalhe', keep(match) nogen		// identificando todos os votos cast por municipio
ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren bolsonaro18 bolsonaro18_2t
ren pt18 pt18_2t
ren pdt18 pdt18_2t
ren novo18 novo18_2t
ren mdb18 mdb18_2t
ren dc18 dc18_2t
ren pstu18 pstu18_2t
ren votos18 votos18_2t
ren nvalidos18 nvalidos18_2t
drop nr_turno
tempfile elec2018
save `elec2018'

restore 

keep if nr_turno == 1

ren bolsonaro18 bolsonaro18_1t
ren pt18 pt18_1t
ren pdt18 pdt18_1t
ren novo18 novo18_1t
ren mdb18 mdb18_1t
ren dc18 dc18_1t
ren pstu18 pstu18_1t
ren votos18 votos18_1t
ren nvalidos18 nvalidos18_1t
drop nr_turno

merge 1:1 codmun7 using `elec2018', nogen		// Junta numa base com 1o e 2o turno

gen bolsonaro_2018_1 = 100 * bolsonaro18_1t / votos18_1t
gen bolsonaro_2018_2 = 100 * bolsonaro18_2t / votos18_2t
gen pt_2018_1 = 100 * pt18_1t / votos18_1t
gen pt_2018_2 = 100 * pt18_2t / votos18_2t
gen pdt_2018_1 = 100 * pdt18_1t / votos18_1t
gen novo_2018_1 = 100 * novo18_1t / votos18_1t
gen mdb_2018_1 = 100 * mdb18_1t / votos18_1t
gen dc_2018_1 = 100 * dc18_1t / votos18_1t
gen pstu_2018_1 = 100 * pstu18_1t / votos18_1t
gen null_2018_1 = 100 * nvalidos18_1t / (nvalidos18_1t + votos18_1t)
gen null_2018_2 = 100 * nvalidos18_2t / (nvalidos18_2t + votos18_2t)

keep bolsonaro_2018_1-null_2018_2 nome_municipio codmun7 capital

tempfile elec2018
save `elec2018', replace

* 2022 election
import delimited using "${raw}detalhe_votacao_munzona_2022_BR", clear delimiter(";")
gen nvalidos22 = qt_votos_brancos + qt_votos_nulos 
gcollapse (sum) nvalidos22, by(cd_municipio nr_turno)
	tempfile detalhe
	save `detalhe', replace
import delimited using "${raw}votacao_candidato_munzona_2022_BR", clear delimiter(";")
gen bolsonaro22 = qt_votos_nominais if nm_urna_candidato == "JAIR BOLSONARO"
replace bolsonaro22 = 0 if nm_urna_candidato != "JAIR BOLSONARO"
gen pt22 = qt_votos_nominais if sg_partido == "PT"
replace pt22 = 0 if sg_partido != "PT"
gen pdt22 = qt_votos_nominais if sg_partido == "PDT"
replace pdt22 = 0 if sg_partido != "PDT"
gen novo22 = qt_votos_nominais if sg_partido == "NOVO"
replace novo22 = 0 if sg_partido != "NOVO"
gen mdb22 = qt_votos_nominais if sg_partido == "MDB"
replace mdb22 = 0 if sg_partido != "MDB"
gen dc22 = qt_votos_nominais if sg_partido == "DC"
replace dc22 = 0 if sg_partido != "DC"
gen pstu22 = qt_votos_nominais if sg_partido == "PSTU"
replace pstu22 = 0 if sg_partido != "PSTU"
rename qt_votos_nominais votos22
gcollapse (sum) bolsonaro22-pstu22 votos22, by(cd_municipio nr_turno)

merge 1:1 cd_municipio nr_turno using `detalhe', keep(match) nogen		// identificando todos os votos cast por municipio
ren cd_municipio codigo_tse
merge m:1 codigo_tse using `correspondencia', keep(match) nogen			// identinficando o municipio
ren codigo_ibge codmun7

*	Separa votos no 1o e 2o turno
preserve
keep if nr_turno == 2

ren bolsonaro22 bolsonaro22_2t
ren pt22 pt22_2t
ren pdt22 pdt22_2t
ren novo22 novo22_2t
ren mdb22 mdb22_2t
ren dc22 dc22_2t
ren pstu22 pstu22_2t
ren votos22 votos22_2t
ren nvalidos22 nvalidos22_2t
drop nr_turno
tempfile elec2022
save `elec2022'

restore 

keep if nr_turno == 1

ren bolsonaro22 bolsonaro22_1t
ren pt22 pt22_1t
ren pdt22 pdt22_1t
ren novo22 novo22_1t
ren mdb22 mdb22_1t
ren dc22 dc22_1t
ren pstu22 pstu22_1t
ren votos22 votos22_1t
ren nvalidos22 nvalidos22_1t
drop nr_turno

merge 1:1 codmun7 using `elec2022', nogen		// Junta numa base com 1o e 2o turno

gen bolsonaro_2022_1 = 100 * bolsonaro22_1t / votos22_1t
gen bolsonaro_2022_2 = 100 * bolsonaro22_2t / votos22_2t
gen pt_2022_1 = 100 * pt22_1t / votos22_1t
gen pt_2022_2 = 100 * pt22_2t / votos22_2t
gen pdt_2022_1 = 100 * pdt22_1t / votos22_1t
gen novo_2022_1 = 100 * novo22_1t / votos22_1t
gen mdb_2022_1 = 100 * mdb22_1t / votos22_1t
gen dc_2022_1 = 100 * dc22_1t / votos22_1t
gen pstu_2022_1 = 100 * pstu22_1t / votos22_1t
gen null_2022_1 = 100 * nvalidos22_1t / (nvalidos22_1t + votos22_1t)
gen null_2022_2 = 100 * nvalidos22_2t / (nvalidos22_2t + votos22_2t)

keep bolsonaro_2022_1-null_2022_2 nome_municipio codmun7 capital

tempfile elec2022
save `elec2022', replace

* Municipal elections
* Ideological party score
import delimited using "${raw}BLS9_full.csv", clear delimiter(",")
destring *, replace force
drop if lrclass == -999 | party_survey == -999 // | wave < 2008
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

* 2022-2018 elections
gen bolso_1 = bolsonaro_2022_1 - bolsonaro_2018_1
gen bolso_2 = bolsonaro_2022_2 - bolsonaro_2018_2
gen pt_1 = pt_2022_1 - pt_2018_1
gen pt_2 = pt_2022_2 - pt_2018_2
gen pdt = pdt_2022_1 - pdt_2018_1
gen novo = novo_2022_1 - novo_2018_1
gen mdb = mdb_2022_1 - mdb_2018_1
gen dc = dc_2022_1 - dc_2018_1
gen pstu = pstu_2022_1 - pstu_2018_1
gen null_1 = null_2022_1 - null_2018_1
gen null_2 = null_2022_2 - null_2018_2

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

**# Controls data
* Aeroportos
import delimited using "${raw}AerodromosPublicos.csv", clear delimiter(";") varnames(2)
keep if validadedoregistro != ""
keep município uf códigooaci
ren município nome_municipio
ren códigooaci icao
gen uf_cd = .
	replace uf_cd = 11 if uf == "Rondônia"
	replace uf_cd = 12 if uf == "Acre"
	replace uf_cd = 13 if uf == "Amazonas"
	replace uf_cd = 14 if uf == "Roraima"
	replace uf_cd = 15 if uf == "Pará"
	replace uf_cd = 16 if uf == "Amapá"
	replace uf_cd = 17 if uf == "Tocantins"
	replace uf_cd = 21 if uf == "Maranhão"
	replace uf_cd = 22 if uf == "Piauí"
	replace uf_cd = 23 if uf == "Ceará"
	replace uf_cd = 24 if uf == "Rio Grande do Norte"
	replace uf_cd = 25 if uf == "Paraíba"
	replace uf_cd = 26 if uf == "Pernambuco"
	replace uf_cd = 27 if uf == "Alagoas"
	replace uf_cd = 28 if uf == "Sergipe"
	replace uf_cd = 29 if uf == "Bahia"
	replace uf_cd = 31 if uf == "Minas Gerais"
	replace uf_cd = 32 if uf == "Espírito Santo"
	replace uf_cd = 33 if uf == "Rio de Janeiro"
	replace uf_cd = 35 if uf == "São Paulo"
	replace uf_cd = 41 if uf == "Paraná"
	replace uf_cd = 42 if uf == "Santa Catarina"
	replace uf_cd = 43 if uf == "Rio Grande do Sul"
	replace uf_cd = 50 if uf == "Mato Grosso do Sul"
	replace uf_cd = 51 if uf == "Mato Grosso"
	replace uf_cd = 52 if uf == "Goiás"
	replace uf_cd = 53 if uf == "Distrito Federal"
tempfile aero
save `aero'

import delimited using "${raw}iata-icao.csv", clear delimiter(",")
keep if country_code == "BR" & icao != ""
gduplicates tag icao, gen(dup)
drop if (icao == "SSYA" & latitude < -24.104) | (icao == "SBBR" & region_name == "Mato Grosso")
merge 1:1 icao using `aero'
gen aeroporto = 1
gen internacional = (_merge != 2)
gcollapse (max) aeroporto internacional, by(nome_municipio uf_cd)
drop if nome_municipio == ""
ren uf_cd uf
tostring uf, replace

la var aeroporto "Indicator var. of existence of airport in municipality"
la var internacional "Indicator var. whether airport admits international flights"
save "${dat}aero", replace

* Coastal municispalities
set excelxlsxlargefile on
import excel using "${raw}Municipios_Costeiros_2021.xls", clear firstrow sheet("lote01_10mar2021")
keep CD_MUN
ren CD_MUN codmun7
save "${dat}costa", replace

* Hospital beds
foreach s in "AC" "AL" "AM" "AP" "BA" "CE" "DF" "ES" "GO" "MA" "MG" "MS" ///
	"MT" "PA" "PB" "PE" "PI" "PR" "RJ" "RN" "RO" "RR" "RS" "SC" "SE" "SP" "TO" {
		import delimited using "${raw}LT`s'2001.csv", clear delimiter(",") varnames(1)
		ren codufmun codmun6
		gcollapse (sum) qt_sus qt_nsus, by(codmun6)
		tempfile leitos_`s'
		save `leitos_`s''
	}
clear
foreach s in "AC" "AL" "AM" "AP" "BA" "CE" "DF" "ES" "GO" "MA" "MG" "MS" ///
	"MT" "PA" "PB" "PE" "PI" "PR" "RJ" "RN" "RO" "RR" "RS" "SC" "SE" "SP" "TO" {
		append using `leitos_`s''
	}

merge 1:1 codmun6 using "${dat}id", keepusing(populacao)
replace qt_sus = 0 if _merge == 2
replace qt_nsus = 0 if _merge == 2
gen leitos_sus = 100000 * qt_sus / populacao
gen leitos_nsus = 100000 * qt_nsus / populacao
keep codmun6 leitos*

la var leitos_sus "Number of SUS managed hospital beds per 100,000 pop."
la var leitos_nsus "Number of non-SUS managed hospital beds per 100,000 pop."
save "${dat}beds", replace

* ESF coverage
import excel using "${raw}Historico-AB-MUNICIPIOS-2007-202012.xlsx", clear firstrow sheet("2020")
keep if NU_COMPETENCIA == "202003"
destring CO_MUNICIPIO_IBGE, gen(codmun6)
destring QT_EQUIPE_SF_AB, gen(x)
gen fracesf = subinstr(PC_COBERTURA_AB, ",", ".", .)
destring fracesf,  replace
merge 1:1 codmun6 using "${dat}id", keepusing(populacao)
gen teamsesf = 100000 * x / populacao
keep codmun6 teamsesf fracesf

la var teamsesf "Num. of ESF teams per 100,000 pop."
la var fracesf "Share of pop. covered by ESF"
save "${dat}esf", replace

* Agro gdp
import excel using "${raw}PIB_dos_Municipios_base_de_dados_2010_2020.xls", clear firstrow
keep if Ano == 2020
ren CódigodoMunicípio codmun7
ren ValoradicionadobrutodaAgrope pibagro
gen fracpibagro = pibagro / Valoradicionadobrutototala
la var fracpibagro "Fracao do setor agricola no PIB"
merge 1:1 codmun7 using "${dat}id", nogen
gen lagropib = ln((pibagro/populacao) + 1)
la var lagropib "Ln of agricultural GDP per capita"
keep codmun6 lagropib fracpibagro
save "${dat}agro", replace

* PBF
import delimited using "${raw}visdata3_download.csv", clear delimiter(",") varnames(1)
ren código codmun6
merge 1:1 codmun6 using "${dat}id", nogen keep(3)
gen beneficiomedio = subinstr(valordobenefíciomédioatéout2021,",",".",.)
destring beneficiomedio, replace
gen x = subinstr(valorrepassadoàsfamíliaspbfatéou,",",".",.)
destring x, replace
gen lgastopbf = ln(x / populacao)
la var beneficiomedio "Valor do beneficio medio do PBF em reais"
la var lgastopbf "Per capita expenditure on PBF"
keep codmun6 beneficiomedio lgastopbf
save "${dat}pbf", replace

* Homicides
import delimited using "${raw}taxa-homicidios.csv", clear delimiter(";") encoding(utf8)
ren cod codmun7
keep if período == 2017
rename valor homicidios
la var homicidios "Homicide rate per 100,000 pop."
keep homicidios codmun7
save "${dat}hom", replace


**# Capacity
use munic_mov dt_inter dt_saida using "${sih}dados_SIH_BRASIL_2019.dta", clear
tostring dt_inter dt_saida, replace
gen entrada = date(dt_inter, "YMD")
gen saida = date(dt_saida, "YMD")

forval t = 21550/21914 {
	preserve
	gen intern = (entrada <= `t' & saida >= `t')
	gcollapse (sum) intern, by(munic_mov)
	tempfile x`t'
	save `x`t'', replace
	restore
}

clear
forval t = 21550/21914 {
	append using `x`t''
}
gcollapse (max) leitos_est = intern, by(munic_mov)
rename munic_mov codmun6
tempfile capacidade
save `capacidade'

use munic_res munic_mov using "${sih}dados_SIH_BRASIL_2019.dta", clear
gen i = 1
gcollapse (sum) i, by(munic_res munic_mov)
tempfile sih
save `sih'

gcollapse (sum) j=i, by(munic_res)
join, into(`sih') by(munic_res) nogen
gen frac = i / j
la var frac "Fracao pessoas de 'munic_res' internadas em 'munic_mov'"
drop i j
tempfile sih
save `sih', replace

join, from("${dat}id") by(munic_res=codmun6)
gcollapse (sum) pop_pot = populacao, by(munic_mov)
join , into(`capacidade') by(codmun6=munic_mov) unique nogen
gen taxa = 100000 * leitos_est / pop_pot
join taxa, into(`sih') by(munic_mov=codmun6)
gcollapse (mean) vacancy = taxa [aw=frac], by(munic_res)
ren munic_res codmun6
save "${dat}capacidade", replace

**# Merging
use "${dat}id", clear
	gen lpop = ln(populacao)
join, into("${dat}geografia") by(codmun6 codmun7) nogen unique
join, into("${dat}covid") by(codmun6) nogen unique
join, into("${dat}elecs") by(codmun7) nogen unique
join, into("${dat}census") by(codmun7) nogen unique
	tostring uf, replace
join, into("${dat}aero") by(nome_municipio uf) unique
	replace aeroporto = 0 if _merge == 2
	replace internacional = 0 if _merge == 2
	drop _merge
	destring uf, replace
join, into("${dat}costa") by(codmun7) unique gen(costa)
	recode costa (2 = 0) (3 = 1)
	label value costa
	format %10.0g costa
	label variable costa "Dummy for munic. being coastal"
join, into("${dat}beds") by(codmun6) unique nogen
join, into("${dat}esf") by(codmun6) unique nogen
join, into("${dat}agro") by(codmun6) unique nogen
join, into("${dat}pbf") by(codmun6) unique nogen
join, into("${dat}hom") by(codmun7) unique nogen
	replace homicidios = 18.39	if codmun6 == 220191
	replace homicidios = 0		if codmun6 == 220198
	replace homicidios = 0		if codmun6 == 220225
	replace homicidios = 14.70	if codmun6 == 261153
	replace homicidios = 13.12	if codmun6 == 311783
	replace homicidios = 14.28	if codmun6 == 315213
	replace homicidios = 0		if codmun6 == 430587
	replace homicidios = 0		if codmun6 == 520393
	replace homicidios = 29.51	if codmun6 == 520396
		* Replace missing homicide data based on IPEA estimates. https://www.ipea.gov.br/atlasviolencia/arquivos/downloads/8099-tabelamunicipiostodossite.pdf
join, into("${dat}capacidade") by(codmun6) unique nogen

order nome_municipio codmun7 codmun6 micro meso uf macro populacao ///
	first* delay_* vacancy ///
	infec infec_alt covid covid_alt allelse2008-allelse2022 ///
	bolsonaro_2018_1-vshare_1208 ///
	distance ldist samereg borders ///
	ldist_alt25 samereg_alt25 borders_alt25 ///
	ldist_alt100 samereg_alt100 borders_alt100 ///
	lpop density leitos_sus leitos_nsus fracesf teamsesf fracpibagro lagropib beneficiomedio lgastopbf homicidios urbano masculino crianca-idoso idademedia rendimento_pessoa-horastrabalho fecundidade gini branco-indigena sabe_ler ef1_completo-es_completo beneficiario trabalhafora retornadiar pea buscatrabalho trabformal-migrante privado-aluguel outrosmot valaluguel dens_morador saneamento-veiculo capital aeroporto internacional costa lat lon

save "${bsa}dataset", replace
