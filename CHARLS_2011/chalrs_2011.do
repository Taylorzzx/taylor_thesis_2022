* Taylor Zhang
* data wrangling for all CHARLS 2011 dataset

* set the working directory to be the thesis file in CHARLS 2011
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2011"

/* upstream and downstrem support
   for all these values there are negatives (e.g. -9999)
*/
use "CHARLS2011_Dataset/family_transfer.dta", clear

foreach v of varlist ce009_1_1 - ce009_10_1 {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_1_1 - ce029_10_1 {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce009_1_2 - ce009_10_2 {
	replace `v' = . if `v' < 0 & `v' != .
}
foreach v of varlist ce029_1_2 - ce029_10_2 {
	replace `v' = . if `v' < 0 & `v' != .
}

egen upsupport = rowtotal(ce009_1_1 - ce009_10_1), missing
egen downsupport = rowtotal(ce029_1_1 - ce029_10_1), missing
egen upsupport_inkind = rowtotal(ce009_1_2 - ce009_10_2), missing
egen downsupport_inkind = rowtotal(ce029_1_2 - ce029_10_2), missing
keep ID householdID communityID upsupport downsupport upsupport_inkind downsupport_inkind

save family_transfer_2011, replace

* emotional support, income of children, and working child
use "CHARLS2011_Dataset/family_information.dta", clear

egen income_child = rowmean(cb069_1_-cb069_25_)

* use the non-missing values of income (cb069_1_-cb069_15_) to calculate nchild
foreach v of varlist cb069_1_-cb069_25_ {
    generate dum`v' = 1 if `v' !=.
} 
foreach v of varlist dumcb069_1_-dumcb069_25_ {
    replace `v' = 0 if `v'==.
}
gen nchild_dum = 0
foreach v of varlist dumcb069_1_-dumcb069_25_ {
	replace nchild_dum = nchild_dum + `v' 
}

gen nchild = nchild_dum

egen emosupport = rowmean(cd004_1_ - cd004_14_)

* rewrite the emotional support in terms of days
foreach v of varlist cd004_1_-cd004_14_ {
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
  
egen emosupport_365 = rowmean(cd004_1_ - cd004_14_)

* calculate the min of cb070 (whether there is at least one answer that is YES)  
* in CHALRS YES = 1; No = 2
* use contains_1 to find out whether the respondent has at least one working children.
egen contains_1 = rowmin(cb070_1_ - cb070_25_)
gen workingchild = (contains_1 == 1)
replace workingchild = . if (contains_1 == .)

keep ID householdID communityID income_child nchild emosupport emosupport_365 workingchild

save family_info_2011, replace

* pension
use "CHARLS2011_Dataset/work_retirement_and_pension.dta", clear

* NRPS
gen NRPS_received = (fn077 == 1)
replace NRPS_received = . if fn077 == .
gen NRPS_participated = (fn071 == 1)
replace NRPS_participated = . if fn071 == .

* fn079 is amount of NRPS benefits per month
gen NRPS_amount = fn079*12
gen salary = ff002
gen side_salary_2011 = fj003*12,
gen recreational_salary_2011 = fm059*12

keep ID householdID communityID NRPS_received NRPS_participated NRPS_amount salary ///
side_salary_2011 recreational_salary_2011

save pension_2011, replace

* household rental income and expenditure
* there is no ID in this dataset
use "CHARLS2011_Dataset/household_income.dta", clear
egen hh_rental = rowtotal(ha060_1_ - ha060_4_), missing

* household expenditure
foreach v of varlist ge010_1-ge010_14 {
    replace `v' = 0 if `v' == -9999 | `v' == -999 | `v' == -99990
  } 
  
gen hh_expend = 0
foreach v of varlist ge010_1-ge010_14 {
    replace hh_expend = hh_expend + `v'
  } 
keep householdID communityID hh_expend hh_rental

save hh_income_2011, replace

* individual income
use "CHARLS2011_Dataset/individual_income.dta", clear

gen cash = hc001
gen deposits = hc005
keep ID householdID communityID cash deposits

save indiv_income_2011, replace

* demographic background
use "CHARLS2011_Dataset/demographic_background.dta", clear
gen married = be001
gen educ = bd001
gen age_year = ba002_1
gen age_month = ba002_2
gen rural_hukou = bc001 == 1,
gen female = (rgender == 2)
replace female = . if rgender == .

keep ID householdID communityID married educ age_year age_month rural_hukou female
save demo_info_2011, replace

* health
use "CHARLS2011_Dataset/health_status_and_functioning.dta", clear
gen self_reported_health = da002
gen self_satisf = dc028

keep ID householdID communityID self_reported_health self_satisf
save health_2011, replace

* medical insurance
use "CHARLS2011_Dataset/health_care_and_insurance.dta", clear
gen med_insur_2011 = (ea001s10 != 10)

keep ID householdID communityID med_insur_2011
save med_2011, replace

/* [!ONLY 2011!]
* proper display of chinese characters in psu.dta
unicode encoding set "GB18030"
unicode translate "psu.dta", invalid(mark) transutf8
*/

* rural defined by the NBS
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2011"
use "CHARLS2011_Dataset/psu.dta", clear

* inlist: the number of arguments is between 2 and 10 for strings
gen east_region = (inlist(province, "北京", "天津","河北省","辽宁省","上海市","江苏省","浙江省","福建省","山东省"))
replace east_region = 1 if inlist(province, "广东省","广西省","海南省") == 1

gen middle_region = (inlist(province, "山西省", "内蒙古自治区", "吉林省", "黑龙江省", "安徽省", "江西省", "河南省", "湖北省", "湖南省"))

* the remaining are supposed to be west_region
* 西部地区包括重庆、四川、贵州、云南、西藏、陕西、甘肃、宁夏、青海、新疆10个省、自治区
gen west_region = (middle_region == 0 & east_region == 0)
gen rural_nbs = (urban_nbs == 0) 

keep communityID east_region middle_region west_region rural_nbs
save region_nbs_2011, replace

* interview year and month
use "CHARLS2011_Dataset/weight.dta", clear
keep ID householdID communityID iyear imonth
save interview_date_2011, replace

* merge all ten dataset
* use the weight data (with the largest amount of obs)
merge 1:1 ID using "demo_info_2011.dta", nogenerate
merge 1:1 ID using "family_info_2011.dta", nogenerate
merge 1:1 ID using "family_transfer_2011.dta", nogenerate
merge 1:1 ID using "health_2011.dta", nogenerate

* hh_income_2011 doesn't have ID, so I use householdID
merge m:1 householdID using "hh_income_2011.dta", nogenerate

merge 1:1 ID using "indiv_income_2011.dta", nogenerate
merge 1:1 ID using "med_2011.dta", nogenerate
merge 1:1 ID using "pension_2011.dta", nogenerate
merge m:1 communityID using "region_nbs_2011.dta", nogenerate

* [!ONLY 2011!]
replace householdID = householdID + "0"
replace ID = householdID + substr(ID,-2,2)

save charls_2011, replace



