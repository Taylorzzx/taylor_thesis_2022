* Taylor Zhang
* data wrangling for all CHARLS 2013 dataset

* set the working directory to be the thesis file in CHARLS 2013
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2013"

/* upstream and downstrem support
   for all these values there are negatives (e.g. -9999)
*/
use "CHARLS2013_Dataset/family_transfer.dta", clear

foreach v of varlist ce009_1_1_ - ce009_1_11_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_1_1_ - ce029_1_11_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce009_3_1_ - ce009_3_11_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_3_1_ - ce029_3_11_ {
	replace `v' = . if `v' < 0 & `v' != .
}

egen upsupport = rowtotal(ce009_1_1_ - ce009_1_11_), missing
egen downsupport = rowtotal(ce029_1_1_ - ce029_1_11_), missing
egen upsupport_inkind = rowtotal(ce009_3_1_ - ce009_3_11_), missing
egen downsupport_inkind = rowtotal(ce029_3_1_ - ce029_3_11_), missing
keep ID householdID communityID upsupport downsupport upsupport_inkind downsupport_inkind

save family_transfer_2013, replace

* emotional support, income of children, and working child
use "CHARLS2013_Dataset/family_information.dta", clear

egen income_child = rowmean(cb069_1_-cb069_11_)

* use the non-missing values of income (cb069_1_-cb069_15_) to calculate nchild
foreach v of varlist cb069_1_-cb069_11_ {
    generate dum`v' = 1 if `v' !=.
} 
foreach v of varlist dumcb069_1_-dumcb069_11_ {
    replace `v' = 0 if `v'==.
}
gen nchild_dum = 0
foreach v of varlist dumcb069_1_-dumcb069_11_ {
	replace nchild_dum = nchild_dum + `v' 
}

gen nchild = nchild_dum

egen emosupport = rowmean(cd004_1_ - cd004_11_)

* rewrite the emotional support in terms of days
foreach v of varlist cd004_1_-cd004_11_ {
    replace `v' = 365 if `v' ==1 & `v' !=.
	replace `v' = 120 if `v' ==2 & `v' !=.
	replace `v' = 48 if `v' ==3 & `v' !=.
	replace `v' = 24 if `v' ==4 & `v' !=.
	replace `v' = 12 if `v' ==5 & `v' !=.
	replace `v' = 4 if `v' ==6 & `v' !=.
	replace `v' = 2 if `v' ==7 & `v' !=.
	replace `v' = 1 if `v' ==8 & `v' !=.
	replace `v' = 0 if `v' ==9 & `v' !=.
	replace `v' = . if `v' ==10
  } 
  
egen emosupport_365 = rowmean(cd004_1_ - cd004_11_)

* calculate the min of cb070 (whether there is at least one answer that is YES)  
* in CHALRS YES = 1; No = 2
* use contains_1 to find out whether the respondent has at least one working children.
egen contains_1 = rowmin(cb070_1_ - cb070_11_)
gen workingchild = (contains_1 == 1)
replace workingchild = . if (contains_1 == .)

keep ID householdID communityID income_child nchild emosupport emosupport_365 workingchild

save family_info_2013, replace

* pension
use "CHARLS2013_Dataset/work_retirement_and_pension.dta", clear

* NRPS
gen NRPS_received = (fn075_w2 == 1)
replace NRPS_received = . if fn075_w2 == .
gen NRPS_participated = (fn001_w2s9 == 9)

* fn079 is amount of NRPS benefits per month
gen NRPS_amount = fn077_w2*12
gen salary = ff002_1
gen side_salary = fj003*12,
gen recreational_salary = fm059*12

keep ID householdID communityID NRPS_received NRPS_participated NRPS_amount salary ///
side_salary recreational_salary

save pension_2013, replace

* household rental income and expenditure
* there is no ID in this dataset
use "CHARLS2013_Dataset/household_income.dta", clear
egen hh_rental = rowtotal(ha060_1_ - ha060_4_), missing

* household expenditure
foreach v of varlist ge010_1-ge010_13 {
    replace `v' = 0 if `v' == -9999 | `v' == -999 | `v' == -99990
  } 
  
gen hh_expend = 0
foreach v of varlist ge010_1-ge010_13 {
    replace hh_expend = hh_expend + `v'
  } 
keep householdID communityID hh_expend hh_rental

save hh_income_2013, replace

* individual income
use "CHARLS2013_Dataset/individual_income.dta", clear

gen cash = hc001
gen deposits = hc005
keep ID householdID communityID cash deposits

save indiv_income_2013, replace

* demographic background
use "CHARLS2013_Dataset/demographic_background.dta", clear
gen married = be001
gen educ = zbd001
gen age_year = ba002_1
gen age_month = ba002_2
gen rural_hukou = zbc001,
gen female = (ba000_w2_3 == 2)
replace female = . if ba000_w2_3 == .

keep ID householdID communityID married educ age_year age_month rural_hukou female
save demo_info_2013, replace

* health
use "CHARLS2013_Dataset/health_status_and_functioning.dta", clear
gen self_reported_health = da002
gen self_satisf = dc028

keep ID householdID communityID self_reported_health self_satisf
save health_2013, replace

* medical insurance
use "CHARLS2013_Dataset/health_care_and_insurance.dta", clear
gen med_insur = (ea009 != .)

keep ID householdID communityID med_insur
save med_2013, replace

* interview year and month
use "CHARLS2013_Dataset/weights.dta", clear

* drop some non-unique ID (ID with no values)
drop if ID == ""

keep ID householdID communityID iyear imonth
save interview_date_2013, replace

* merge all ten dataset
* use the weight data (with the largest amount of obs)
merge 1:1 ID using "demo_info_2013.dta", nogenerate
merge 1:1 ID using "family_info_2013.dta", nogenerate
merge 1:1 ID using "family_transfer_2013.dta", nogenerate
merge 1:1 ID using "health_2013.dta", nogenerate

* hh_income_2013 doesn't have ID, so I use householdID
merge m:1 householdID using "hh_income_2013.dta", nogenerate

merge 1:1 ID using "indiv_income_2013.dta", nogenerate
merge 1:1 ID using "med_2013.dta", nogenerate
merge 1:1 ID using "pension_2013.dta", nogenerate

save charls_2013, replace
