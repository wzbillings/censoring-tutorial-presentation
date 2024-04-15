//
// Interval censoring in HAI titer outcome
// with one uncensored x value
// Zane Billings
// 2024-04-15
//

// The input data include the number of observations N;
// a predictor variable x; and the lower limit y_l and upper limit y_u
// of the outcome in survival-like interval2 format.
// c is a vector of censoring statuses which is -1 for left censored, 0 for
// uncensored, 1 for right censored, 2 for interval censored, since stan
// will not permit evaluation of normal_lcdf() at infinite values
data {
  int<lower=0> N;
  vector[N] y_l;
  vector[N] y_u;
  vector[N] x;
  vector[N] c;
}

// The parameters accepted by the model.
parameters {
  real a;
  real b;
  real<lower=0> sigma;
}

// The model to be estimated.
model {
	sigma ~ exponential(1);
	a ~ normal(0, 2);
	b ~ normal(0, 2);
	
	vector[N] mu;
	for (i in 1:N) {
		// calculate the mean of the current observation
		mu[i] = a + b * x[i];
		// update the target likelihood appropriately depending on whether it is
		// censored or not.
		// No censoring case
		if (c[i] == 0)
			target += normal_lpdf(y_l[i] | mu[i], sigma);
		else if (c[i] == -1)
			target += normal_lcdf(y_u[i] | mu[i], sigma);
		else if (c[i] == 1)
			target += normal_lccdf(y_l[i] | mu[i], sigma);
		else if (c[i] == 2)
			target += log_diff_exp(
				normal_lcdf(y_u[i] | mu[i], sigma),
				normal_lcdf(y_l[i] | mu[i], sigma)
			);
	}
}

