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