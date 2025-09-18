* S+D: stacked difference-in-differences and BJS DiD imputation estimators using BRFSS data
* drinking outcomes
* unit of obs at annual level

clear all
set more off
capture log close

log using "$analyze_log/analysis_sd_brfss_individual_newdid.txt", text replace


*** deshpande and li stacked diff-in-diff code ***

use "$analysis_data/brfss_individual_merged.dta", clear

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

egen county_state_stack = group(county_state stack)
egen state_stack = group(fips_state_code stack)
egen year_stack = group(year stack)
bysort id: gen number = _n
tab number

gen rest_ban_year = subject_county_rest_ban_d
replace rest_ban_year = 0 if year == tyear

save "$analysis_data/brfss_individual_stacked.dta", replace 

*** stacked dd ***

*** simple dd--unconditional, total drinking ***
eststo clear

* total drinking: table 2, panel a, column 5
eststo m1: reghdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m1 == 1
estadd scalar unique_n = r(N), replace


* extensive-margin drinking: table 2, panel b, column 5
eststo m2: reghdfe drink_ext subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_ext if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m2 == 1
estadd scalar unique_n = r(N), replace

*intensive-margin drinking: table 2, panel c, column 5
eststo m3: reghdfe drink_int subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_int if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m3 == 1
estadd scalar unique_n = r(N), replace

* bar and restaurant bans
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_stacked.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_stacked.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** simple dd--smoking status ***
eststo clear

* current smoking: table OA6, panel a, column 5
eststo m1: reghdfe smoke_current_pct subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ smoke_current_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m1 == 1
estadd scalar unique_n = r(N), replace

* never smoking: table OA6, panel b, column 5
eststo m2: reghdfe smoke_never_pct subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ smoke_never_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m2 == 1
estadd scalar unique_n = r(N), replace

* former smoking: table OA6, panel c, column 5
eststo m3: reghdfe smoke_former_pct subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ smoke_former_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m3 == 1
estadd scalar unique_n = r(N), replace


local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_stacked.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_stacked.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** simple dd--unconditional, disaggregated measures of drinking ***
eststo clear

* # days drinking: table OA9, panel a, column 5
eststo m1: reghdfe drink_day subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_day if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m1 == 1
estadd scalar unique_n = r(N), replace

* avg. amt consumed per day (conditional on drinking that day): table OA9, panel b, column 5
eststo m2: reghdfe drink_amt subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_amt if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m2 == 1
estadd scalar unique_n = r(N), replace

* maximum amt drank per occasion: table OA9, panel c, column 5
eststo m3: reghdfe drink_max subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

qui summ drink_max if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))
count if number == 1 & _est_m3 == 1
estadd scalar unique_n = r(N), replace


local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_disagg_stacked.rtf", replace compress noconstant se(2) b(2) r2(2) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(2 2 2 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_disagg_stacked.tex", replace compress noconstant se(2) b(2) r2(2) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect" "unique_n Unique N") sfmt(2 2 2 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** now do the stacked dd event studies ***
eststo clear

gen bb_neg1 = 0

*full-margin drinking: figure OA1, top-left panel
eststo m1: reghdfe drink_tot pre_bar_ban* post_bar_ban* bb_neg1 rest_ban_year [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

test pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2

local model "m1"

coefplot (`model', keep(pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(post_bar_ban_0 post_bar_ban_1 post_bar_ban_2 post_bar_ban_3 post_bar_ban_4 post_bar_ban_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") order(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") xtitle("Number of Years Since Bar Smoking Ban Effective") ytitle("# Drinks/Month Relative to Year Prior to Implementation") title("Stacked Difference-in-Differences Event Study: Effect of" "Smoking Bans on Overall Alcohol Consumption") name(es_drink_t_stacked)
graph export "$out/event_study_ind_drink_tot_stacked.png", replace
graph export "$out/event_study_ind_drink_tot_stacked.pdf", replace


*extensive-margin drinking: figure OA1, top-right panel
eststo m2: reghdfe drink_ext pre_bar_ban* post_bar_ban* bb_neg1 rest_ban_year [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

test pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2

local model "m2"
coefplot (`model', keep(pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(post_bar_ban_0 post_bar_ban_1 post_bar_ban_2 post_bar_ban_3 post_bar_ban_4 post_bar_ban_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") order(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") xtitle("Number of Years Since Bar Smoking Ban Effective") ytitle("p.p. Relative to Year Prior to Implementation") title("Stacked Difference-in-Differences Event Study: Effect of" "Smoking Bans on Extensive-Margin Alcohol Consumption") name(es_drink_ext_stacked)
graph export "$out/event_study_ind_drink_ext_stacked.png", replace
graph export "$out/event_study_ind_drink_ext_stacked.pdf", replace

*intensive-margin drinking: figure OA1, bottom panel
eststo m3: reghdfe drink_int pre_bar_ban* post_bar_ban* bb_neg1 rest_ban_year [pweight = annewt], absorb(i.stack#bac08 i.stack##c.cig_tax_pack i.stack#_ageg5yr i.stack#marital i.stack#sex i.stack#race2 i.stack#_educag i.stack#emp_emp county_state_stack year_stack i.stack#region_year) vce(cluster county_state_stack)

test pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2

local model "m3"
coefplot (`model', keep(pre_bar_ban_4 pre_bar_ban_3 pre_bar_ban_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(post_bar_ban_0 post_bar_ban_1 post_bar_ban_2 post_bar_ban_3 post_bar_ban_4 post_bar_ban_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-6(2)6, angle(horizontal)) yscale(range(-6 6)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") order(pre_bar_ban_4 = "t-4" pre_bar_ban_3 = "t-3" pre_bar_ban_2 = "t-2" bb_neg1 = "t-1" post_bar_ban_0 = "t" post_bar_ban_1 = "t+1" post_bar_ban_2 = "t+2" post_bar_ban_3 = "t+3" post_bar_ban_4 = "t+4" post_bar_ban_5 = "t+5") xtitle("Number of Years Since Bar Smoking Ban Effective") ytitle("# Drinks/Month Relative to Year Prior to Implementation") title("Stacked Difference-in-Differences Event Study: Effect of" "Smoking Bans on Intensive-Margin Alcohol Consumption") name(es_drink_int_stacked)
graph export "$out/event_study_ind_drink_int_stacked.png", replace
graph export "$out/event_study_ind_drink_int_stacked.pdf", replace



*** bjs did imputation and event studies ***

use "$analysis_data/brfss_individual_merged.dta", clear

gen id = _n

gen bar_ban = bar_ban_first_eff_min
replace bar_ban = . if bar_ban_first_eff_min > ym(2012, 12)
format bar_ban %tm
tab bar_ban

gen bar_ban_state = b_state_entry_moyr
replace bar_ban_state = . if bar_ban_state > ym(2012, 12)
format bar_ban_state %tm
tab bar_ban

ren subject_county_rest_ban_d rest_ban
ren subject_state_restaurant_ban_v1 rest_ban_state


* regular diff-in-diff

* table 2, panel a, column 6
local outcome drink_tot

eststo m1: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table 2, panel b, column 6
local outcome drink_ext 

eststo m2: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table 2, panel c, column 6
local outcome drink_int

eststo m3: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table OA6, panel a, column 6
local outcome smoke_current_pct

eststo m4: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table OA6, panel b, column 6
local outcome smoke_never_pct

eststo m5: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table OA6, panel c, column 6
local outcome smoke_former_pct

eststo m6: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 6 models
local include_models "m1 m2 m3 m4 m5 m6"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital_status "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_bjs.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_bjs.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** disaggregated drinking outcomes ***
eststo clear

* table OA9, panel a, column 6
local outcome drink_day

eststo m1: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table OA9, panel b, column 6
local outcome drink_amt

eststo m2: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* table OA9, panel c, column 6
local outcome drink_max

eststo m3: did_imputation `outcome' id time_moyr bar_ban [aweight = annewt], controls(cig_tax_pack) fe(rest_ban bac08 _ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) cluster(county_state) autosample maxit(1000)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 3 models
local include_models "m1 m2 m3"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital_status "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_bjs_disagg.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_bjs_disagg.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(tau) coeflabels(tau "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** event studies ***
eststo clear

gen bar_ban_first_eff_year = yofd(dofm(bar_ban))
gen rest_ban_year = rest_ban
replace rest_ban_year = 0 if year == bar_ban_first_eff_year

* figure OA2, top-left panel
local outcome drink_tot

eststo m1: did_imputation `outcome' id year bar_ban_first_eff_year [aweight = annewt], controls(cig_tax_pack) fe(rest_ban_year bac08 _ageg5yr marital sex race2 _educag emp_emp county_state year region_year) cluster(county_state) autosample maxit(1000) pretrend(4) horizons(0/5)

estadd scalar F_test = e(pre_F), replace
estadd scalar p_val = e(pre_p), replace

event_plot m1, default_look graph_opt(xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Imputation Estimator Event Study: Effect of" "Smoking Bans on Overall Alcohol Consumption") ylabel(-4(2)4) yscale(range(-4 4))) reportcommand
graph export "$out/event_study_ind_bjs_drink_tot.png", replace
graph export "$out/event_study_ind_bjs_drink_tot.pdf", replace

* figure OA2, top-right panel
local outcome drink_ext

eststo m2: did_imputation `outcome' id year bar_ban_first_eff_year [aweight = annewt], controls(cig_tax_pack) fe(rest_ban_year bac08 _ageg5yr marital sex race2 _educag emp_emp county_state year region_year) cluster(county_state) autosample maxit(1000) pretrend(4) horizons(0/5)

estadd scalar F_test = e(pre_F), replace
estadd scalar p_val = e(pre_p), replace

event_plot m2, default_look graph_opt(xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Imputation Estimator Event Study: Effect of" "Smoking Bans on Extensive-Margin Alcohol Consumption") ylabel(-4(2)4) yscale(range(-4 4))) reportcommand
graph export "$out/event_study_ind_bjs_drink_ext.png", replace
graph export "$out/event_study_ind_bjs_drink_ext.pdf", replace

* figure OA2, bottom panel
local outcome drink_int

eststo m3: did_imputation `outcome' id year bar_ban_first_eff_year [aweight = annewt], controls(cig_tax_pack) fe(rest_ban_year bac08 _ageg5yr marital sex race2 _educag emp_emp county_state year region_year) cluster(county_state) autosample maxit(1000) pretrend(4) horizons(0/5)

estadd scalar F_test = e(pre_F), replace
estadd scalar p_val = e(pre_p), replace

event_plot m3, default_look graph_opt(xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Imputation Estimator Event Study: Effect of" "Smoking Bans on Intensive-Margin Alcohol Consumption") ylabel(-6(2)6) yscale(range(-6 6))) reportcommand
graph export "$out/event_study_ind_bjs_drink_int.png", replace
graph export "$out/event_study_ind_bjs_drink_int.pdf", replace


log close
