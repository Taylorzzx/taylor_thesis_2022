* Regression Discontinuity
* Taylor Zhang
* fuzzy RDD

* Import sample
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022"

use "charls_sample.dta", clear

* Manipulation Test: self-selection or sorting arounf the threshhold
* Cattaneo, Jansson, Ma (2017)
* null hypothesis: there is no manipulation around the threshhold
rddensity monthly_age, plot kernel(uniform) c(720) p(1)

keep if monthly_age >= 600 & monthly_age <= 480

* No jump in other variables
*rdplot covar monthly_age, kernel(uniform) c(720) p(1)

* OB:
* rdbwselect updum margin, kernel(uniform) c(720) p(1) bwselect(mserd)

* Two-stage regression 
* gen E = (age>=60)
* gen margin2 = margin*margin

* ivregress 2sls downdum (nrps_received = E) above below margin2 lnperfinan if margin >= -6 & margin <= 6, first robust
* ivregress 2sls downdum (nrps_received = E) above below margin2 lnperfinan if margin >= -6 & margin <= 6 & income_child_high == 0, first robust
