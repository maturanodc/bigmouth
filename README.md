# ReadMe for “Bigmouth Strikes Again: Electoral Impact of Reckless Speech during a Pandemic”

  Dimitri Maturano, [dimitricm@insper.edu.br](mailto:dimitricm@insper.edu.br), April 18th, 2025.

The following file details where data for the replication of Bigmouth Strikes Again can be acquired. All data is public. Once in the appropriate folders, simply execute Stata and R scripts in order. Final data can be found [here](https://doi.org/10.7910/DVN/LNZX0T), and should be placed on `bsa` to run the estimation script.

## Glossary
`/bsa/`: Main folder. Github zip should be extracted here. Final data should be placed here. In scripts, `Z:/Arquivos IFB/Paper - Covid Bolsonaro/`

`/cen/`: Census folder. 2010 Census Microdata should be extracted here. In scripts, `Z:/Arquivos IFB/Censos Demográficos/Censo 2010/Dados/`

`/dat/`: Data subfolder of `/bsa/`. In scripts, `Z:/Arquivos IFB/Paper - Covid Bolsonaro/data/`

`/raw/`: Raw data subfolder of `/dat/`. All data, except 2010 Census Microdata, should be extracted here. In scripts, `Z:/Arquivos IFB/Paper - Covid Bolsonaro/data/raw/`

`bsa` should also have `tables` and `figures` folders for the execution of scripts.


## Data (in order of apparition)
*Shapefiles:* Municipal shapefiles are `BR_Municipios_2020.zip` in https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2020/Brasil/BR/.

*Census 2022:* https://sidra.ibge.gov.br/tabela/4714. Files should be downloaded separately and called `tabela4714_populacao.csv` and `tabela4714_densidade.csv`.

*Census 2010:* https://www.ibge.gov.br/estatisticas/sociais/populacao/9662-censo-demografico-2010.html?edicao=9754&t=downloads.
Data should be downloaded from the `Censo_Demografico_2010/Resultados_Gerais_da_Amostra/Microdados/` folder,
then converted into .CSV format onto `/cen/` and lower cased,
separating persons and households samples into different folders (`/Amostras Pessoas/` and `/Amostras Domicílios/`, respectively).

*Territorial division:* https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/23701-divisao-territorial-brasileira.html

*Mortality:* https://opendatasus.saude.gov.br/dataset/sim

*Vaccination:* https://dados.gov.br/dados/conjuntos-dados/covid-19-vacinacao1

*Cases:* https://covid.saude.gov.br/

*TSE to IBGE compatibilization:* https://github.com/betafcc/Municipios-Brasileiros-TSE

*Electoral data:* https://dadosabertos.tse.jus.br/

*BLS:* https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/WM9IZ8

*Airports:* https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-publicos-v2

*International airports:* https://github.com/ip2location/ip2location-iata-icao/blob/master/iata-icao.csv

*Coastal municipalities:* https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/34330-municipios-costeiros.html

*Hospital beds:* http://tabnet.datasus.gov.br/cgi/tabcgi.exe?cnes/cnv/leiintbr.def

*ESF Coverage:* https://relatorioaps.saude.gov.br/cobertura/ab

*Agricultural GDP:* https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html?t=downloads&c=1100304, 
under `Downloads/2021/base/base_de_dados_2010_2021_xlsx.zip`

*PBF:* https://aplicacoes.cidadania.gov.br/vis/data3/data-explorer.php

*Homicides:* https://www.ipea.gov.br/atlasviolencia/
