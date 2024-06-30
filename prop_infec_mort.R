library(foreach)
library(tidyverse)
library(ggplot2)

deathtoll <- data.frame(
  "I_0" = c(seq(from = 0.01, to = 1, by = 0.01))
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
  
  k <- paste(
    "iota = ", round(iota,digits = 3),
    ", rho = ", round(rho,digits = 3),
    ", mu = ", round(mu,digits = 3),
    sep=""
  )
  
  ggplot(
    data=deathtoll, aes(x=I_0, y=deathtoll[,j+1], group=1)
  ) + geom_line() + xlab(paste("I(0); ", k,sep = "")) +
    ylab("D(1,000)") + theme_classic()
  
}
