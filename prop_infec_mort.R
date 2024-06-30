library(foreach)
library(tidyverse)
library(ggplot2)

deathtoll <- data.frame(
  "I_0" = c(
    seq(from = 0.01, to = 1, by = 0.01),
    "mu", "rho", "iota"
  )
)

for (j in 1:1000) {
  set.seed(j)
  
  mu <- runif(1, 0, 1)
  rho <- runif(1, 0, 1)
  iota <- runif(1, 0, 1)
    
  for (i in 1:100) {
      
    df <- data.frame(T = 0, S = 1 - i/100, I = i/100, R = 0, D = 0)
      
    for (t in 1:1000) {
      
      lnova <- data.frame(
        T = t,
        S = df[t,2] * (1 - iota * df[t,3] ),
        I = df[t,3] * (1 + iota * df[t,2] - rho - mu),
        R = df[t,4] + rho * df[t,3],
        D = df[t,5] + mu * df[t,3]
      )
        
      df <- rbind(df,lnova)
      
    }
      
    deathtoll[i,j + 1] <- df[1001,5]
      
  }
  
  deathtoll[101, j + 1] <- mu
  deathtoll[102, j + 1] <- rho
  deathtoll[103, j + 1] <- iota
    
}

ggplot(data=deathtoll[1:100,], aes(x=I_0, y=V2, group=1)) + 
  geom_line() + scale_x_discrete(breaks = seq(0, 1, by = .10)) +
  xlab("I(0), mu = 0.266, rho = 0.372, iota = 0.573") +
  ylab("D(infinty)") + theme_classic()

ggplot(data=deathtoll[1:100,], aes(x=I_0, y=V3, group=1)) + 
  geom_line() + scale_x_discrete(breaks = seq(0, 1, by = .10)) +
  xlab("I(0), mu = 0.185, rho = 0.702, iota = 0.573") +
  ylab("D(infinty)") + theme_classic()

# ...


