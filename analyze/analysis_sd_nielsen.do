* This script executes the analysis using Nielsen data. It calls several other do files.
* created by Anne Burton
* 02/24/22
* modified by Anne Burton
* 10/25/23


clear all
set more off
capture log close

*** merge all datasets together ***

use "$nielsen_data/nielsen_cp_monthly_alc_cigs_2004_2012.dta", clear

* first merge in monthly smoking ban data (treatment)
merge m:1 fips_state_code fips_county_code time_moyr using "$build_data/smoking_bans.dta"

order fips_state_code fips_county_code time_moyr household_code
gsort fips_state_code fips_county_code time_moyr household_code

tab fips_state_code if _merge == 1, missing
tab fips_county_code if _merge == 1, missing
tab fips_state_code if _merge == 2, missing
tab fips_county_code if _merge == 2, missing
tab time_moyr if _merge == 2, missing

*any unmatched from master is missing a state and county code
*any unmatched from using is a county-month-year that doesn't have nielsen respondents
drop if _merge == 1 | _merge == 2
drop _merge

tab time_moyr

* merge in alcohol policies (bac laws)
* any unmatched from using is a state-month-year that doesn't have nielsen respondents (alaska and hawaii)
merge m:1 fips_state_code time_moyr using "$build_data/alc_policies.dta"
tab fips_state_code if _merge == 2
keep if _merge == 3
drop _merge

* merge in smoking policies (cigarette taxes)
* any unmatched from using is a state-year that doesn't have nielsen respondents (alaska and hawaii)
merge m:1 state_name year using "$build_data/cig_policies.dta"
tab state_name if _merge == 2
keep if _merge == 3
drop _merge

*make the group variable for the county fixed effects
gegen county_state = group(fips_county_code fips_state_code)
label variable county_state "unique identifier for county-state pair"


* make region and division variables
gen division=.
* new england
replace division = 1 if fips_state_code == 9 | fips_state_code == 23 | fips_state_code==25 | fips_state_code == 33 | fips_state_code==44 | fips_state_code==50
* middle atlantic
replace division = 2 if fips_state_code == 34 | fips_state_code==36 | fips_state_code==42
* east north central
replace division = 3 if fips_state_code == 17 | fips_state_code == 18 | fips_state_code==26 | fips_state_code==39 | fips_state_code==55
* west north central
replace division = 4 if fips_state_code == 19 | fips_state_code == 20 | fips_state_code == 27 | fips_state_code == 29 | fips_state_code == 31 | fips_state_code == 38 | fips_state_code == 46
* south atlantic
replace division = 5 if fips_state_code == 10 | fips_state_code == 11 | fips_state_code == 12 | fips_state_code == 13 | fips_state_code == 24 | fips_state_code == 37 | fips_state_code == 45 | fips_state_code == 51 | fips_state_code == 54
* east south central
replace division = 6 if fips_state_code == 1 | fips_state_code == 21 | fips_state_code == 28 | fips_state_code == 47
* west south central
replace division = 7 if fips_state_code == 5 | fips_state_code == 22 | fips_state_code == 40 | fips_state_code == 48
* mountain
replace division = 8 if fips_state_code == 4 | fips_state_code == 8 | fips_state_code == 16 | fips_state_code == 35 |fips_state_code == 30 | fips_state_code == 49 | fips_state_code == 32 | fips_state_code == 56
* pacific
replace division = 9 if fips_state_code == 2 | fips_state_code == 6 | fips_state_code == 15 | fips_state_code == 41 | fips_state_code == 53
 
 
gen region = .
replace region = 1 if division == 1 | division == 2
replace region = 2 if division == 3 | division == 4
replace region = 3 if division == 5 | division == 6 | division == 7
replace region = 4 if division == 8 | division == 9

egen division_year = group(division year)
egen region_year = group(region year)
egen region_moyr = group(region time_moyr)

* make division-by-season dummies for heterogeneity analysis on whether people in cold places have different responses to smoking bans relative to people in not cold places
* "cold places": q4 and q1 (october - march) in mountain, west north central, east north central, middle atlantic, and new england census divisions
* omitted group: q2 and q3 in "cold places", year round everywhere else

gen cold = 0
replace cold = 1 if (division <= 4 |division == 8) & (purchase_date_mo <= 3 | purchase_date_mo >= 10)

tab division if cold == 1
tab time_moyr if cold == 1

gen bar_cold = cold*subject_county_bar_ban
gen restaurant_v1_cold = cold*subject_county_restaurant_ban_v1

gen bar_none = (1-cold)*subject_county_bar_ban
gen restaurant_v1_none = (1-cold)*subject_county_restaurant_ban_v1

* save data
save "$analysis_data/nielsen_household_merged.dta", replace

*** make dataset for event studies ***
preserve

* make annual treatment variables
gen bar_ban_first_eff_year = yofd(dofm(bar_ban_first_eff_min))
gen rest_ban_year = subject_county_rest_ban_d
replace rest_ban_year = 0 if year == bar_ban_first_eff_year

* make event time variables

* get event time
gen bb_et_agb_year = year - bar_ban_first_eff_year
label variable bb_et_agb_year "number of years since bar ban effective"


* for units that are treated after the sample period, replace their time variables with "missing" b/c they are untreated for the sample period. *make sure untreated units are included but get no dummies (by giving them "-1")
replace bb_et_agb_year = -1 if bar_ban_first_eff_year > 2012 | bar_ban_first_eff_year == .

		
* now make dummies for each possible post-period year (dropping always-treated obs so only need to go out 7 periods)
	forvalues j = 0(1)7 {
		gen bb_post_et_agb_year_`j' = 1 if bb_et_agb_year == `j'
		replace bb_post_et_agb_year_`j' = 0 if bb_et_agb_year != `j'
		label variable bb_post_et_agb_year_`j' "= 1 if bar ban effective `j' years ago"
		}

		*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
		forvalues j = 2(1)8 {
			gen bb_pre_et_agb_year_`j' = 1 if bb_et_agb_year == -`j'
			replace bb_pre_et_agb_year_`j' = 0 if bb_et_agb_year != -`j'
			disp "anne check if values replaced here (below)--shouldn't be"
			replace bb_pre_et_agb_year_`j' = 0 if bb_et_agb_year == .
			label variable bb_pre_et_agb_year_`j' "=1 if bar ban effective in `j' years"
			}
	
* drop always-treated (or treated in first year)
drop if bar_ban_first_eff_year < 2005

gen bb_neg1 = 0

save "$analysis_data/nielsen_event_study_data.dta", replace

restore

********************************************************************************
***** Analyses start here


* Summary statistics
include "$analyze/analysis_sd_nielsen_sumstats.do"

* TWFE (main estimates) @ individual level
include "$analyze/analysis_sd_nielsen_household_twfe.do"

* TWFE robustness checks/heterogeneity analyses
include "$analyze/analysis_sd_nielsen_household_robust.do"

* event studies (main estimates) w/annual aggregation
include "$analyze/analysis_sd_nielsen_household_event_studies.do"

