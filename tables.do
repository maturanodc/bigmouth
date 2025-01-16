use "dataset", clear

cd "$tab"

global X lpop-lon samereg borders
cap gen I = ldist * lpop

preserve
drop privado casa casapropria branco crianca // (Full rank)

**# Table 1: First-stage
sum covid [aw=populacao]
	local mean_dep = round(r(mean),.1)
	di `mean_dep'
reg covid ldist I lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) replace nonotes
reg covid ldist I lpop $X [aw=pop], cluster(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) append nonotes
areg covid ldist I lpop $X [aw=pop], cluster(meso) ab(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
global pi1 = _b[ldist]
global pi2 = _b[I]
	
**# Table 2: First-stage placebo
file open Table_2 using "Table_2.tex", write replace
file write Table_2 "\begin{tabular}{ccccc}\hline" _n ///
	"Year & ldist & I & F & p-value \\ \hline" _n
forval i = 1/15 {
	local t = `i' + 2007
    areg allelse`t' ldist I $X [aw=pop], cluster(meso) a(meso)
    test ldist = I = 0
    local b_ldist = round(_b[ldist],.001)
    local se_ldist = round(_se[ldist],.001)
    local b_I = round(_b[I],.001)
    local se_I = round(_se[I],.001)
    local fstat = round(r(F),.001)
    local pval = round(r(p),.001)

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

**# Table 3: Impact on Bolsonaro
sum bolso_1 [aw=populacao]
	local mean_dep = round(r(mean),.001)
	di `mean_dep'
areg bolso_1 covid $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_3, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes
ivregress 2sls bolso_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_3, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
global beta = _b[covid]
outreg2 using Table_3, skip
sum bolso_2 [aw=populacao]
	local mean_dep = round(r(mean),.001)
	di `mean_dep'
areg bolso_2 covid $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_3, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
ivregress 2sls bolso_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_3, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

**# Table 4: Heterogeneities
sum bolso_1 if macro != 1 [aw=pop]
	local mean_dep = round(r(mean), .001)
areg covid ldist I $X if macro != 1 [aw=pop] , cluster(meso) a(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = r(p)
ivregress 2sls bolso_1 (covid = ldist I) $X i.meso if macro != 1 [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat", "`F'", ///
		"Degrees of freedom", "`df'<comma> `df_r'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes ctitle("macro != 1")

foreach y in "macro != 2" "macro != 3" "macro != 4" ///
	"macro != 5" "pop > 50000" "pop <= 50000" {
		
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
	outreg2 using Table_4, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat", "`F'", ///
		"Degrees of freedom", "`df'<comma> `df_r'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes ctitle("`y'")
		
	}

**# Table 5: Alternative thresholds
global X25 lpop-lon samereg_alt25 borders_alt25
gen ldist_alt = ldist_alt25
gen I_alt = ldist_alt * lpop

sum covid [aw=populacao]
	local covid = round(r(mean),.1)
areg covid ldist_alt I_alt $X25 [aw=pop] , cluster(meso) a(meso)
local clusters = e(N_clust)
test ldist_alt = I_alt = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_5, tex(frag) nocons keep(ldist_alt I_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`covid'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes

sum bolso_1 [aw=pop]
	local bolso_1 = round(r(mean),.001)
ivregress 2sls bolso_1 (covid = ldist_alt I_alt) $X25 i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_5, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`bolso_1'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
sum bolso_2 [aw=pop]
	local bolso_2 = round(r(mean),.001)
ivregress 2sls bolso_2 (covid = ldist_alt I_alt) $X25 i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_5, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`bolso_2'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
	
	outreg2 using Table_5, skip

global X100 lpop-lon samereg_alt100 borders_alt100
replace ldist_alt = ldist_alt100
replace I_alt = ldist_alt * lpop

sum covid [aw=populacao]
	local covid = round(r(mean),.1)
areg covid ldist_alt I_alt $X100 [aw=pop] , cluster(meso) a(meso)
	local clusters = e(N_clust)
test ldist_alt = I_alt = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_5, tex(frag) nocons keep(ldist_alt I_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`covid'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

sum bolso_1 [aw=pop]
	local bolso_1 = round(r(mean),.001)
ivregress 2sls bolso_1 (covid = ldist_alt I_alt) $X100 i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_5, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`bolso_1'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
sum bolso_2 [aw=pop]
	local bolso_2 = round(r(mean),.001)
ivregress 2sls bolso_2 (covid = ldist_alt I_alt) $X100 i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_5, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`bolso_2'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

**# Table 6: Alternative specifications
sum bolso_1 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls bolso_1 (covid = I) ldist $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_6, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes

ivregress 2sls bolso_1 (covid = ldist) I $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_6, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

outreg2 using Table_6, skip

sum bolso_2 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls bolso_2 (covid = I) ldist $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_6, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

ivregress 2sls bolso_2 (covid = ldist) I $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_6, tex(frag) nocons keep(covid ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

**# Table 7: Placebo test
sum vshare_1814_1 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1814_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes

sum vshare_1410_1 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1410_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

outreg2 using Table_7, skip

sum vshare_1814_2 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1814_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
sum vshare_1410_2 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1410_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
outreg2 using Table_7, skip

sum vshare_1612 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1612 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
sum vshare_1208 [aw=pop]
local mean_dep = round(r(mean), 0.001)
ivregress 2sls vshare_1208 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_7, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
	
**# Table 8: Other politicians
sum pt_1 [aw=pop]
	local mean_dep = round(r(mean), 0.001)
ivregress 2sls pt_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_8, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
		) replace nonotes

foreach y of varlist pt_2-null_2 {
	sum `y' [aw=pop]
	local mean_dep = round(r(mean), 0.001)
	ivregress 2sls `y' (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_8, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
		) append nonotes
}

**# Table 9: Right Wing
areg covid_alt ldist I lpop $X [aw=pop], cluster(meso) a(meso)
local clusters = e(N_clust)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_9, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes

foreach y of varlist right-bparty {
	sum `y' [aw=pop]
	local mean_dep = round(r(mean), 0.001)
	ivregress 2sls `y' (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
	outreg2 using Table_9, tex(frag) nocons keep(covid) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
		) append nonotes
}	

**# Table 10: Incumbency
sum gov_1 [aw=pop]
local mean_dep = round(r(mean), 0.001)
areg covid_alt ldist I lpop $X if gov_1 != . [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
ivregress 2sls gov_1 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_10, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat", "`F' <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) replace nonotes
	
sum gov_2 [aw=pop]
local mean_dep = round(r(mean), 0.001)
areg covid_alt ldist I lpop $X if gov_2 != . [aw=pop], cluster(meso) a(meso)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
ivregress 2sls gov_2 (covid = ldist I) $X i.meso [aw=pop], cluster(meso)
local clusters = e(N_clust)
outreg2 using Table_10, tex(frag) nocons keep(covid) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat", "`F' <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

restore
preserve
foreach v of varlist ///
	fracpibagro urbano-idoso branco-outrosmot saneamento-veiculo {
		replace `v' = `v' * 100
	}

**# Table A1: Summary statistics
estpost sum ///
	covid_alt covid infec_alt infec first* delay_* ///
	bolsonaro_2018_1-bolso_2 ///
	dist populacao ldist lpop I ///
	density-costa samereg borders lat lon [aw = populacao]
esttab . using Table_A1, ///
	cells("count(fmt(%9.0gc)) mean(fmt(%9.4gc)) sd(fmt(%9.4gc)) min(fmt(%9.4gc)) max(fmt(%9.4gc))") ///
	noobs tex longtable replace

restore
preserve
drop privado casa casapropria branco crianca // (Full rank)

**# Table A2: Regional distribution
file open Table_A2 using "Table_A2.tex", write replace
file write Table_A2 "\begin{tabular}{lcccc} \hline" _n ///
	"& & Large & Share of large & Distance \\ " _n ///
	"Region & Municipalities & municipalities & to NLM \\ \hline" _n

tab macro [aw=pop], matcell(M)
tab macro if pop>50000 [aw=pop], matcell(L)
forval i =1/5 {
	sum distance if macro == `i' [aw=pop]
	local media = round(r(mean),.01)
	local sd = round(r(sd),.01)
	local m`i' = M[`i',1]
	local m = round(`m`i'',.01)
	local l`i' = L[`i',1]
	local l = round(`l`i'',.01)
	local r = round(100 * `l`i'' / `m`i'',.01)
	local n`i' = 100 * M[`i',1] / (M[1,1] + M[2,1] + M[3,1] + M[4,1] + M[5,1])
	local n = round(`n`i'', .01)
	local k`i' = 100 * L[`i',1] / (L[1,1] + L[2,1] + L[3,1] + L[4,1] + L[5,1])
	local k = round(`k`i'', .01)
	file write Table_A2 "`i' & `m' & `l' & `r'\% & `media' \\" _n ///
		" & [`n'\%] & [`k'\%] & & (`sd') \\" _n
}
sum distance [aw=pop]
local media = round(r(mean),.01)
local sd = round(r(sd),.01)
local mt = `m1' + `m2' + `m3' + `m4' + `m5'
local m = round(`mt',.01)
local lt = `l1' + `l2' + `l3' + `l4' + `l5'
local l = round(`lt',.01)
local rt = round(100 * `mt' / `lt', .01)
local nt = `n1' + `n2' + `n3' + `n4' + `n5'
local n = round(`nt',.01)
local kt = `k1' + `k2' + `k3' + `k4' + `k5'
local k = round(`kt',.01)

file write Table_A2 "\hline" _n ///
	"Total & `m' & `l' & `r'\% & `media' \\" _n ///
	" & [`n'\%] & [`k'\%] & & (`sd') \\ \hline" _n ///
	"\end{tabular}" _n
file close Table_A2

restore
**# Table A3: Correlation coefficients
gen z = - 1 * (${pi1} * ldist + ${pi2} * I)
egen min = min(z)
egen max = max(z)
gen isol = (z - min) / (max - min)
estpost corr covid density-costa samereg borders lat lon [aw = populacao]
mat def A = e(rho)'
estpost corr isol density-costa samereg borders lat lon [aw = populacao]
mat def B = e(rho)'
mat def X = A , B

esttab matrix(X, fmt(%9.3g)) using Table_A3, tex longtable replace

drop privado casa casapropria branco crianca // (Full rank)

local pi1 = round(${pi1} , .1)
local pi2 = round(${pi2} , .001)
local beta = round(${beta}, .0001)
**# Table A4: Different spatial correlations
file open Table_A4 using "Table_A4.tex", write replace
file write Table_A4 "\begin{tabular}{lcccccc}\hline" _n ///
	"& & \multicolumn{2}{c}{First stage} & & \multicolumn{2}{c}{Second stage} \\" _n ///
	"& & \multicolumn{2}{c}{(\(\hat\pi_1=`pi1',\,\hat\pi_2=`pi2'\))} & & \multicolumn{2}{c}{(\(\hat\beta=`beta'\))} \\ \cline{3-4} \cline{6-7}" _n ///
	"Cluster level & N clusters& Joint F-stat & p-value & & Std. Error & p-value \\ \hline" _n
	
foreach v of varlist codmun6 micro meso uf macro {
	areg covid ldist I $X [aw=pop], cluster(`v') a(meso)
	test ldist = I = 0
	local f = round(r(F), .01)
	local p1 = round(r(p), .0001)
	
	ivregress 2sls bolso_1 (covid = ldist I) $X i.meso [aw=pop], cluster(`v')
	matrix V = e(V)
	test covid
	local n = e(N_clust)
	local stderr = round(V[1,1], .00001)
	local p2 = round(r(p), .0001)
	
	file write Table_A4 "`v' & `n' & `f' & `p1' & & `stderr' & `p2' \\" _n
}
file write Table_A4 "\hline" _n "\end{tabular}" _n
file close Table_A4

**# Table A5: Earlier Covid
sum bolso_1 [aw=populacao]
	local mean_dep = round(r(mean),.001)
	di `mean_dep'
areg bolso_1 covid_alt $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A5, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) replace nonotes
ivregress 2sls bolso_1 (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A5, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_A5, skip
sum bolso_2 [aw=populacao]
	local mean_dep = round(r(mean),.001)
	di `mean_dep'
areg bolso_2 covid_alt $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A5, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes
ivregress 2sls bolso_2 (covid_alt = ldist I) $X i.meso [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_A5, tex(frag) nocons keep(covid_alt) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "Yes", ///
		"Regional intercepts", "Yes", ///
		"Population weights", "Yes" ///
	) append nonotes

**# Table C1: Vaccination
sum delay_vi [aw=pop]
	local mean_dep = round(r(mean),.01)
reg delay_vi ldist I lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_C1, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) replace nonotes
areg delay_vi ldist I lpop $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
outreg2 using Table_C1, tex(frag) nocons keep(ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_C1,	skip
sum covid [aw=pop]
	local mean_dep = round(r(mean),.01)
reg covid delay_vi lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_C1, tex(frag) nocons keep(ldist I delay_vi) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) append nonotes
areg covid delay_vi $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
outreg2 using Table_C1, tex(frag) nocons keep(ldist I delay_vi) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes

**# Table C2: Vaccination
sum vacancy [aw=pop]
	local mean_dep = round(r(mean),.01)
reg vacancy ldist I lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
	outreg2 using Table_C2, tex(frag) nocons keep(ldist I) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) replace nonotes
areg vacancy ldist I lpop $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
test ldist = I = 0
	local F = round(r(F),.01)
	local df = r(df)
	local df_r = r(df_r)
	local pval = round(r(p),0.001)
outreg2 using Table_C2, tex(frag) nocons keep(ldist I) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes
outreg2 using Table_C2,	skip
sum covid [aw=pop]
	local mean_dep = round(r(mean),.01)
reg covid vacancy lpop [aw=pop], cluster(meso)
	local clusters = e(N_clust)
	outreg2 using Table_C2, tex(frag) nocons keep(ldist I vacancy) addtext( ///
		"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
		"Mean value dep. var.", "`mean_dep'", ///
		"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
		"p-value F-test", "`pval'", ///
		"ln Population count", "Yes", ///
		"Municipal controls", "No", ///
		"Regional intercepts", "No", ///
		"Population weights", "Yes" ///
	) append nonotes
areg covid vacancy $X [aw=pop], cluster(meso) a(meso)
	local clusters = e(N_clust)
outreg2 using Table_C2, tex(frag) nocons keep(ldist I vacancy) addtext( ///
	"N. clusters <openparentheses>regions<closeparentheses>", "`clusters'", ///
	"Mean value dep. var.", "`mean_dep'", ///
	"Joint F-stat <openparentheses>`df'<comma> `df_r' df.<closeparentheses>", "`F'", ///
	"p-value F-test", "`pval'", ///
	"ln Population count", "Yes", ///
	"Municipal controls", "Yes", ///
	"Regional intercepts", "Yes", ///
	"Population weights", "Yes" ///
	) append nonotes


	
cd "$bsa"
