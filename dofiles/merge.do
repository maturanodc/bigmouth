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
		* Replace missing homicide data based on IPEA estimates.  https://www.ipea.gov.br/atlasviolencia/arquivos/downloads/8099-tabelamunicipiostodossite.pdf

order nome_municipio codmun7 codmun6 micro meso uf macro populacao ///
	firstcase firstvacc delay covid covid_alt allelse2008-allelse2022 ///
	bolsonaro_2018_1-vshare_1208 ///
	distance ldist samereg borders ///
	ldist_alt25 samereg_alt25 borders_alt25 ///
	ldist_alt100 samereg_alt100 borders_alt100 ///
	lpop density leitos_sus leitos_nsus fracesf teamsesf fracpibagro lagropib ///
		beneficiomedio lgastopbf homicidios urbano masculino crianca-idoso ///
		idademedia rendimento_pessoa rendimento_domicilio horastrabalho ///
		fecundidade gini branco preto amarelo pardo indigena sabe_ler ///
		ef1_completo ef2_completo em_completo es_completo beneficiario ///
		trabalhafora retornadiar pea buscatrabalho trabformal-migrante ///
		privado-aluguel outrosmot valaluguel dens_morador saneamento-veiculo ///
		capital aeroporto internacional costa lat lon

save "${bsa}dataset", replace

**# Data redux
gen I = ldist * lpop
global X lpop-lon samereg borders
areg covid ldist I lpop $X [aw=pop], cluster(meso) ab(meso)

gen X = _b[ldist] * ldist + _b[I] * I

egen k = max(populacao)
insobs 6, before(1)
replace populacao = 0 if _n == 1
replace populacao = 5000 if _n == 2
replace populacao = 15000 if _n == 3
replace populacao = 50000 if _n == 4
replace populacao = 200000 if _n == 5
replace populacao = 1000000 if _n == 6

gen x = 0 if populacao == 0
replace x = 1/6 if populacao == 5000
replace x = 1/3 if populacao == 15000
replace x = 1/2 if populacao == 50000
replace x = 2/3 if populacao == 200000
replace x = 5/6 if populacao == 1000000
replace x = 1 if populacao == k
ipolate x populacao, gen(Y)

drop if codmun7 == .
keep codmun7 populacao X Y 
save "${bsa}data_redux", replace
