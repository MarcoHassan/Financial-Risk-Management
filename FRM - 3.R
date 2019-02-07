rm(list=ls())

## Used libraries
library(rugarch)
library(fBasics)

## Set working directory
setwd("C:/Users/Marco Hassan/Desktop/Financial Risk Management/Problem Sets/Problem Set 3/R")

## Import dataset

BK <- read.csv("C:/Users/Marco Hassan/Desktop/Financial Risk Management/Problem Sets/Problem Set 3/R/BK.csv", comment.char="#")

## Select relevant Data 
Dataset$Date <- as.character(Dataset$Date)
Dataset[Dataset$Date == "31/12/2014",]
Dataset[Dataset$Date == "31/12/2015",]

Data <- Dataset[2966:3217,] 

## Create Return Seires
Data_Return <- diff(log(Data[,2]),lag=1)


## Create good formatted type of spread series
BK <- as.vector(BK[,2])

## Model selection through Aikaike 
final.aic <- Inf
final.order <- c(0,0,0)
for (i in 0:3) for (j in 0:3) {
  current.aic <- AIC(arima(BK, order=c(i, 0, j)))
  if (current.aic < final.aic) {
    final.aic <- current.aic
    final.order <- c(i, 0, j)
    final.arma <- arima(BK, order=final.order)
  }
}

## Model selection through BIC
final.bic <- Inf
final.order <- c(0,0,0)
for (i in 0:3) for (j in 0:3) {
  current.bic <- BIC(arima(BK, order=c(i, 0, j)))
  if (current.bic < final.bic) {
    final.bic <- current.bic
    final.order <- c(i, 0, j)
    final.arma.bic <- arima(BK, order=final.order)
  }
}

final.arma.bic

## Based in Akaike MA = 2; based on Bayesian Information Criteria better MA= 0, AR = 0.

final.arma.bic$coef
final.arma$coef

## Perform a likelihood ratio test
loglarma00 <- final.arma$loglik
loglarma02 <- final.arma$loglik
lrstat <- 2*(loglarma02-loglarma00) # See lecture slides for explanation.
p.val <- 1-pchisq(lrstat,df=2) 
if (p.val>0.05) {
  print('Cannot reject ARMA(0,0) in favor of ARMA(0,2).')
}

## Box-Ljung test
Box.test(BK, lag = 20, type ="Ljung")


## Clearly not needed to extend it to an ARMA-GARCH model
par(mfrow=c(2,1))
acf((final.arma.bic$residuals)^2, main = "Autocorrelation squared residuals")
acf(abs(final.arma.bic$residuals), main = "Autocorrelation absolute returns")

## Box-Ljung test
Box.test((final.arma.bic$residuals^2), lag = 25 , type = "Ljung")

## Estimate ARMA-GARCH model

## Automated model selection through information criteria

logL <- matrix(0,nrow=3,ncol=3)
params <- matrix(0,nrow=3,ncol=3)
aic <- matrix(0,nrow=3,ncol=3)
bic <- matrix(0,nrow=3,ncol=3)
for (p in 1:3) {
  for (q in 1:3) {
    spec <- ugarchspec(mean.model=list(armaOrder=c(p,q)),variance.model=list(garchOrder=c(1,1)))
    fit <- ugarchfit(spec=spec,data= BK)
    logL[p,q] <- likelihood(fit)
    params[p,q] <- length(coef(fit))
    aic[p,q] <- infocriteria(fit)[1]
    bic[p,q] <- infocriteria(fit)[2]
  }
}


## ARMA(3,3)-GARCH(1,1) best one; get the model
spec <- ugarchspec(mean.model=list(armaOrder=c(3,3)),variance.model=list(garchOrder=c(1,1)))
fit <- ugarchfit(spec=spec,data= BK)


## Get predicted spread 1 step ahead

## Prediction ARMA
pred.arma <- predict(final.arma.bic, n.ahead = 1)

mu.arma <- pred.arma$pred
sig.arma <- pred.arma$se

## Liquidation costs in normal markets
mu.arma*10^6/100 ## / 100 as series quoted in %.

## VaR of the spread 
VaR.arma <- (as.numeric(mu.arma + qnorm(0.05)*sig.arma))*10^6/(2*100)


## Prediction ARMA(3,3)-GARCH(1,1) 
## Predict
fspec <- getspec(fit) # specification of the fitted process
setfixed(fspec) <- as.list(coef(fit))
pred <- ugarchforecast(fspec, data = BK, n.ahead = 1, out.sample = 1) # predict from the fitted process

## Extract the resulting series
mu.garch <- fitted(pred) 
sig.garch <- sigma(pred) 

## VaR of the spread
VaR.garch <- as.numeric(quantile(pred, probs = 0.05))*10^6/(2*100)

## Add on the top of that the unadjusted VaR from a GARCH(1,1) on the security
spec <- ugarchspec(mean.model=list(armaOrder=c(0,0), include.mean=F),
                   variance.model=list(model='sGARCH', garchOrder=c(1,1)),
                   distribution.model='norm')

sub_sample_garch <- ugarchfit(spec=spec,data=Data_Return)
sub_sample_csd <- ugarchforecast(sub_sample_garch,n.ahead = 1)
sub_sample_csd <- as.numeric(sigma(sub_sample_csd))
a <- 0.95
wealth <- 1000000
var_garch_r <- qnorm(1-a)*sub_sample_csd + mean(Data_Return)
var_garch_w <- wealth*(1-exp(var_garch_r))

## Adjusted VaR
Var_ARMA_adjusted <- var_garch_w + VaR.arma
Var_GARCH_adjusted <- var_garch_w + VaR.garch


## One factor Copula model for credit risk

## Create factors 
fact_ors <- c(2,1,0,-1,-2)

## Output table
prob_default <- rep(0, 5)
prob_min_8_survival <- rep(0,5)

for(i in 1:5){
  ## Probability of survival
  ran_var <- (pnorm(0.96)-sqrt(0.25)*fact_ors[i])/(sqrt(1-0.25))
  prob_default[i] <- 1- pnorm(ran_var)
  
  ## probability more than 8 defaults
  prob_min_8_survival[i] <- 1-pbinom(8, 125, prob_default[i])
}
