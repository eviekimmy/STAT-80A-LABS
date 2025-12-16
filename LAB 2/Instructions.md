## Overview

This Lab revolves around simulating spins from a roulette wheel. You will 
compare different bets and their convergence to their expected profits, as well 
as compare frequencies between a biased and unbiased wheel. There will also be 
some brief discussion of Chebyshev's Theorem (equations provided). For 
additional help, refer to Chapter 3 of the textbook. Answer the questions using 
the corresponding Canvas quiz. 

## Set Seed
Please set the random seed to the last 4 digits of your Student ID (if using 
your ID card, your Student ID is the number between the 2 dashes). 

## Part I: Comparing Betting Strategies
For this lab, we will focus on four different kinds of bets: Straight up bets, 
split bets, red or black, and first to third dozen. The payouts are 35:1, 17:1, 
1:1, and 2:1. They are set in such a way that the expected profit for each bet 
is -2/38 for a \$1 bet. Out of 38 pockets, the number of pockets that 
correspond to each bet are 1, 2, 18, and 12. 

Calculate the variance for each bet if the betting amount is \$1. 

Set the betting amounts to $1. Focus on the first plot, which shows the running 
average profit as more spins are generated. Compare this to the dotted line, 
which is the expected profit each running average should converge to. Are there 
any bets that take longer to converge than others? Is there a relationship 
between the variance of a bet and how long it takes to converge?

Now, adjust the bets so you bet \$3 on red and \$2 on the 2nd dozen, and the 
remaining bets are 0. The running average of the combined bet is shown in the 
second plot. Adjust the plot so only the dozen and color bet are shown. Fill out 
the table on the Canvas quiz and use it to calculate the mean and variance. 

| Outcome                   | Prob | Profit |
|:-------------------------:|:----:|:------:|
| Red in second dozen       |  -   |    -   |
| Black in second dozen     |  -   |    -   |
| Red not in second dozen   |  -   |    -   |
| Black not in second dozen |  -   |    -   |

How does the variance of this combined bet compare to the individual variances 
of the betting on red and the 2nd dozen? Does the behavior between these two 
plots agree with this relationship? 

The mean of this combined bet can also be calculated separately:

X = profit from red/black bet <br>
Y = profit from dozen bet

$$
\begin{aligned}
\mathbb{E}[3X + 2Y] &= 
5\mathbb{E}[X] + 2\mathbb{E}[Y]  \\ 
&\approx 3(-0.0526) + 2(-0.0526) \\ 
&\approx -0.263
\end{aligned}
$$

How can this equation make calculations easier? Can this equation be extended to 
variance?

What are the pros and cons of combining bets (Hint: compare the mean and 
variance between the combined bets and individual bets). 

## Part II: Bias Detection
Switch the panel to "Bias Detection." For this section, you will adjust the bias 
of pockets 2,4, and 21, as well as how many spins are performed. The left plot 
displays the frequency of each pocket when there is a bias, while the right plot 
corresponds to an even wheel. Make sure the bias is set to 0.033 and the number 
of spins to 10,000. 

If you did not know beforehand that 2,4, and 21 were biased, would you be able 
to distinguish the biased wheel from the unbiased one based on these 
frequencies? 

Increase the number of spins until pockets 2,4, and 21 
exceed 1500 and the remaining pockets are below 1500 (this should occur around 
50,000. If this does not happen, then keep increasing until you get 100,000 
spins). 

Do the same with bias. Keep the number of spins at 10,000 and increase the bias 
until the biased pockets are above 150 (This should occur around 0.037. If this 
doesn't happen, increase the bias to 0.04). 

Report both of these values into the Canvas quiz.

## Part III: Chebyshev

In the previous section, you found the number of spins needed to distinguish 
which pockets are biased when they each have a probability of 0.033 occurring. 
In addition, you found the how biased 2,4, and 21 need to be in order to 
distinguish them at 10,000 spins. These were computed by evaluating whether the 
biased pockets are above a certain threshold (above 1500 when keeping biased 
fixed, and above 150 when keeping number of spins fixed). If we want to make 
these standard procedures for detecting biased wheels, it would be important to 
know how reliable this method is (i.e. how often this procedure works vs doesn't 
work). One way to do that is to use Chebyshev's Inequality:

$$
P(|\frac{z}{n} - P(A)| > \epsilon) \leq \frac{P(A)[1-P(A)]}{n\epsilon^2}
$$

Here, $z$ is the combined frequency of the biased wheels, $n$ is the number 
of spins, $P(A)$ is the combined bias of the three pockets, and $\epsilon$ is 
the difference we want to compare. 

First, let's calculate this for when the bias is fixed at 0.033. Calculate the 
following:

$\frac{z}{n} = \frac{3(1500)}{n}$

$P(A) = 3(0.033) = 0.099$

$\epsilon = |\frac{z}{n} - P(A)|$

*If you had to increase the number of spins to 100,000, use*

$\frac{z}{n} = \frac{3(3000)}{100,000} = 0.09$

Note that since $\frac{z}{n}$ is lower than $P(A)$, and the actual combined 
frequencies of biased pockets is slightly higher than 3*1500, our observed 
frequencies are within $\epsilon$. Now, calculate the upper bound probability. 

Do the same for when number of spins is fixed at 10,000.

$\frac{z}{n} = \frac{3(300)}{10,000} = 0.09$

$P(A) = 3(p_{bias})$

$\epsilon = |\frac{z}{n} - P(A)|$

When recording these upper bounds, round up at four decimals (e.g. round 
0.03341 to 0.0335). 

Do the values you recorded give you confidence that these procedures for 
detecting bias are reliable (e.g. is it rare that your combined frequency will 
be less than the threshold you set)? The thresholds are 150 and 1500 depending 
on what amount of bias you wish to detect. 












