
// This model infers a random bias from a sequences of 1s and 0s (right and left hand choices)

// The input (data) for the model. n of trials and the sequence of choices (right as 1, left as 0)
data {
 int<lower=1> n; // n of trials
 array[n] int h; // sequence of choices (right as 1, left as 0) as long as n
}

// The parameters that the model needs to estimate (theta)
parameters {
    real theta; // note it is unbounded as we now work on log odds
}

// The model to be estimated (a bernoulli, parameter theta, prior on the theta)
model {
  // The prior for theta on a log odds scale is a normal distribution with a mean of 0 and a sd of 1.
  // This covers most of the probability space between 0 and 1, after being converted to probability.
  target += normal_lpdf(theta | 0, 1);
  
  // The model consists of a bernoulli distribution (binomial w 1 trial only) with a rate theta,
  // note we specify it uses a logit link (theta is in logodds)
  target += bernoulli_logit_lpmf(h | theta);
  
}

generated quantities{
  real<lower=0, upper=1> theta_prior;  // theta prior parameter, on a prob scale (0-1)
  real<lower=0, upper=1> theta_posterior; // theta posterior parameter, on a prob scale (0-1)
  int<lower=0, upper=n> prior_preds;
  int<lower=0, upper=n> posterior_preds;
  
  theta_prior = inv_logit(normal_rng(0,1)); // generating the prior on a log odds scale and converting
  theta_posterior = inv_logit(theta);  // converting the posterior estimate from log odds to prob.
  prior_preds = binomial_rng(n, theta_prior);
  posterior_preds = binomial_rng(n, inv_logit(theta));
}

