* This is an auxiliary do-file. It documents calculations made to reach some
* of the values discussed in the paper, but does not create anything itself.
* Requires dataset.dta in /main/.

use "${bsa}dataset", clear

* Brazilian population
egen x = total(pop)
di %14.0fc x // 203,080,756 pop.
drop x

* COVID deaths up to 01oct2022
gen x = covid * pop / 10^5
egen y = total(x)
di %14.0fc y // 696,439 deaths
drop x y

* Mortality rate: 696,439 * 10^5 / 203,080,756 = 342.93697 deaths / 100k pop.

* Bolsonaro %
sum bolsonaro_2022_1 [aw=pop] // 43.61307   %
sum bolsonaro_2022_2 [aw=pop] // 49.44262   %

* Estimates beta, 1st
ivregress 2sls bolso_1 (covid = ldist c.ldist#c.lpop) /// betahat = -0.0155317
	lpop-lon samereg borders i.meso /// 				  95%ci_l = -0.0269320
	[aw=pop], cluster(meso) // 							  95%ci_u = -0.0041313
	
* Estimates beta, 2nd
ivregress 2sls bolso_2 (covid = ldist c.ldist#c.lpop) /// betahat = -0.0117253
	lpop-lon samereg borders i.meso /// 				  95%ci_l = -0.0209377
	[aw=pop], cluster(meso) // 							  95%ci_u = -0.0025129
	
* Voteshare variation due to covid => Voteshare no covid ceteris paribus
* 1st round
	* betahat: 342.93697 * -0.0155317 = -5.3263941 => 48.939464
	* 95%ci_l: 342.93697 * -0.0269320 = -9.2359785 => 52.849049
	* 95%ci_u: 342.93697 * -0.0041313 = -1.4167755 => 45.029846
* 2nd round
	* betahat: 342.93697 * -0.0117253 = -4.0210389 => 53.463659
	* 95%ci_l: 342.93697 * -0.0209377 = -7.1803114 => 56.622931
	* 95%ci_u: 342.93697 * -0.0025129 = -0.8617663 => 50.304386

* Reduction in deaths necessary for winning, ceteris paribus
* 1st round
	* betahat: impossible
	* 95%ci_l: 50 < 52.849049 - 9.2359785 * ( 1 - x ) => x > 69.152711%
	* 95%ci_u: impossible
* 2nd round
	* betahat: 50 < 53.463659 - 4.0210389 * ( 1 - x ) => x > 13.861589%
	* 95%ci_l: 50 < 56.622931 - 7.1803114 * ( 1 - x ) => x > 7.7626215%
	* 95%ci_u: 50 < 50.304386 - 0.8617663 * ( 1 - x ) => x > 64.678823%
	
	
	
	
	