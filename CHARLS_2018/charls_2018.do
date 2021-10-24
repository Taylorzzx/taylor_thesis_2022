* Taylor Zhang
* data wrangling for all CHARLS 2018 dataset

* set the working directory to be the thesis file in CHARLS 2018
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2018"

/* upstream and downstrem support
   for all these values there are negatives (e.g. -9999)
*/
use "CHARLS2018_Dataset/family_transfer.dta", clear

foreach v of varlist ce009_1_1_ - ce009_1_15_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_1_1_ - ce029_1_15_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce009_3_1_ - ce009_3_15_ {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_3_1_ - ce029_3_15_ {
	replace `v' = . if `v' < 0 & `v' != .
}

egen upsupport = rowtotal(ce009_1_1_ - ce009_1_15_), missing
egen downsupport = rowtotal(ce029_1_1_ - ce029_1_15_), missing
egen upsupport_inkind = rowtotal(ce009_3_1_ - ce009_3_15_), missing
egen downsupport_inkind = rowtotal(ce029_3_1_ - ce029_3_15_), missing

egen emosupport = rowmean(cd004_1_ - cd004_9_)

* rewrite the emotional support in terms of days
foreach v of varlist cd004_1_-cd004_9_ {
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
  
egen emosupport_365 = rowmean(cd004_1_ - cd004_9_)

keep ID householdID communityID upsupport downsupport upsupport_inkind downsupport_inkind ///
emosupport emosupport_365

save family_transfer_2018, replace

* emotional support, income of children, and working child
use "CHARLS2018_Dataset/family_information.dta", clear

* use the non-missing values of income (cb069_1_-cb069_15_) to calculate nchild
foreach v of varlist cb069_1_-cb069_15_ {
    generate dum`v' = 1 if `v' !=.
} 
foreach v of varlist dumcb069_1_-dumcb069_15_ {
    replace `v' = 0 if `v'==.
}
gen nchild_dum = 0
foreach v of varlist dumcb069_1_-dumcb069_15_ {
	replace nchild_dum = nchild_dum + `v' 
}

gen nchild = nchild_dum

* in this question, 997 means "don't know'"
foreach v of varlist cb069_1_ - cb069_15_ {
	replace `v' = . if `v' == 997
}
egen income_child = rowmean(cb069_1_-cb069_15_)

* calculate the min of cb070 (whether there is at least one answer that is YES)  
* in CHALRS YES = 1; No = 2
* use contains_1 to find out whether the respondent has at least one working children.
egen contains_1 = rowmin(cb070_w4_1_ - cb070_w4_15_)
gen workingchild = (contains_1 == 1)
replace workingchild = . if (contains_1 == .)

keep ID householdID communityID income_child nchild workingchild

save family_info_2018, replace

* pension
use "CHARLS2018_Dataset/pension.dta", clear

* NRPS
gen NRPS_received = (fn058_w4_a == 2 & fn058_w4_b == 1)
replace NRPS_received = . if fn058_w4_a != 2
gen NRPS_participated = (fn058_w4_a == 2)
replace NRPS_participated = . if fn058_w4_a == .

* fn079 is amount of NRPS benefits per month
gen NRPS_amount = fn066_w2_1*12 if NRPS_received == 1
replace NRPS_amount = fn066_w2_min if NRPS_amount == -1
keep ID householdID communityID NRPS_received NRPS_participated NRPS_amount 
save pension_2018, replace

* salary
use "CHARLS2018_Dataset/Work_Retirement.dta", clear
gen salary = ff002_w4_a
gen side_salary = fj003_w4*12,
gen recreational_salary = fm059*12

keep ID householdID communityID salary side_salary recreational_salary
save salary_2018, replace

* household rental income and expenditure
* there is no ID in this dataset
use "CHARLS2018_Dataset/household_income.dta", clear
egen hh_rental = rowtotal(ha060_1_ - ha060_4_), missing

* household expenditure
foreach v of varlist ge010_1-ge010_15 {
    replace `v' = 0 if `v' == -9999 | `v' == -999 | `v' == -99990
  } 
  
gen hh_expend = 0
foreach v of varlist ge010_1-ge010_15 {
    replace hh_expend = hh_expend + `v'
  } 
keep householdID communityID hh_expend hh_rental

save hh_income_2018, replace

* individual income
use "CHARLS2018_Dataset/individual_income.dta", clear

gen cash = hc001
gen deposits = hc005
keep ID householdID communityID cash deposits

save indiv_income_2018, replace

* demographic background
use "CHARLS2018_Dataset/demographic_background.dta", clear
gen married = be001
gen educ = bd001_w2_4
gen age_year = ba004_w3_1
gen age_month = ba004_w3_2

gen rural_hukou = zbc004
replace rural_hukou = bc002_w3_1 if bc002_w3 == .

gen female = (ba000_w2_3 == 2)
replace female = . if ba000_w2_3 == .

keep ID householdID communityID married educ age_year age_month rural_hukou female
save demo_info_2018, replace

* health
use "CHARLS2018_Dataset/health_status_and_functioning.dta", clear
gen self_reported_health = da002
keep ID householdID communityID self_reported_health
save health_2018, replace

* life satisf
use "CHARLS2018_Dataset/Cognition.dta", clear
gen self_satisf = dc028

keep ID householdID communityID self_satisf
save life_satisf_2018, replace

* medical insurance
use "CHARLS2018_Dataset/health_care_and_insurance.dta", clear
gen med_insur = (ea001_w4_s12 == 0)

keep ID householdID communityID med_insur
save med_2018, replace

* interview year and month
use "CHARLS2018_Dataset/Sample_Infor.dta", clear

keep ID householdID communityID iyear imonth
save interview_date_2018, replace

* merge all eleven dataset
* use the weight data (with the largest amount of obs)
merge 1:1 ID using "demo_info_2018.dta", nogenerate
merge 1:1 ID using "family_info_2018.dta", nogenerate
merge 1:1 ID using "family_transfer_2018.dta", nogenerate
merge 1:1 ID using "health_2018.dta", nogenerate

* hh_income_2015 doesn't have ID, so I use householdID
merge m:1 householdID using "hh_income_2018.dta", nogenerate

merge 1:1 ID using "indiv_income_2018.dta", nogenerate
merge 1:1 ID using "med_2018.dta", nogenerate
merge 1:1 ID using "life_satisf_2018.dta", nogenerate
merge 1:1 ID using "pension_2018.dta", nogenerate
merge 1:1 ID using "salary_2018.dta", nogenerate

save charls_2018, replace
