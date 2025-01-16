clear all
cap set maxvar 17000
set type double

global bsa "Z:\Arquivos IFB\Paper - Covid Bolsonaro\"				// Main path for Bigmouth Strikes Again
global cen "Z:\Arquivos IFB\Censos Demográficos\Censo 2010\Dados\"	// Root path for 2010 Census data
global sih "Z:\Arquivos IFB\DATASUS\SIH\DTA\" 						// Root path for hospitalization data
global cap "${cen}Amostra Pessoas\"
global cad "${cen}Amostra Domicílios\"
global dat "${bsa}data\"
global raw "${dat}raw\"
global dof "${bsa}dofiles\"
global fig "${bsa}figures\"
global tab "${bsa}tables\"

cd "$bsa"

/*------------------------------------------------------------------------------
---------------------------------- ATTENTION! ----------------------------------
--------------------------------------------------------------------------------

Run R script 1_preparacoes.R in /main/ before running this do-file. It uses
shapefiles in /raw/ to create distancias.dta and contato.dta datasets in /data/,
which are used to build the main dataframe dataset.dta in /main/. It also
generates the SIRDA.dta, SIRDB.dta and vaccination.dta datasets in /main/ used
to plot viral dynamics figures in Appendix C.

------------------------------------------------------------------------------*/

**# Dataframe construction
/*------------------------------------------------------------------------------
dataframe_construction.do uses every dataset from /data/raw/ and distancias.dta
and contato.dta from /data/. Creates various intermediate datasets in /data/,
and the final dataset.dta in /main/.
------------------------------------------------------------------------------*/

do "${dof}dataframe_construction.do"

**# Tables
/*------------------------------------------------------------------------------
tables.do uses dataset.dta in /main/ to create Tables 1 to 10, A1 to A5, and
C1 and C2 in /tables/.
------------------------------------------------------------------------------*/
do "${dofiles}tables.do"


**# Plots
/*------------------------------------------------------------------------------
plots.do uses dataset.dta in /main/ to create dataset_redux.dta in /main/, and
Figures 1 and 3a to 3d in /figures/; uses SIRDA.dta in /main/ to create Figures
C1a and C1c in /figures/; uses SIRDB.dta in /main/ to create Figures C1b and C1d
in /figures/; and uses vaccination.dta in /main/ to create Figures C2a and C2b.
------------------------------------------------------------------------------*/
do "${dofiles}plots.do"


