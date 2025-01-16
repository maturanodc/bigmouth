cd "$bsa"

use "dataset", clear
global X lpop-lon samereg borders
cap gen I = ldist * lpop
areg covid ldist I lpop $X [aw=pop], cluster(meso) ab(meso)
gen z = - 1 * (_b[ldist] * ldist + _b[I] * I)
egen min = min(z)
egen max = max(z)
gen isol = (z - min) / (max - min)
egen min2 = min(firstinfec)
gen del = ln(firstinfec - min2 + 1)

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
ipolate x populacao, gen(y)

drop if codmun7 == .
keep codmun7 isol populacao del firstinfec infec covid ldist infec_alt y
save "dataset_redux", replace

cd "$fig"

**# Figure 1
histogram isol, xlab(, format(%9.1f)) ///
	xtitle("Estimated municipal isolation") ///
	col("navy") fin("75")
graph export "Fig_1.pdf", as(pdf) replace

**# Figure 3
graph twoway (lpolyci ldist isol [aw=pop], ///
	k(bi) bw(.2) deg(1) pw(.25) clc("navy")), ///
	legend(off) xtitle("Estimated municipal isolation") ///
	xlab(, format(%9.1f)) ytitle("")
graph export "Fig_3a.pdf", as(pdf) replace

graph twoway (lpolyci firstinfec isol [aw=pop], ///
	k(bi) bw(.2) deg(1) pw(.25) clc("navy")), ///
	legend(off) xtitle("Estimated municipal isolation") ///
	xlab(, format(%9.1f)) ylab(, format(%tdmy))
graph export "Fig_3b.pdf", as(pdf) replace
	
graph twoway (lpolyci infec isol [aw=pop], ///
	k(bi) bw(.2) deg(1) pw(.25) clc("navy")), ///
	legend(off) xtitle("Estimated municipal isolation") ///
	xlab(, format(%9.1f)) ylab(, format(%9.0gc))
graph export "Fig_3c.pdf", as(pdf) replace
	
graph twoway (lpolyci covid isol [aw=pop], ///
	k(bi) bw(.2) deg(1) pw(.25) clc("navy")), ///
	legend(off) xtitle("Estimated municipal isolation") ///
	xlab(, format(%9.1f)) ylab(, format(%9.0gc))
graph export "Fig_3d.pdf", as(pdf) replace

**# Figure C1
use "${bsa}SIRDA", clear
tsset t
graph twoway (tsline i_phi1, lp("solid") lc("gs6")) ///
	(tsline i_phi2, lp("dash") lc("gs3")) ///
	(tsline i_phi3, lp("dot") lc("gs0")), ///
	legend(off) xtitle("") xlab(, format(%9.0gc)) ///
	ytitle("Instantaneous infection rate") ylab(, format(%09.1fc)) 
graph export "Fig_C1a.pdf", as(pdf) replace

graph twoway (tsline c_phi1, lp("solid") lc("gs6")) ///
	(tsline c_phi2, lp("dash") lc("gs3")) ///
	(tsline c_phi3, lp("dot") lc("gs0")), ///
	legend(off) xtitle("Municipality A") xlab(, format(%9.0gc)) ///
	ytitle("Cumulative infection rate") ylab(, format(%09.1fc)) 
graph export "Fig_C1c.pdf", as(pdf) replace

use "${bsa}SIRDB", clear
tsset t
graph twoway (tsline i_phi1, lp("solid") lc("gs6")) ///
	(tsline i_phi2, lp("dash") lc("gs3")) ///
	(tsline i_phi3, lp("dot") lc("gs0")), ///
	legend(label (1 "{it:ϕ}{subscript:1} = 1.00") ///
		label (2 "{it:ϕ}{subscript:2} = 0.25") ///
		label (3 "{it:ϕ}{subscript:3} = 0.01") ///
		col(1) ring(0) position(2) bmargin(medium)) ///
	xtitle("") xlab(, format(%9.0gc)) ///
	ytitle("") ylab(, format(%09.1fc))
graph export "Fig_C1b.pdf", as(pdf) replace

graph twoway (tsline c_phi1, lp("solid") lc("gs6")) ///
	(tsline c_phi2, lp("dash") lc("gs3")) ///
	(tsline c_phi3, lp("dot") lc("gs0")), ///
	legend(off) xtitle("Municipality B") ///
	xlab(, format(%9.0fc)) ytitle("") ylab(, format(%09.1fc))
graph export "Fig_C1d.pdf", as(pdf) replace

**# Figure C2
use "${bsa}vaccination", clear
tsset t
graph twoway (tsline da, color("navy") lp("solid")) ///
	(tsline da2, color("navy") lp("dash")) ///
	(tsline db, color("maroon") lp("solid")) ///
	(tsline db2, color("maroon") lp("dash")), ///
	xline(751, lc(black) lp("dot")) legend(off) ///
	xtitle("") xlab(, format(%9.0fc)) ///
	ylab(, format(%09.2fc))
graph export "Fig_C2a.pdf", as(pdf) replace

graph twoway (tsline ia, color("navy") lp("solid")) ///
	(tsline ib, color("maroon") lp("solid")), ///
	xline(751, lc(black) lp("dot")) xtitle("") ///
	xlab(, format(%9.0fc)) ylab(, format(%09.2fc)) ///
	legend(label (1 "Municipality A") ///
		label (2 "Municipality B") ///
		col(1) ring(0) position(2) bmargin(medium))
graph export "Fig_C2b.pdf", as(pdf) replace

cd "$bsa"
