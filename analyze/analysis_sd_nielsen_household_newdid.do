* S+D: BJS did imputation estimator and stacked diff-in-diff using Nielsen data
* drinking outcomes
* unit of obs at household level (monthly treatment)

clear all
set more off
capture log close

log using "$analyze_log/analysis_sd_nielsen_household_newdid.txt", text replace

*** stacked dd ***
use "$analysis_data/nielsen_household_merged.dta", clear

* first need a treatment year variable
gen tyear = yofd(dofm(bar_ban_first_eff_min))
replace tyear = 0 if bar_ban_first_eff_min == .
replace tyear = 0 if tyear > 2012

* make an id variable to use later to count # unique observations in regression
gen id = _n


* make stack 1 with all obs from counties treated in 2005 and all obs from counties treated after 2010 (or never) 
preserve
keep if tyear == 2005 | tyear == 0 | tyear > 2010
keep if year >= 2004 & year <= 2010
gen stack = 2005
gen tbar = 0
replace tbar = 1 if tyear == 2005
gen event_time = year - 2005 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit the year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}

tempfile data2005
save `data2005', replace
restore

* make stack 2 with all obs from counties treated in 2006 and all obs from counties treated after 2011 (or never) 
preserve
keep if tyear == 2006 | tyear == 0 | tyear > 2011
keep if year >= 2004 & year <= 2011
gen stack = 2006
gen tbar = 0
replace tbar = 1 if tyear == 2006
gen event_time = year - 2006 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
	
tempfile data2006
save `data2006', replace
restore

* make stack 3 with all obs from counties treated in 2007 and all obs from counties treated after sample period (or never) 
preserve
keep if tyear == 2007 | tyear == 0
keep if year >= 2004 & year <= 2012
gen stack = 2007
gen tbar = 0
replace tbar = 1 if tyear == 2007
gen event_time = year - 2007 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2007
save `data2007', replace
restore

* make stack 4 with all obs from counties treated in 2008 and all obs from counties treated after sample period (or never)
preserve
keep if tyear == 2008 | tyear == 0
keep if year >= 2004 & year <= 2012
gen stack = 2008
gen tbar = 0
replace tbar = 1 if tyear == 2008
gen event_time = year - 2008 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2008
save `data2008', replace
restore
 
* make stack 5 with all obs from counties treated in 2009 and all obs from counties treated after sample period (or never)
preserve
keep if tyear == 2009 | tyear == 0
keep if year >= 2005 & year <= 2012
gen stack = 2009
gen tbar = 0
replace tbar = 1 if tyear == 2009
gen event_time = year - 2009 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2009
save `data2009', replace
restore

* make stack 6 with all obs from counties treated in 2010 and all obs from counties treated after sample period (or never)
preserve
keep if tyear == 2010 | tyear == 0
keep if year >= 2006 & year <= 2012
gen stack = 2010
gen tbar = 0
replace tbar = 1 if tyear == 2010
gen event_time = year - 2010 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2010
save `data2010', replace
restore

* make stack 7 with all obs from counties treated in 2011 and all obs from counties treated after sample period (or never)
preserve
keep if tyear == 2011 | tyear == 0
keep if year >= 2007 & year <= 2012
gen stack = 2011
gen tbar = 0
replace tbar = 1 if tyear == 2011
gen event_time = year - 2011 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2011
save `data2011', replace
restore

* make stack 8 with all obs from counties treated in 2012 and all obs from counties treated after sample period (or never)
preserve
keep if tyear == 2012 | tyear == 0
keep if year >= 2008 & year <= 2012
gen stack = 2012
gen tbar = 0
replace tbar = 1 if tyear == 2012
gen event_time = year - 2012 if tbar == 1
replace event_time = -1 if tbar == 0
label variable event_time "number of yrs since bar ban eff"
*now make dummies for each possible post-period year
forvalues j = 0(1)5 {
	gen post_bar_ban_`j' = 1 if event_time == `j'
	replace post_bar_ban_`j' = 0 if event_time != `j'
	label variable post_bar_ban_`j' "= 1 if bar ban effective `j' years ago"
		}
*now make dummies for each possible pre-period year (omit year prior, which is why j starts at 2 and not 1!)
forvalues j = 2(1)4 {
	gen pre_bar_ban_`j' = 1 if event_time == -`j'
	replace pre_bar_ban_`j' = 0 if event_time != -`j'
	disp "anne check if values replaced here (below)"
	replace pre_bar_ban_`j' = 0 if event_time == .
	label variable pre_bar_ban_`j' "=1 if bar ban effective in `j' years"
	}
tempfile data2012
save `data2012', replace
restore

* append the stack year datasets
clear
forvalues i=2005/2012{
	append using `data`i''
}

egen household_stack = group(household_code stack)
egen county_state_stack = group(county_state stack)
egen state_stack = group(fips_state_code stack)
egen year_stack = group(year stack)
bysort id: gen number = _n
tab number

gen rest_ban_year = subject_county_rest_ban_d
replace rest_ban_year = 0 if year == tyear

save "$analysis_data/nielsen_household_stacked.dta", replace 


*** stacked dd ***

*simple dd--unconditional
eststo clear

* table 3, panel a, column 5
local outcome alc_servings

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m1 == 1
estadd scalar unique_n = r(N), replace

* table 3, panel b, column 5
local outcome alc_any

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m2 == 1
estadd scalar unique_n = r(N), replace

* table 3, panel c, column 5
local outcome alc_servings_1

eststo m3: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m3 == 1
estadd scalar unique_n = r(N), replace

* table oa7, panel a, column 5
local outcome cig_any

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m4 == 1
estadd scalar unique_n = r(N), replace

* table oa7, panel b, column 5
local outcome cig_packs

eststo m5: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m5 == 1
estadd scalar unique_n = r(N), replace

* table oa10, panel a, column 5
local outcome alc_servings_beer

eststo m6: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m6 == 1
estadd scalar unique_n = r(N), replace

* table oa10, panel b, column 5
local outcome alc_servings_wine

eststo m7: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m7 == 1
estadd scalar unique_n = r(N), replace

* table oa10, panel c, column 5
local outcome alc_servings_liquor

eststo m8: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(i.stack#bac08 i.stack##c.cig_tax_pack household_stack county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m8 == 1
estadd scalar unique_n = r(N), replace


* make a table where I include all 8 models
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_stacked.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_stacked.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** bjs did imputation estimator ***
use "$analysis_data/nielsen_household_merged.dta", clear

gen bar_ban = bar_ban_first_eff_min
replace bar_ban = . if bar_ban_first_eff_min > ym(2012, 12)
format bar_ban %tm
tab bar_ban

ren subject_county_rest_ban_d rest_ban

gen bar_ban_first_eff_year = yofd(dofm(bar_ban))
gen rest_ban_year = rest_ban
replace rest_ban_year = 0 if year == bar_ban_first_eff_year

* regular diff-in-diff
eststo clear

* table 3, panel a, column 6
local outcome alc_servings

eststo m1: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table 3, panel b, column 6
local outcome alc_any

eststo m2: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table 3, panel c, column 6
local outcome alc_servings_1

eststo m3: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample tol(.0001) maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table oa7, panel a, column 6
local outcome cig_any

eststo m4: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table oa7, panel b, column 6
local outcome cig_packs

eststo m5: did_imputation `outcome' household_code time_moyr bar_ban if smoker == 1 [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample tol(.0001) maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
                   
* table oa10, panel a, column 6
local outcome alc_servings_beer

eststo m6: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample tol(.000001) maxit(2000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table oa10, panel b, column 6
local outcome alc_servings_wine

eststo m7: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample tol(.000001) maxit(2000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table oa10, panel c, column 6
local outcome alc_servings_liquor

eststo m8: did_imputation `outcome' household_code time_moyr bar_ban [aweight = projection_factor], controls(cig_tax_pack) fe(rest_ban bac08 household_code time_moyr region_moyr) cluster(county_state) autosample tol(.000001) maxit(2000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where we include all 8 models
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital_status "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_bjs.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_bjs.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


log close
