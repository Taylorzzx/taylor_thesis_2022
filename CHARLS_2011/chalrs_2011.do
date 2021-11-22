* Taylor Zhang
* data wrangling for all CHARLS 2011 dataset

* set the working directory to be the thesis file in CHARLS 2011
cd "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2011"

/* upstream and downstrem support
   for all these values there are negatives (e.g. -9999)
*/
use "CHARLS2011_Dataset/family_transfer.dta", clear

* [only 2011] total = regular + nonregular monetary support
* so need to get the values for non-regular
forval i = 1/10{
	rename ce009_`i'_1 reg_upsupport_`i'
	rename ce029_`i'_1 reg_downsupport_`i'
	rename ce009_`i'_2 reg_inkind_upsupport_`i'
	rename ce029_`i'_2 reg_inkind_downsupport_`i'
	rename ce009_`i'_3 nonreg_upsupport_`i'
	rename ce029_`i'_3 nonreg_downsupport_`i'
	rename ce009_`i'_4 nonreg_inkind_upsupport_`i'
	rename ce029_`i'_4 nonreg_inkind_downsupport_`i'
	
	replace reg_upsupport_`i' = .  if reg_upsupport_`i' < 0 & reg_upsupport_`i' != .
	replace reg_downsupport_`i' = .  if reg_downsupport_`i' < 0 & reg_downsupport_`i' != .
	replace reg_inkind_upsupport_`i' = .  if reg_inkind_upsupport_`i' < 0 & reg_inkind_upsupport_`i' != .
	replace reg_inkind_downsupport_`i' = .  if reg_inkind_downsupport_`i' < 0 & reg_inkind_downsupport_`i' != .
	replace nonreg_upsupport_`i' = .  if nonreg_upsupport_`i' < 0 & nonreg_upsupport_`i' != .
	replace nonreg_downsupport_`i' = .  if nonreg_downsupport_`i' < 0 & nonreg_downsupport_`i' != .
	replace nonreg_inkind_upsupport_`i' = .  if nonreg_inkind_upsupport_`i' < 0 & nonreg_inkind_upsupport_`i' != .
	replace nonreg_inkind_downsupport_`i' = .  if nonreg_inkind_downsupport_`i' < 0 & nonreg_inkind_downsupport_`i' != .
}

order _all, sequential

egen upsupport = rowtotal(reg_upsupport_1 - reg_upsupport_10 nonreg_upsupport_1 - nonreg_upsupport_10), missing
egen downsupport = rowtotal(reg_downsupport_1 - reg_downsupport_10 nonreg_downsupport_1 - nonreg_downsupport_10), missing
egen upsupport_inkind = rowtotal(reg_inkind_upsupport_1 - reg_inkind_upsupport_10 nonreg_inkind_upsupport_1 - nonreg_inkind_upsupport_10), missing
egen downsupport_inkind = rowtotal(reg_inkind_downsupport_1 - reg_inkind_downsupport_10 nonreg_inkind_downsupport_1 - nonreg_inkind_downsupport_10), missing

* Brackets 

forval i = 1/10{
	rename ce009_`i'_1_a reg_upsupport_min_`i'
	rename ce029_`i'_1_a reg_downsupport_min_`i'
	rename ce009_`i'_1_b reg_upsupport_max_`i'
	rename ce029_`i'_1_b reg_downsupport_max_`i'
	rename ce009_`i'_3_a nonreg_upsupport_min_`i'
	rename ce029_`i'_3_a nonreg_downsupport_min_`i'
	rename ce009_`i'_3_b nonreg_upsupport_max_`i'
	rename ce029_`i'_3_b nonreg_downsupport_max_`i'
	
	rename ce009_`i'_2_a inkind_reg_upsupport_min_`i'
	rename ce029_`i'_2_a inkind_reg_downsupport_min_`i'
	rename ce009_`i'_2_b inkind_reg_upsupport_max_`i'
	rename ce029_`i'_2_b inkind_reg_downsupport_max_`i'
	rename ce009_`i'_4_a inkind_nonreg_upsupport_min_`i'
	rename ce029_`i'_4_a inkind_nonreg_downsupport_min_`i'
	rename ce009_`i'_4_b inkind_nonreg_upsupport_max_`i'
	rename ce029_`i'_4_b inkind_nonreg_downsupport_max_`i'
}

order _all, sequential
egen upsupport_min = rowtotal(reg_upsupport_min_1 - reg_upsupport_min_10 nonreg_upsupport_min_1-nonreg_upsupport_min_10), missing
egen upsupport_max = rowtotal(reg_upsupport_max_1 - reg_upsupport_max_10 nonreg_upsupport_max_1-nonreg_upsupport_max_10), missing
egen upsupport_bracket_avg = rowmean(upsupport_min upsupport_max)

egen downsupport_min = rowtotal(reg_downsupport_min_1-reg_downsupport_min_10 nonreg_downsupport_min_1-nonreg_downsupport_min_10), missing
egen downsupport_max = rowtotal(reg_downsupport_max_1-reg_downsupport_max_10 nonreg_downsupport_max_1-nonreg_downsupport_max_10), missing
egen downsupport_bracket_avg = rowmean(downsupport_min downsupport_max)

egen inkind_upsupport_min = rowtotal(inkind_reg_upsupport_min_1 - inkind_reg_upsupport_min_10 inkind_nonreg_upsupport_min_1-inkind_nonreg_upsupport_min_10), missing
egen inkind_upsupport_max = rowtotal(inkind_reg_upsupport_max_1 - inkind_reg_upsupport_max_10 inkind_nonreg_upsupport_max_1-inkind_nonreg_upsupport_max_10), missing
egen inkind_upsupport_bracket_avg = rowmean(inkind_upsupport_min inkind_upsupport_max)

egen inkind_downsupport_min = rowtotal(inkind_reg_downsupport_min_1-inkind_reg_downsupport_min_10 inkind_nonreg_downsupport_min_1-inkind_nonreg_downsupport_min_10), missing
egen inkind_downsupport_max = rowtotal(inkind_reg_downsupport_max_1-inkind_reg_downsupport_max_10 inkind_nonreg_downsupport_max_1-inkind_nonreg_downsupport_max_10), missing
egen inkind_downsupport_bracket_avg = rowmean(inkind_downsupport_min inkind_downsupport_max)

replace upsupport = upsupport_bracket_avg if upsupport == . & upsupport_bracket_avg != .
replace downsupport = downsupport_bracket_avg if upsupport == . & downsupport_bracket_avg != .
replace upsupport_inkind = inkind_upsupport_bracket_avg if upsupport_inkind == . & inkind_upsupport_bracket_avg != .
replace downsupport_inkind = inkind_downsupport_bracket_avg if upsupport_inkind == . & inkind_downsupport_bracket_avg != .

* only in 2011
*gen updum_eco = (ce007==1)
*replace updum_eco = . if ce007 == .
*gen downdum_eco = (ce027==1)
*replace downdum_eco = . if ce027 == .

* Time spent providing care to grandchildren
gen care_dum = (cf001 == 1)
replace care_dum = . if cf001 == .

keep ID householdID communityID upsupport downsupport upsupport_inkind downsupport_inkind ///
 care_dum

save family_transfer_2011, replace

* emotional support, income of children, and working child
use "CHARLS2011_Dataset/family_information.dta", clear

order _all, sequential
egen income_child = rowtotal(cb069_1_-cb069_25_), missing

* use the non-missing values of income (cb069_1_-cb069_15_) to calculate nchild
foreach v of varlist cb069_1_-cb069_25_ {
    generate dum`v' = 1 if `v' !=.
} 

egen nchild = rowtotal(dumcb069_1_-dumcb069_25_), missing

* Num of biological/adopted children currently living but not living with the respondent
egen nchild_bio_adopted = rowtotal(cb001 cb009 cb017 cb025 cb033 cb041), missing

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
  
foreach v of varlist cd003_1_-cd003_14_ {
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
  
egen freq_visit_365 = rowtotal(cd003_1_ - cd003_14_), missing
egen freq_contact_365 = rowtotal(cd004_1_ - cd004_14_), missing

* calculate the min of cb070 (whether there is at least one answer that is YES)  
* in CHALRS YES = 1; No = 2
* use contains_1 to find out whether the respondent has at least one working children.
egen contains_1 = rowmin(cb070_1_ - cb070_25_)
gen workingchild = (contains_1 == 1)
replace workingchild = . if (contains_1 == .)

*no distance variable in 2018
egen distance = rowtotal(cb053_1_1_ - cb053_1_14_ cb053_4_1_ - cb053_4_14_ cb053_8_1_-cb053_8_14_), missing
gen live_outside = (distance > 0)
replace live_outside = . if distance == .

keep ID householdID communityID income_child nchild freq_contact_365 freq_visit_365 workingchild ///
nchild_bio_adopted live_outside

save family_info_2011, replace

* pension
use "CHARLS2011_Dataset/work_retirement_and_pension.dta", clear

* NRPS
gen nrps_received = (fn077 == 1)
replace nrps_received = . if fn077 == .
gen nrps_participated = (fn071 == 1)
replace nrps_participated = . if fn071 == .

* fn079 is amount of NRPS benefits per month
gen nrps_amount = fn079*12
gen salary = ff002
gen side_salary = fj003*12,
gen recreational_salary = fm059*12

keep ID householdID communityID nrps_received nrps_participated nrps_amount salary ///
side_salary recreational_salary 

save pension_2011, replace

* household rental income and expenditure
* there is no ID in this dataset
use "CHARLS2011_Dataset/household_income.dta", clear
egen hh_rental = rowtotal(ha060_1_ - ha060_4_), missing
order _all, sequential
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
gen rural_hukou = bc001,
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
gen med_insur = (ea001s10 != 10)

keep ID householdID communityID med_insur
save med_2011, replace

* [!ONLY 2011!]
* community survey: whether teh community covered by NRPS 
use "CHARLS2011_Dataset/community.dta", clear
gen nrps_rollout = (jg033 == 1)
replace nrps_rollout = . if jg033 == .

* there are two communities haev sub communities but the answers to nrps_rollout are the same
* so I only keep one from these two community community
keep if sub_commuID == "01" | sub_commuID == ""

keep communityID nrps_rollout
save community_2011, replace

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

* hh_income_2011 and community_2011 don't have ID, so I use householdID & communityID
merge m:1 householdID using "hh_income_2011.dta", nogenerate
merge m:1 communityID using "community_2011.dta", nogenerate

merge 1:1 ID using "indiv_income_2011.dta", nogenerate
merge 1:1 ID using "med_2011.dta", nogenerate
merge 1:1 ID using "pension_2011.dta", nogenerate
merge m:1 communityID using "region_nbs_2011.dta", nogenerate

* [!ONLY 2011!]
* match up with the ID in other three waves
replace householdID = householdID + "0"
replace ID = householdID + substr(ID,-2,2)

* Age_ID
merge 1:1 ID using "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2015/age_ID_2015.dta", nogenerate
drop if communityID == ""

* nchild_bio_2018
merge 1:1 ID using "/Users/Taylor/Desktop/22 Thesis/taylor_thesis_2022/CHARLS_2018/nchild_2018.dta"
drop if _merge == 2
replace nchild_bio_adopted_2018 = nchild_bio_adopted if nchild_bio_adopted_2018 == . & nchild_bio_adopted != .
replace nchild_bio_adopted_2018 = nchild_bio_adopted if nchild_bio_adopted_2018 != . & nchild_bio_adopted != . & nchild_bio_adopted_2018 < nchild_bio_adopted
drop _merge

* CHARLS year
gen year = 2011

save charls_2011, replace
