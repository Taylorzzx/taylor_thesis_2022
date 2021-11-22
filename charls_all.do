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

* married 1 means marreid and live together
replace married = 0 if married != 1 & married != .

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

* combine non-monetary and monetary assistance
egen upsupport_sum = rowtotal(upsupport upsupport_inkind), missing
egen downsupport_sum = rowtotal(downsupport downsupport_inkind), missing
gen lnupsupport_sum = log(upsupport_sum)
replace lnupsupport_sum = 0 if upsupport_sum == 0
gen lndownsupport_sum = log(downsupport_sum)
replace lndownsupport_sum = 0 if downsupport_sum == 0

gen updum_sum = (upsupport_sum > 0)
replace updum_sum = . if upsupport_sum == .
gen downdum_sum = (downsupport_sum > 0)
replace downdum_sum = . if downsupport_sum == .

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
label variable married "Marital Status"
label variable educ "Education"
label variable rural_hukou "Rural Hukou"
label variable female "Gender"
label variable income_child "Children's Income"
label variable nchild "Numer of Children Earning Income"
label variable nchild_bio_adopted "Number of Biological and Adopted Children"
label variable freq_visit_365 "Frequency of Visits"
label variable freq_contact_365 "Frequency of Contact"
label variable workingchild "Have Children Working"
label variable live_outside "Non-cohabiting Children"
label variable lndownsupport_sum "Downstream Support"
label variable lndownsupport "Downstream Financial Support"
label variable lndownsupport_inkind "Downstream Inkind Support"
label variable lnupsupport_sum "Upstream Support"
label variable lnupsupport "Upstream Financial Support"
label variable lnupsupport_inkind "Upstream Inkind Support"
label variable care_dum "Take Care of Grandchildren"
label variable east_region "East"
label variable middle_region "Middle"
label variable west_region "West"
label variable monthly_age "Monthly Age"
label variable downdum "Received downsupport"
label variable downdum_inkind "Received downsupport_inkind"
label variable downdum_sum "Received downsupport_sum"
label variable downdum "Received upsupport"
label variable downdum_inkind "Received upsupport_inkind"
label variable downdum_sum "Received upsupport_sum"
label variable lnperfinan "Personal Financing"
label variable nrps_received "Received NRPS"
label variable nrps_participated "Enrolled in NRPS"
label variable nrps_rollout "Covered by NRPS"

order _all, alphabetic
save charls_all, replace
