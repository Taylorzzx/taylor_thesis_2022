* Taylor Zhang
* append all four wave dataset

cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022"

use "CHARLS_2011/charls_2011.dta", clear
append using "CHARLS_2013/charls_2013.dta"
append using "CHARLS_2015/charls_2015.dta"
append using "CHARLS_2018/charls_2018.dta"

* calculate monthly_age
destring iyear imonth, replace
gen monthly_age = (iyear - age_year_ID )*12 + imonth-age_month_ID

* dummies of upstream and downstream support
gen updum = (upsupport > 0)
replace updum = . if upsupport == .
gen downdum = (downsupport > 0)
replace downdum = . if downsupport == .
gen updum_inkind = (upsupport_inkind > 0)
replace updum_inkind = . if upsupport_inkind == .
gen downdum_inkind = (downsupport_inkind > 0)
replace downdum_inkind = . if downsupport_inkind == .

* logs of upstream and downstream support
gen lnupsupport = log(upsupport)
replace lnupsupport = 0 if upsupport == 0
gen lndownsupport = log(downsupport)
replace lndownsupport = 0 if downsupport == 0
gen lnupsupport_inkind = log(upsupport_inkind)
replace lnupsupport_inkind = 0 if upsupport_inkind == 0
gen lndownsupport_inkind = log(downsupport_inkind)
replace lndownsupport_inkind = 0 if downsupport_inkind == 0

* round the emosupport (calculated by rowmean)
gen emosupport_r = round(emosupport)
gen emodum = (emosupport_r > 0)
replace emodum = . if emosupport_r == .

* values of education in 2015 need to change since 12 means no change (actually =1)
replace educ = 1 if educ == 12 & year == 2015

* personal financing
egen perfinan = rowtotal(hh_rental cash deposits salary side_salary recreational_salary), missing
gen lnperfinan = log(perfinan)
replace lnperfinan = 0 if perfinan == 0

* since all the counties were supposed to be covered by NRPS by 2013
* for 2013 onward, NRPS_rollout should be 1
replace nrps_rollout = 1 if iyear !=  2011 & iyear !=  2012

* randomly select one individual from each household
set seed 12345
gen random = uniform()
bysort householdID (random) : gen byte select = _n == 1
bysort householdID ID (select) : replace select = select[_N]

* label

save charls_all, replace

* sample
keep if rural_hukou == 1 & select == 1 & nrps_rollout == 1

save charls_sample, replace
