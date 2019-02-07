
## Libraries
library(plotrix)
library(evir) 
library(evd) 
library(fExtremes)
library(mgcv)
library(ismev)
library(ggplot2)
library(xts)
library(fGarch)
library(moments)
library(rugarch)
library(reshape2)


## Import dataset

setwd("C:/Users/Marco Hassan/Desktop/Financial Risk Management/Problem Sets/Problem Set 2/R")

Dataset <- read.csv("C:/Users/Marco Hassan/Desktop/Financial Risk Management/Problem Sets/Problem Set 2/R/Dataset")

## Select relevant Data
Dataset$Date <- as.character(Dataset$Date)
Dataset[Dataset$Date == "06/10/2008",]
Dataset[Dataset$Date == "12/09/2008",]

Data <- head(Dataset, 1396) ## for september replace with 1380

## Create Return Seires
Data$Return <- rep(NA, 1396)

for (i in 2:1396){
  Data$Return[i] <- log(Data$Adj.Close[i]) - 
      log(Data$Adj.Close[i-1])
}

## Sorting observatuions

sorted_Data <- sort(Data$Return)

## Create a vector with different over-the threshold observations

CT <- c(5:500)
T <- length(sorted_Data)

## Selction of VaR quantile
p <- 0.01

## Create empty vectors
VaR <- rep(NA, length(CT))
iota <- rep(NA, length(CT))
threshold <- rep(NA, length(CT))

## Estimate the shape parameter for different threshold levels

for (i in 1:length(CT)){
  threshold[i] <- sorted_Data[CT[i]+1]
  iota[i] <- 1/mean(log(sorted_Data[1:CT[i]]/threshold[i]))
  VaR[i] <- threshold[i]*(CT[i]/(T*p))^(1/iota[i]) 
}

estimator <- 1/iota


## Calculate mean excess return and confidence interval
mean_excess <- rep(0, length(CT))
error <- rep(0, length(CT))

for(i in 1:length(CT)){
  mean_excess[i] <- (100*rowsum(sorted_Data, sorted_Data<threshold[i])[2])/(sum(sorted_Data<threshold[i]))
}

abb <- data.frame(threshold, mean_excess)

## Plot mean excess return
ggplot(abb, aes(x= abb$threshold, y = abb$mean_excess))+
  geom_point(alpha = 0.2)+
  geom_vline(xintercept= -0.005, linetype = "3313", col = "red", lwd = 1)+
  xlab("threshold")+ ylab("mean excess")+ ggtitle("Mean Excess return vs Threshold")


## Plot iota
dat_gg <- data.frame(CT, iota)

ggplot(dat_gg, aes(x= dat_gg$CT, y = dat_gg$iota))+
  geom_line(aes(y = dat_gg$iota), col = "blue", lwd = 1)+
  geom_smooth(method = "loess", formula = y ~ x, span = 0.8, col ="black")+
  xlab("Threshold") + ylab("iota")+ ggtitle("Iota estimator")+ 
  theme_bw()

## Estimate the VaR on the 5% quantile
p_new <- 0.05
VaR_0.95 <- rep(NA, length(CT))

for (i in 1:length(CT)){
  VaR_0.95[i] <- threshold[i]*(CT[i]/(T*p_new))^(1/iota[i])
}

par(mfrow = c(2,1))
## Plot of 99%-VaR and iota on threshold
twoord.plot(CT, VaR, iota, type = "l", lwd = 1, main="99%-VaR and iota", ylab = "VaR", rylab="iota")

## Plot of 95%-VaR and iota on threshold
twoord.plot(CT, VaR_0.95, iota,type = "l", main="95%-VaR and iota", ylab = "VaR", rylab="iota")


## To get valid threshold range for hill estimaton
par(mfrow=c(1,1))
plot.new()
hill(Data$Return[-1]*-100, option = "alpha", ci = 0.95, start = 5, end = 500, labels = F)
abline(v=55, col="blue", lty=2, lwd=1) ## for september replace with 20
abline(v=20, col="blue", lty=2, lwd=1) ## for september replace with 8
title(main="Iota estimator for different thresholds",
      sub = "Over the threshold observations",
      ylab = "iota", 
      line = 3.25)
title(main="Returns * -100", line = 2.25, cex.main = 0.8)



## focussing on the selected optimal threshold
threshold_new <- threshold[(20-5):(55-5)]
CT_new <-CT[20:55] 
VaR_new <- VaR[(20-5):(55-5)]*100
VaR_0.95_new <- VaR_0.95[(20-5):(55-5)]*100

fg <- data.frame(CT_new, VaR_new, VaR_0.95_new)

ggplot(fg, aes(x= fg$CT_new, y = fg$VaR_new))+
  geom_line(aes(y = fg$VaR_new), col= "black", lwd=1)+
  geom_hline(yintercept = mean(fg$VaR_new), col ="red")+
  ylab("VaR*100")+ xlab("Over the threshold observations")+ ggtitle("99% VaR for optimal threshold")

ggplot(fg, aes(x= fg$CT_new, y = fg$VaR_0.95_new))+
  geom_line(aes(y = fg$VaR_0.95_new), col= "black", lwd=1)+
  geom_hline(yintercept = mean(fg$VaR_0.95_new), col ="red")+
  ylab("VaR*100")+ xlab("Over the threshold observations")+ ggtitle("95% VaR for optimal threshold")

## To get 99% and 95% VaR for comparison with GARCH VaR:

absolute_99_VaR <- (exp(mean(VaR_new/100))-1)*10^6
absolute_95_VaR <- (exp(mean(VaR_0.95_new/100))-1)*10^6

## VaR(p) using a Conditional-EVT approach from standardized GARCH(1,1) residuals

## Obtain GARCH volatilities
sigma_garch <- garchFit(~garch(1,1), data = Data$Return[-1])@sigma.t

sigma_forecast <- predict(garchFit(~garch(1,1), data = Data$Return[-1]), 1)

## Standardized returns
standardized_returns <- (Data$Return[-1]- mean(Data$Return[-1]))/sigma_garch

## Repeat EVT VaR computation for standardized returns
## Sorting observatuions

sorted_standardized <- sort(standardized_returns)

## Create a vector with different over-the threshold observations

CT <- c(5:500)
T <- length(standardized_returns)

## Selction of VaR quantile
p <- 0.01

## Create empty vectors
VaR_standardized <- rep(NA, length(CT))
iota_standardized <- rep(NA, length(CT))
threshold_standardized <- rep(NA, length(CT))

## Estimate the shape parameter for different threshold levels

for (i in 1:length(CT)){
  threshold_standardized[i] <- sorted_standardized[CT[i]+1]
  iota_standardized[i] <- 1/mean(log(sorted_standardized[1:CT[i]]/threshold_standardized[i]))
  VaR_standardized[i] <- threshold_standardized[i]*(CT[i]/(T*p))^(1/iota_standardized[i]) 
}

estimator_standardized <- 1/iota_standardized

## Compare normal to standardized returns VaR
par(mfrow = c(1,2))
plot(VaR_standardized, type = "l", lwd = 1.5, col = "blue", ylab = "99% - stadardized VaR", 
     xlab = "Excedeences observations", main = "Standardized Returns")
plot(VaR, type = "l", lwd = 1.5, col = "blue", ylab = "99% - VaR", 
     xlab = "Excedeences observations", main = "Normal Returns")


## Comparison VaR with standardized VaR
stand_var_reformulated <- stdev(Data$Return[-1])*VaR_standardized

overlap <- data.frame(CT, stand_var_reformulated, VaR)

overlap <- melt(overlap, id.vars = "CT")


ggplot(overlap, aes(x=overlap$CT, value, linetype=variable))+
  geom_line(lwd=1)+
  geom_hline(yintercept = mean(stand_var_reformulated), col ="black")+
  geom_hline(yintercept = mean(VaR), col ="black", linetype = "3313")+
  theme(legend.title =element_blank())+
  scale_linetype_discrete(labels=c("standardized VaR", "VaR"))+
  ggtitle("VaR comparison")+ ylab("99%-VaR") + xlab("Exceedence observations")


## VaR EVT with present turbolence

## Get stable Hill
par(mfrow=c(1,1))
plot.new()
hill(standardized_returns, option = "alpha", ci = 0.95, start = 5, end = 500, labels = F)
abline(v=52, col="blue", lty=2, lwd=1) ## for september replace with 20
abline(v=26, col="blue", lty=2, lwd=1) ## for september replace with 8
title(main="Iota estimator for different thresholds",
      sub = "Over the threshold observations",
      ylab = "iota", 
      line = 3.25)
title(main="Returns", line = 2.25, cex.main = 0.8)

## Estimate mean VaR in the stable part with present turbolence in the selected optimal threshold

VaR_0.99_stand_new <- mean(VaR_standardized[(26-5):(52-5)])*sigma_forecast$standardDeviation

absolute_99_stand_VaR <- (exp(VaR_0.99_stand_new)-1)*10^6



######################################
#Plots for theoretical argumentations#
######################################

dat <- Data$Return[-1]

d<- density(dat) # returns the density data
plot(d, xlab = "Returns", lty ="dotted",col="red", lwd =3, main = "Denisty comparison")
xfit<-seq(min(dat),max(dat),length=100) 
yfit<-dnorm(xfit,mean=mean(dat),sd=sd(dat)) 
lines(xfit, yfit, col="blue", lty = "dotted", lwd=2)
legend(-0.3, 30, legend=c("empirical denisty", "normal denisty"),
       col=c("red", "blue"), lty="dotted", cex=0.8)

## QQ-plots
qqnorm(dat); qqline(dat, col ="red")



## Argumentation through block maxima
gev(-Data$Return[-1], block = 100) ## notice yimes -1 as parameters are defined for right tail.


## Extract gev values manually due to internal function reading of R
a <- c(0.04249923, 0.03725163, 0.04956138, 0.02598405, 0.04470006, 0.03991969,
       0.02529192, 0.04982210, 0.02504827, 0.03908797, 0.04309188, 0.05441146,
       0.07683057, 0.31687448)

fgev(a)
plot(profile(fgev(a))) 
confint(profile(fgev(a)),level=0.95) 

## Argumentation through POT
gpd.fitrange(-Data$Return[-1],0.0038, 0.088,
             nint=496, show = T)


## Plotiing domain of Fisher-Tippett domain of attraction distributions
x <- seq(-15, 15, by=0.1)
Gumbel_density <- exp(-x-exp(-x))
Frechet_density <- dgev(x, xi=0.3, mu=0)
Weibull_density <- dgev(x, xi=-0.3, mu=0)

plot(c(x,x,x), c(Gumbel_density,Frechet_density, Weibull_density),
     type='n', xlab="x", ylab=" ",las=1, main = "Fisher-Tippett domain of attraction distributions")
lines(x, Gumbel_density, type='l', lty=1, col='green')
lines(x, Weibull_density, type='l', lty=2, col='blue')
lines(x, Frechet_density, type='l', lty=3, col='red')
legend('topright', legend=c('Gumbel','Weibull', 'Frechet'), lty=c(1,2,3), col=c('green','blue','red'))
