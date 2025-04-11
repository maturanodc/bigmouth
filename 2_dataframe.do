**# Dataframe construction
/*------------------------------------------------------------------------------
2_dataframe.do uses every dataset from /data/raw/, distancias.dta and 
contato.dta from /data/. Creates various intermediate datasets in /data/,
and the final dataset.dta in /main/. Also creates data_redux.dta in /main/,
used to build Figure 1 maps.
------------------------------------------------------------------------------*/

clear all
cap set maxvar 17000
set type double

global bsa "Z:/Arquivos IFB/Paper - Covid Bolsonaro/"				// Main path for Bigmouth Strikes Again
global cen "Z:/Arquivos IFB/Censos Demográficos/Censo 2010/Dados/"	// Root path for 2010 Census data
global cap "${cen}Amostra Pessoas/"
global cad "${cen}Amostra Domicílios/"
global dat "${bsa}data/"
global raw "${dat}raw/"
global dof "${bsa}dofiles/"

cd "$bsa"

/*------------------------------------------------------------------------------
---------------------------------- ATTENTION! ----------------------------------
--------------------------------------------------------------------------------

Run R script 1_preparacoes.R in /main/ before running this do-file. It uses
shapefiles in /raw/ to create distancias.dta and contato.dta datasets in /data/,
which are used to build the main dataframe dataset.dta in /main/.

------------------------------------------------------------------------------*/

**# Census data
do "${dof}census.do"

**# Geography
do "${dof}geography.do"

**# Covid data
do "${dof}covid.do"

**# Election data
do "${dof}elec.do"

**# Controls data
do "${dof}controls.do"

**# Merge and save
do "${dof}merge.do"
