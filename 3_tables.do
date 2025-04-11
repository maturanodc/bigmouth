use "${bsa}dataset.dta", clear

cd "${bsa}tables/"

gen I = ldist * lpop
foreach v of varlist ///
	fracpibagro urbano-idoso branco-outrosmot saneamento-veiculo {
		replace `v' = `v' * 100
	}

**# Table A1: Summary statistics
estpost sum ///
	covid_alt covid firstcase firstvacc delay ///
	bolsonaro_2018_1-bolso_2 ///
	dist populacao ldist lpop I ///
	density-costa samereg borders lat lon [aw = populacao]
esttab . using Table_A1, ///
	cells("count(fmt(%9.0gc)) mean(fmt(%9.4gc)) sd(fmt(%9.4gc)) min(fmt(%9.4gc)) max(fmt(%9.4gc))") ///
	noobs tex longtable replace

drop privado casa casapropria branco crianca // (Full rank)

global X lpop-lon samereg borders

**# Table A2: Regional distribution of Brazilian municipalities
file open Table_A2 using "Table_A2.tex", write replace
file write Table_A2 "\begin{tabular}{lcccc} \hline" _n ///
	"& & Large & Share of large & Distance \\ " _n ///
	"Region & Municipalities & municipalities & to NLM \\ \hline" _n

tab macro [aw=pop], matcell(M)
tab macro if pop > 50000 [aw=pop], matcell(L)
forval i = 1/5 {
	sum distance if macro == `i' [aw=pop]
	local media = r(mean)
	local sd = r(sd)
	local m`i' = M[`i',1]
	local m = `m`i''
	local l`i' = L[`i',1]
	local l = `l`i''
	local r = 100 * `l`i'' / `m`i''
	local n`i' = 100 * M[`i',1] / (M[1,1] + M[2,1] + M[3,1] + M[4,1] + M[5,1])
	local n = `n`i''
	local k`i' = 100 * L[`i',1] / (L[1,1] + L[2,1] + L[3,1] + L[4,1] + L[5,1])
	local k = `k`i''
	file write Table_A2 "`i' & `m' & `l' & `r'\% & `media' \\" _n ///
		" & [`n'\%] & [`k'\%] & & (`sd') \\" _n
}
sum distance [aw=pop]
local mediat = r(mean)
local sdt = r(sd)
local mt = `m1' + `m2' + `m3' + `m4' + `m5'
local lt = `l1' + `l2' + `l3' + `l4' + `l5'
local rt = 100 * `mt' / `lt'
local nt = `n1' + `n2' + `n3' + `n4' + `n5'
local kt = `k1' + `k2' + `k3' + `k4' + `k5'

file write Table_A2 "\hline" _n ///
	"Total & `mt' & `lt' & `rt'\% & `mediat' \\" _n ///
	" & [`nt'\%] & [`kt'\%] & & (`sdt') \\ \hline" _n ///
	"\end{tabular}" _n
file close Table_A2

**# Table A3: Impact of earlier COVID-19 deaths on votes for Jair Bolsonaro
sum bolso_1 [aw=populacao]
	local mean_dep1 = r(mean)
sum bolso_2 [aw=populacao]
	local mean_dep2 = r(mean)
areg covid_alt ldist I lpop $X [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	
areg bolso_1 covid_alt $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A3, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep1'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes
areg bolso_2 covid_alt $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A3, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep2'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_A3, skip
ivregress 2sls bolso_1 (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A3, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep1'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
ivregress 2sls bolso_2 (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A3, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep2'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes


**# Table 1: COVID-19 Mortality rates and Municipal isolation (first-stage)
sum covid [aw=populacao]
local mean_dep = r(mean)
reg covid ldist I lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) replace nonotes
reg covid ldist I lpop $X [aw=pop], cluster(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) append nonotes
areg covid ldist I lpop $X [aw=pop], cluster(meso) ab(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
global pi1 = _b[ldist]
global pi2 = _b[I]

**# Table 2: First-stage placebo tests---Isolation and non-COVID deaths
file open Table_2 using "Table_2.tex", write replace
file write Table_2 "\begin{tabular}{ccccc}\hline" _n ///
	"Year & ldist & I & F & p-value \\ \hline" _n
forval i = 1/15 {
	local t = `i' + 2007
    areg allelse`t' ldist I $X [aw=pop], cluster(meso) a(meso)
    test ldist = I = 0
    local b_ldist = _b[ldist]
    local se_ldist = _se[ldist]
    local b_I = _b[I]
    local se_I = _se[I]
    local fstat = r(F)
    local pval = r(p)

    * Write the row to the file
	if `t' != 2019 {
		file write Table_2 ///
			"`t' & `b_ldist' & `b_I' & `fstat' & `pval' \\" _n ///
			" & (`se_ldist') & (`se_I') \\" _n
	}
	else if `t' == 2019 {
		file write Table_2 ///
			"`t' & `b_ldist'* & `b_I' & `fstat' & `pval' \\" _n ///
			" & (`se_ldist') & (`se_I') \\" _n
	}
}
file write Table_2 "\hline" _n "\end{tabular}" _n
file close Table_2

**# Table 3: Differences in Vaccination Timing and Mortality rates
sum delay [aw=pop]
local mean_dep = r(mean)
reg delay ldist I lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	outreg2 using Table_3, tex(frag) nocons keep(ldist I delay) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) replace nonotes
areg delay ldist I lpop $X [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	outreg2 using Table_3, tex(frag) nocons keep(ldist I delay) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_3,	skip
sum covid [aw=pop]
local mean_dep = r(mean)
reg covid delay lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_3, tex(frag) nocons keep(ldist I delay) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) append nonotes
areg covid delay $X [aw=pop], cluster(meso) a(meso)
	outreg2 using Table_3, tex(frag) nocons keep(ldist I delay) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

**# Table 4: Impact of COVID-19 deaths on votes for Jair Bolsonaro
areg covid ldist I lpop $X [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
sum bolso_1 [aw=populacao]
	local mean_dep1 = r(mean)
sum bolso_2 [aw=populacao]
	local mean_dep2 = r(mean)
areg bolso_1 covid $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep1'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes
areg bolso_2 covid $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep2'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_4, skip
ivregress 2sls bolso_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep1'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
global beta = _b[covid]
ivregress 2sls bolso_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep2'", ///
		"Joint F-stat `df' `df_r' df.", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

**# Table 5: Different spatial correlation effects on main estimates
file open Table_5 using "Table_5.tex", write replace
file write Table_5 "\begin{tabular}{lcccccc}\hline" _n ///
	"& & \multicolumn{2}{c}{First stage} & & \multicolumn{2}{c}{Second stage} \\" _n ///
	"\multicolumn{1}{c}{Cluster level} & Number & \multicolumn{2}{c}{(\(\hat\pi_1=`pi1',\,\hat\pi_2=`pi2'\))} & & \multicolumn{2}{c}{(\(\hat\beta=`beta'\))} \\ \cline{3-4} \cline{6-7}" _n ///
	"\multicolumn{1}{c}{(robust)} & of clusters& Joint F-stat & p-value & & Std. Error & p-value \\ \multicolumn{1}{c}{(1)} & (2) & (3) & (4) & & (5) & (6) \\ \hline \\" _n
	
foreach v of varlist codmun6 micro meso uf macro {
	areg covid ldist I $X [aw=pop], cluster(`v') a(meso)
	test ldist = I = 0
	local f = r(F)
	local p1 = r(p)
	
	ivregress 2sls bolso_1 (covid = ldist I) $X i.meso [aw=pop], cluster(`v')
	matrix V = e(V)
	test covid
	local n = e(N_clust)
	local stderr = V[1,1]
	local p2 = r(p)
	
	file write Table_5 "`v' & `n' & `f' & `p1' & & `stderr' & `p2' \\" _n
}
file write Table_5 "\hline" _n "\end{tabular}" _n
file close Table_5

**# Table 6: Heterogeneous impacts on presidential support (2sls)
sum bolso_1 if macro != 1 [aw=pop]
local mean_dep = r(mean)
areg covid ldist I $X if macro != 1 [aw=pop] , cluster(meso) a(meso)
test ldist = I = 0
local F = r(F)
local df = r(df)
local df_r = r(df_r)
local pval = r(p)
ivregress 2sls bolso_1 (covid = ldist I) $X i.meso if macro != 1 [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_6, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat", "`F'", ///
	"Degrees of freedom", "`df' `df_r'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
) replace nonotes ctitle("macro != 1")

foreach y in "macro != 2" "macro != 3" "macro != 4" ///
	"macro != 5" "pop <= 50000" "pop > 50000" {
		
	sum bolso_1 if `y' [aw=pop]
	local mean_dep = round(r(mean), .001)
	areg covid ldist I $X if `y' [aw=pop] , cluster(meso) a(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	ivregress 2sls bolso_1 (covid = ldist I) $X i.meso if `y' [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_6, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters regions", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat", "`F'", ///
		"Degrees of freedom", "`df' `df_r'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes ctitle("`y'")
		
	}

**# Table 7: Alternative thresholds
global X25 lpop-lon samereg_alt25 borders_alt25
gen ldist_alt = ldist_alt25
gen I_alt = ldist_alt * lpop

sum bolso_1 [aw=pop]
local bolso_1 = r(mean)
sum bolso_2 [aw=pop]
local bolso_2 = r(mean)

areg covid ldist_alt I_alt $X25 [aw=pop] , cluster(meso) a(meso)
test ldist_alt = I_alt = 0
local F = r(F)
local df = r(df)
local df_r = r(df_r)
local pval = r(p)
ivregress 2sls bolso_1 (covid = ldist_alt I_alt) $X25 i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`bolso_1'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
) replace nonotes

ivregress 2sls bolso_2 (covid = ldist_alt I_alt) $X25 i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`bolso_2'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
) append nonotes
	
outreg2 using Table_7, skip

global X100 lpop-lon samereg_alt100 borders_alt100
replace ldist_alt = ldist_alt100
replace I_alt = ldist_alt * lpop

areg covid ldist_alt I_alt $X100 [aw=pop] , cluster(meso) a(meso)
test ldist_alt = I_alt = 0
local F = r(F)
local df = r(df)
local df_r = r(df_r)
local pval = r(p)
ivregress 2sls bolso_1 (covid = ldist_alt I_alt) $X100 i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`bolso_1'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
) append nonotes

ivregress 2sls bolso_2 (covid = ldist_alt I_alt) $X100 i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`bolso_2'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
) append nonotes

**# Table 8: Alternative specifications
areg covid ldist I $X [aw=pop] , cluster(meso) a(meso)
test ldist = I = 0
local F = r(F)
local df = r(df)
local df_r = r(df_r)
local pval = r(p)

sum bolso_1 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls bolso_1 (covid = I) ldist $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_8, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes

ivregress 2sls bolso_1 (covid = ldist) I $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_8, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

outreg2 using Table_8, skip

sum bolso_2 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls bolso_2 (covid = I) ldist $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_8, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

ivregress 2sls bolso_2 (covid = ldist) I $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_8, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

**# Table 9: Placebo test---Impact of COVID-19 on prior elections (2sls)
sum vshare_1814_1 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1814_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes

sum vshare_1410_1 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1410_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

outreg2 using Table_9, skip

sum vshare_1814_2 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1814_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
sum vshare_1410_2 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1410_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
outreg2 using Table_9, skip

sum vshare_1612 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1612 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
sum vshare_1208 [aw=pop]
local mean_dep = r(mean)
ivregress 2sls vshare_1208 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes


**# Table 10: COVID-19 impact on Right Wing mayoral candidates
areg covid_alt ldist I lpop $X [aw=pop], cluster(meso) a(meso)
local clusters = e(N_clust)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
	
sum right [aw=pop]
local mean_dep = r(mean)
ivregress 2sls right (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
outreg2 using Table_10, tex(frag) nocons keep(covid_alt) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes
	
sum fright [aw=pop]
local mean_dep = r(mean)
ivregress 2sls fright (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
outreg2 using Table_10, tex(frag) nocons keep(covid_alt) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

sum bparty [aw=pop]
local mean_dep = r(mean)
ivregress 2sls bparty (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
outreg2 using Table_10, tex(frag) nocons keep(covid_alt) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

**# Table 11: COVID-19 impact on incumbent gubernatorial candidates (2SLS)
sum gov_1 [aw=pop]
local mean_dep = r(mean)
areg covid ldist I lpop $X if gov_1 != . [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
ivregress 2sls gov_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_11, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes

sum gov_2 [aw=pop]
local mean_dep = r(mean)
areg covid ldist I lpop $X if gov_2 != . [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = r(F)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
ivregress 2sls gov_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_11, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters regions", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat `df' `df_r' df.", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

cd "$bsa"
