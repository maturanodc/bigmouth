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
la var lgastopbf "Per capita expenditure on PBF (logs)"
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