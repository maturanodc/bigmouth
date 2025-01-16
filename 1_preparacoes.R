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

## SIRD dataframes creation
i0 <- 10^(-4)
beta <- 0.02
gamma <- 0.004
delta <- 0.001
phi1 <- 1 
phi2 <- 1/4
phi3 <- 10^(-2)

df1 <- data.frame(matrix(ncol = 9, nrow = 0))
df2 <- data.frame(matrix(ncol = 9, nrow = 0))
df3 <- data.frame(matrix(ncol = 9, nrow = 0))
colnames(df1) <- c("t", "sa", "ia", "ra", "da", "sb", "ib", "rb", "db")
colnames(df2) <- c("t", "sa", "ia", "ra", "da", "sb", "ib", "rb", "db")
colnames(df3) <- c("t", "sa", "ia", "ra", "da", "sb", "ib", "rb", "db")
df1[1,] <-       c( 0,   1,    0,    0,    0,    1-i0, i0,   0,    0)
df2[1,] <-       c( 0,   1,    0,    0,    0,    1-i0, i0,   0,    0)
df3[1,] <-       c( 0,   1,    0,    0,    0,    1-i0, i0,   0,    0)

for (i in 1:2000){
  df1[i+1,1] <- i
  
  df1[i+1,2] <- df1[i,2] * (1 - beta * (df1[i,3] + phi1 * df1[i,7]))
  df1[i+1,3] <- df1[i,3] * (1 - gamma - delta) + beta * df1[i,2] * (df1[i,3] + phi1 * df1[i,7])
  df1[i+1,4] <- df1[i,4] + gamma * df1[i,3]
  df1[i+1,5] <- df1[i,5] + delta * df1[i,3]
  
  df1[i+1,6] <- df1[i,6] * (1 - beta * (df1[i,7] + phi1 * df1[i,3]))
  df1[i+1,7] <- df1[i,7] * (1 - gamma - delta) + beta * df1[i,6] * (df1[i,7] + phi1 * df1[i,3])
  df1[i+1,8] <- df1[i,8] + gamma * df1[i,7]
  df1[i+1,9] <- df1[i,9] + delta * df1[i,7]
}

for (i in 1:2000){
  df2[i+1,1] <- i
  
  df2[i+1,2] <- df2[i,2] * (1 - beta * (df2[i,3] + phi2 * df2[i,7]))
  df2[i+1,3] <- df2[i,3] * (1 - gamma - delta) + beta * df2[i,2] * (df2[i,3] + phi2 * df2[i,7])
  df2[i+1,4] <- df2[i,4] + gamma * df2[i,3]
  df2[i+1,5] <- df2[i,5] + delta * df2[i,3]
  
  df2[i+1,6] <- df2[i,6] * (1 - beta * (df2[i,7] + phi2 * df2[i,3]))
  df2[i+1,7] <- df2[i,7] * (1 - gamma - delta) + beta * df2[i,6] * (df2[i,7] + phi2 * df2[i,3])
  df2[i+1,8] <- df2[i,8] + gamma * df2[i,7]
  df2[i+1,9] <- df2[i,9] + delta * df2[i,7]
}

for (i in 1:2000){
  df3[i+1,1] <- i
  
  df3[i+1,2] <- df3[i,2] * (1 - beta * (df3[i,3] + phi3 * df3[i,7]))
  df3[i+1,3] <- df3[i,3] * (1 - gamma - delta) + beta * df3[i,2] * (df3[i,3] + phi3 * df3[i,7])
  df3[i+1,4] <- df3[i,4] + gamma * df3[i,3]
  df3[i+1,5] <- df3[i,5] + delta * df3[i,3]
  
  df3[i+1,6] <- df3[i,6] * (1 - beta * (df3[i,7] + phi3 * df3[i,3]))
  df3[i+1,7] <- df3[i,7] * (1 - gamma - delta) + beta * df3[i,6] * (df3[i,7] + phi3 * df3[i,3])
  df3[i+1,8] <- df3[i,8] + gamma * df3[i,7]
  df3[i+1,9] <- df3[i,9] + delta * df3[i,7]
}

dfA <- cbind(
  t = seq(0,2000,1),
  df1 %>% mutate(
    i_phi1 = ia,
    c_phi1 = ia + ra + da
  ) %>% select(i_phi1,c_phi1),
  df2 %>% mutate(
    i_phi2 = ia,
    c_phi2 = ia + ra + da
  ) %>% select(i_phi2,c_phi2),
  df3 %>% mutate(
    i_phi3 = ia,
    c_phi3 = ia + ra + da
  ) %>% select(i_phi3,c_phi3)
)

dfB <- cbind(
  t = seq(0,2000,1),
  df1 %>% mutate(
    i_phi1 = ib,
    c_phi1 = ib + rb + db
  ) %>% select(i_phi1,c_phi1),
  df2 %>% mutate(
    i_phi2 = ib,
    c_phi2 = ib + rb + db
  ) %>% select(i_phi2,c_phi2),
  df3 %>% mutate(
    i_phi3 = ib,
    c_phi3 = ib + rb + db
  ) %>% select(i_phi3,c_phi3)
)

haven::write_dta(dfA, "SIRDA.dta")
haven::write_dta(dfB, "SIRDB.dta")

## Vaccination hypotheses
rm(list=ls()); gc()
i0 <- 10^(-4)
beta <- 0.02
gamma <- 0.004
gamma. <- 0.00475
delta <- 0.001
delta. <- 0.00025
phi <- 10^(-3)
tv <- 751

df <- data.frame(matrix(ncol = 11, nrow = 0))
colnames(df) <- c("t", "sa", "ia", "ra", "da", "sb", "ib", "rb", "db", "da2", "db2")
df[1,] <-       c( 0,   1,    0,    0,    0,    1-i0, i0,   0,    0, 0 ,0)

for (i in 1:2500){
  df[i+1,1] <- i
  
  df[i+1,2] <- df[i,2] * (1 - beta * (df[i,3] + phi * df[i,7]))
  df[i+1,3] <- df[i,3] * (1 - ifelse(i<tv,gamma,gamma.) - ifelse(i<tv,delta,delta.)) + beta * df[i,2] * (df[i,3] + phi * df[i,7])
  df[i+1,4] <- df[i,4] + ifelse(i<tv,gamma,gamma.) * df[i,3]
  df[i+1,5] <- df[i,5] + ifelse(i<tv,delta,delta.) * df[i,3]
  
  df[i+1,6] <- df[i,6] * (1 - beta * (df[i,7] + phi * df[i,3]))
  df[i+1,7] <- df[i,7] * (1 - ifelse(i<tv,gamma,gamma.) - ifelse(i<tv,delta,delta.)) + beta * df[i,6] * (df[i,7] + phi * df[i,3])
  df[i+1,8] <- df[i,8] + ifelse(i<tv,gamma,gamma.) * df[i,7]
  df[i+1,9] <- df[i,9] + ifelse(i<tv,delta,delta.) * df[i,7]
  
  df[i+1,10] <- df[i,10] + delta * df[i,3]
  df[i+1,11] <- df[i,11] + delta * df[i,7]
}

haven::write_dta(df, "vaccination.dta")
