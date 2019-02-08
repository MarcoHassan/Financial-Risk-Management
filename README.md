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

Moreover, EVT parameters are not affected by the distribution of the returns in normal times,
which are of little interest to risk managers. Just tail observations are used to model the tail
distribution of returns.

Without going into detail it is now possible to use the fact that under the Fisher-Tippett theorem the only three possible domain of attraction of the normalized sequence of i.i.d. maximums with cumulative distribution F are either Fréchet, a Gumbel or a Weibull distributions. 

Given such a result and the three different distributions we proceed the analysis by trying to modelling the fat tails of the empirical distribution making by modelling them via a Fréchet distribution, which displays heavy fat tails.

![image](https://user-images.githubusercontent.com/42472072/52469191-7daa2400-2b93-11e9-927b-7596c271e340.png)

I modelled the Fréchet via the Hill-estimator.

In the following we continue our analysis based on the peak over threshold approach. Here
maxima observations do not result from the maximum in each time-series block, but from the
observations over and above a given threshold.

Selecting different thresholds, will result in different model specifications, which will report a
higher or lower number of observations.

The trade-off will be the following: a higher number of observations will increase the
estimation precision of the shape parameter; however, a higher number of observations will
come at the expense of a lower threshold where the generalized pareto distribution
approximation will not hold with the consequent bias of the results.

The Hill-estimator, relies on the peak over threshold technique, where we assume to
possibility to approximate the tail of our maxima distribution with a generalized pareto
distribution with positive shape parameter.

As the approximation works just in the very tail of the distribution and the Hill-estimator
makes use of over the threshold observations, the trade-off in the Hill-estimator is again given
by low variance vs. low bias.

To compute the Hill estimator in a consistent way we must then choose an appropriate range
of thresholds. This is chosen as the region where the Hill is stable.

Computing the Hill-estimator for a number of threshold it is then possible to approximate such given range; from the following graph this is among the 55th and the 20th over the threshold observation.

![image](https://user-images.githubusercontent.com/42472072/52469458-26588380-2b94-11e9-822e-2079feef20c9.png)

Based on the average Hill estimator over such range I subsequently estimated the VaR and ES incorporating the accordingly modelled heavy tail distribution with the following results.

![image](https://user-images.githubusercontent.com/42472072/52469650-b7c7f580-2b94-11e9-8106-6ec5b1e39601.png)



