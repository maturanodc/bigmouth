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
