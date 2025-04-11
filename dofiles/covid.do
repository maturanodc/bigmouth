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

**# Vaccine data
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

**# Infection data
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
by codmun6: egen firstcase = max(x_16)
by codmun6: egen x_17 = min(date) if vacina > 0
by codmun6: egen firstvacc = max(x_17)
gen delay = firstvacc - firstcase
drop x_*

gen pre20 = (date < 22234)		// 15/11/2020
gen pre22 = (date < 22920)		// 02/10/2022

gen covid = covid19 * pre22
gen covid_alt = covid19 * pre20

gcollapse (sum) covid covid_alt, by(codmun6 firstcase firstvacc delay allelse*)
	
join populacao, from("${dat}id") unique nogen keep(3) by(codmun6)

foreach v of varlist allelse2008-allelse2022 covid covid_alt {
	replace `v' = 100000 * `v' / populacao
}
drop populacao

save "${dat}covid", replace