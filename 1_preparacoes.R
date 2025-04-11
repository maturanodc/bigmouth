library(tidyverse)
library(sf)
library(spdep)
library(geosphere)
setwd("Z:/Arquivos IFB/Paper - Covid Bolsonaro/")
rm(list=ls()); gc()

## Distances OD-matrix
munic <- st_read("data/raw/BR_Municipios_2020.shp") %>%
  mutate(codmun7 = as.numeric(CD_MUN)) %>% select(codmun7, geometry)
munic <- munic[order(munic$codmun7),]

distancias <- cbind(
  munic %>% as.data.frame() %>% select(codmun7),
  distm(
    x = st_coordinates(st_centroid(munic)$geometry),
    y = st_coordinates(st_centroid(munic)$geometry),
    fun = geosphere::distHaversine
  ) %>% as_tibble()/1000
)

colnames(distancias) <- as.data.frame(rbind("codmun7",
                          cbind("dist_", munic %>% as.data.frame() %>%
                          select(codmun7)) %>% rename(v1 = '"dist_"',
                          v2 = 'codmun7') %>% unite(id, v1, v2,
                          sep = "") %>% select(id)))$id

haven::write_dta(distancias, "data/distancias.dta")

distancias <- distancias %>% 
  mutate(lat = st_coordinates(st_centroid(munic)$geometry)[,"Y"],
         lon = st_coordinates(st_centroid(munic)$geometry)[,"X"]) %>% 
  select(codmun7, lat, lon)

contato <- cbind(
  munic %>% as.data.frame() %>% select(codmun7),
  nb2mat(
    poly2nb(munic),
    style = "B",
    zero.policy = TRUE
  ) %>% as_tibble()
)

colnames(contato) <- as.data.frame(rbind("codmun7",
                      cbind("adj_", munic %>% as.data.frame() %>%
                      select(codmun7)) %>% rename(v1 = '"adj_"',
                      v2 = 'codmun7') %>% unite(id, v1, v2,
                      sep = "") %>% select(id)))$id

contato <- contato %>% merge(distancias, by = "codmun7")

haven::write_dta(contato, "data/contato.dta")
