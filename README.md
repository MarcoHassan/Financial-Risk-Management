# R-Financial-Risk-Management

Authors: Marco Hassan

Semester exercise for a lecture in Financial Risk Management at the University of St. Gallen.

The goal is to model financial returns incorporating clustering and heteroskedasticity of returns as well as with fat tailed distributions based on extreme value theory and check how the different models would have performed in the financial crises of 2007.

# Part 1

In this part a univariate financial times series analysis is performed. 

The classical features of returns is observed, where there is little or no autocorrelation in the first moment, conferming the hypothesis of i.i.d. returns.

![image](https://user-images.githubusercontent.com/42472072/52468141-76354b80-2b90-11e9-8ff2-a2ab430bd232.png)

Despite of that there is clustering of returns in the series and the squared returns that represent a proxy for the unobserved volatility measure show profund autocorrelation.

![image](https://user-images.githubusercontent.com/42472072/52468219-ba285080-2b90-11e9-92b9-6c76022cd63a.png)

![image](https://user-images.githubusercontent.com/42472072/52468211-ac72cb00-2b90-11e9-9da6-7e490752c7a6.png)

This together with the empirical observed leptokurtic distribution of returns suggests for an alternative modelling of returns as simply modelling returns through linear times series models with the additional assumption of normally distributed returns will not capture the clustering of returns nor the heavy tails of the distribution.


![image](https://user-images.githubusercontent.com/42472072/52468337-18553380-2b91-11e9-873e-a04427ee4640.png)

This is addressed in a first step by modelling the heteroskedastic component of returns through the classical GARCH model.

After applying the most basic GARCH model an evalutation checks at the asymmetric effect of negative vs. positive returns for the subsequent returns observing a higher effect of negative in influencing the volatility in the market.

A the GJR-GARCH model incorportating such effect is hence evalued and used for further evalutations.

Finally, the two classical risk measures of the **Value at Risk** and **Expected Shortfall** are computed using both a linear times series modelling via an ARMA(2,2) and a GARCH model.

Albeit the GARCH model is shown to perform better in capturing the downturns of the financial crises of 2007 compared to an ARMA(2,2) model both results are poor and far from matching the real observed losses.


![image](https://user-images.githubusercontent.com/42472072/52468645-ff00b700-2b91-11e9-8873-6b4cdb1b4917.png)



This is the reason why we turned to **Extreme Value Theory** and the heavy tail modelling in the next part.

# Part 2

Using GARCH, the risk manager models the entire distribution of the returns. The MLestimation
of the GARCH parameters, maximize consequently the likelihood of getting the
observed returns distribution based on the assumption of GARCH-model-returns. Under the
specification of t-distribution innovation terms and asymmetric GARCH model it is then
possible to get return’s density functions with fat tails and to get reasonable estimators for
the various risk-measures.

In contrast to the GARCH approach, EVT does not aim at modelling the entire distribution of
returns, but as its name suggest – extreme value theory – it focus just on the tail modelling.
This key feature of EVT makes it valuable for risk managers as it gives the right theoretical
framework to model the tail risk despite a low number of observations.
