library(tidyverse)
library(mapview)
library(sf)
library(sp)
library(haven)
library(RColorBrewer)
library(scales)
setwd("Z:/Arquivos IFB/Paper - Covid Bolsonaro/"); gc(); rm(list=ls())

data <- merge(st_read("data/raw/BR_Municipios_2020.shp") %>% 
                mutate(codmun7 = as.numeric(CD_MUN)) %>% 
                select(geometry, codmun7),
              read_dta("dataset_redux.dta"),
              by = "codmun7")

k <- 10000000/(6*max(data$populacao)) + 5/6

p <- ggplot(data) +
  geom_sf(
    aes(fill = y),
    color = NA
  ) + 
  scale_fill_gradientn(
    colors = rev(brewer.pal(11, "Spectral")),
    limits = c(0,1),
    breaks = c(0,1/6,1/3,1/2,2/3,5/6,k),
    labels = c("0","5k","15k","50k","200k","1mi","10mi")
  ) +
  theme_void() +
  theme(
    legend.position = "inside",
    legend.position.inside = c(.2,.35),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_rect(fill="white", color = "white"),
    legend.title = element_blank()
  ); ggsave(
    "figures/Fig_2a.pdf",
    plot = p,
    width = 150,
    height = 160,
    units = "mm"
  )

p <- ggplot(data) +
  geom_sf(
    aes(fill = isol),
    color = NA
  ) + 
  scale_fill_gradientn(
    colors = brewer.pal(11, "Spectral")
  ) +
  theme_void() +
  theme(
    legend.position = "inside",
    legend.position.inside = c(.2,.35),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_rect(fill="white", color = "white"),
    legend.title = element_blank()
  ); ggsave(
    "figures/Fig_2b.pdf",
    plot = p,
    width = 150,
    height = 160,
    units = "mm"
  )

p <- ggplot(data) +
  geom_sf(
    aes(fill = del),
    color = NA
  ) + 
  scale_fill_gradientn(
    colors = brewer.pal(11, "Spectral")
  ) +
  theme_void() +
  theme(
    legend.position = "inside",
    legend.position.inside = c(.2,.35),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_rect(fill="white", color = "white"),
    legend.title = element_blank()
  ); ggsave(
    "figures/Fig_2c.pdf",
    plot = p,
    width = 150,
    height = 160,
    units = "mm"
  )
