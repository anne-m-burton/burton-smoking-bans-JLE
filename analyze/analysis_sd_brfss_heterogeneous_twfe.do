* S+D: two-way FE regressions using BRFSS data
* drinking outcomes
* unit of obs at annual level

set more off
capture log close

log using "$analyze_log/analysis_sd_brfss_heterogeneous_twfe.txt", text replace

use "$analysis_data/brfss_individual_merged.dta", clear


*** census division-by-season heterogeneity analysis (aka do people in places that are super cold in the winter months respond differently?) ***

* drinking outcomes
eststo clear

* table 6, panel a, column 1: total alcohol consumption
eststo m1: reghdfe drink_tot bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_tot if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_tot if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))


* table 6, panel b, column 1: extensive-margin alcohol consumption
eststo m2: reghdfe drink_ext bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_ext if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_ext if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))


* table 6, panel c, column 1: intensive-margin alcohol consumption
eststo m3: reghdfe drink_int bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_int if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_int if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 3 outcomes
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*** weather drinking-by-smoking outcomes ***
eststo clear

* table 6, panel a, column 2: total alcohol consumption for current smokers
eststo m1: reghdfe drink_tot bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_tot if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_tot if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel a, column 3: total alcohol consumption for never smokers
eststo m2: reghdfe drink_tot bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_tot if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_tot if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel a, column 4: total alcohol consumption for former smokers
eststo m3: reghdfe drink_tot bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_tot if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_tot if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel b, column 2: extensive-margin alcohol consumption for current smokers
eststo m4: reghdfe drink_ext bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_ext if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_ext if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel b, column 3: extensive-margin alcohol consumption for never smokers
eststo m5: reghdfe drink_ext bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_ext if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_ext if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel b, column 4: extensive-margin alcohol consumption for former smokers
eststo m6: reghdfe drink_ext bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_ext if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_ext if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel c, column 2: intensive-margin alcohol consumption for current smokers
eststo m7: reghdfe drink_int bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_int if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_int if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel c, column 3: intensive-margin alcohol consumption for never smokers
eststo m8: reghdfe drink_int bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_int if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_int if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* table 6, panel c, column 4: intensive-margin alcohol consumption for former smokers
eststo m9: reghdfe drink_int bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ drink_int if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ drink_int if (bar_none == 0 & cold == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

*make a table where I include all 9 drinking-by-smoking outcomes
local include_models "m1 m2 m3 m4 m5 m6 m7 m8 m9"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_by_smoke_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_by_smoke_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** unconditional drinking regressions by age group: table 8 ***
eststo clear

* total alcohol consumption (past 30 days)
local outcome "drink_tot"

* 18-20
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 18 & age <= 20 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 18 & age <= 20) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 21-34
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 21 & age <= 34 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 21 & age <= 34) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 35-54
eststo m3: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 35 & age <= 54 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 35 & age <= 54) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 55+
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 55 & age != . [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 55 & age != .) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_age.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_age.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days)
eststo clear

local outcome "drink_ext"

* 18-20
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 18 & age <= 20 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 18 & age <= 20) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 21-34
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 21 & age <= 34 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 21 & age <= 34) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 35-54
eststo m3: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 35 & age <= 54 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 35 & age <= 54) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 55+
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 55 & age != . [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 55 & age != .) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_age.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_age.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin
eststo clear

local outcome "drink_int"

* 18-20
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 18 & age <= 20 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 18 & age <= 20) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 21-34
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 21 & age <= 34 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 21 & age <= 34) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 35-54
eststo m3: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 35 & age <= 54 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 35 & age <= 54) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* 55+
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if age >= 55 & age != . [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & age >= 55 & age != .) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_age.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_age.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** drinking-by-smoking outcomes by gender: table 9 ***

*** drinking regressions for current smokers ***
eststo clear

* total alcohol consumption (past 30 days)
local outcome "drink_tot"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_current_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_current_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days)
eststo clear

local outcome "drink_ext"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_current_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_current_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin
eststo clear

local outcome "drink_int"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_current_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_current_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** drinking regressions for never smokers ***
eststo clear

* total alcohol consumption (past 30 days)
local outcome "drink_tot"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_never_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_never_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days)
eststo clear

local outcome "drink_ext"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_never_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_never_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin
eststo clear

local outcome "drink_int"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_never_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_never_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)




*** drinking regressions for former smokers ***
eststo clear

* total alcohol consumption (past 30 days)
local outcome "drink_tot"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_former_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_former_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days)
eststo clear

local outcome "drink_ext"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_former_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_former_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin
eststo clear

local outcome "drink_int"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 & smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 2 models
local include_models "m1 m2"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_former_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_former_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)




*** drinking by gender: table OA4 ***
eststo clear

* total alcohol consumption (past 30 days)
local outcome "drink_tot"

* male
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* extensive-margin alcohol consumption (past 30 days)
local outcome "drink_ext"

* male
eststo m3: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* intensive-margin
local outcome "drink_int"

* male
eststo m5: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 1 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* female
eststo m6: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if sex == 2 [pweight = annewt], absorb(_ageg5yr marital race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & sex == 2) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 6 models
local include_models "m1 m2 m3 m4 m5 m6"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_sex.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_sex.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** poisson for alcohol bc so many 0s: table OA5 ***
eststo clear

* total alcohol consumption: unconditional wrt smoking status
ppmlhdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state) d
margins, dydx(subject_county_bar_ban) post
eststo m1

summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total alcohol consumption: current smokers
ppmlhdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state) d
margins, dydx(subject_county_bar_ban) post
eststo m2

summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total alcohol consumption: never smokers
ppmlhdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state) d
margins, dydx(subject_county_bar_ban) post
eststo m3

summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total alcohol consumption: former smokers
ppmlhdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state) d
margins, dydx(subject_county_bar_ban) post
eststo m4

summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 outcomes
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_poisson.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_poisson.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** weather smoking outcomes: table OA8 ***
eststo clear

* current-smoking status
eststo m1: reghdfe smoke_current_pct bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ smoke_current_pct if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean_c = r(mean), replace
qui estadd scalar smoke_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ smoke_current_pct if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,2]/r(mean))

* never-smoking status
eststo m2: reghdfe smoke_never_pct bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ smoke_never_pct if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean_c = r(mean), replace
qui estadd scalar smoke_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ smoke_never_pct if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,2]/r(mean))

* former-smoking status
eststo m3: reghdfe smoke_former_pct bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ smoke_former_pct if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean_c = r(mean), replace
qui estadd scalar smoke_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ smoke_former_pct if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,2]/r(mean))

*make a table where I include all 3 smoking outcomes
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean_c Pre-Ban Mean: Cold" "smoke_percent_c % Effect: Cold" "smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean_c Pre-Ban Mean: Cold" "smoke_percent_c % Effect: Cold" "smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** drop the handful of counties that had a bar ban before a restaurant ban: column 4 of tables 2, OA6, and OA9 ***
preserve

drop if flag_bar_first == 1

* drinking outcomes
eststo clear

* total alcohol consumption
eststo m1: reghdfe drink_tot subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_tot if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ drink_tot if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

* extensive-margin alcohol consumption
eststo m2: reghdfe drink_ext subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_ext if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ drink_ext if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

* intensive-margin alcohol consumption
eststo m3: reghdfe drink_int subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_int if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ drink_int if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

* # days alcohol consumption
eststo m4: reghdfe drink_day subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_day if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* avg amt drank per day
eststo m5: reghdfe drink_amt subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_amt if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* maximum amt of alcohol consumption on 1 occasion
eststo m6: reghdfe drink_max subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ drink_max if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 6 outcomes
local include_models "m1 m2 m3 m4 m5 m6"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_nobarfirst.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_nobarfirst.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* smoking outcomes
eststo clear

* current-smoking status
eststo m1: reghdfe smoke_current_pct subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ smoke_current_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,1]/r(mean))

* never-smoking status
eststo m2: reghdfe smoke_never_pct subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ smoke_never_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,1]/r(mean))

* former-smoking status
eststo m3: reghdfe smoke_former_pct subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ smoke_former_pct if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 3 smoking outcomes
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_nobarfirst.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_nobarfirst.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


restore



*** state-level analysis ***
eststo clear

* total alcohol consumption (past 30 days): table OA11, panel a (effect of bar/rest smoking bans on alcohol consumption--brfss)
local outcome "drink_tot"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, current smokers
eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, never smokers
eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, former smokers
eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification
eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, current smokers
eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, never smokers
eststo m7: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, former smokers
eststo m8: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 8 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_state.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_state.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days): table OA11, panel b (effect of bar/rest smoking bans on alcohol consumption--brfss)
eststo clear

local outcome "drink_ext"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, current smokers
eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, never smokers
eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, former smokers
eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification
eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, current smokers
eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, never smokers
eststo m7: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, former smokers
eststo m8: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 8 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_state.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_state.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin: table OA11, panel c (effect of bar/rest smoking bans on alcohol consumption--brfss)
eststo clear

local outcome "drink_int"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, current smokers
eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, never smokers
eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*twfe + restaurant-only ban as controls--no other controls, former smokers
eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification
eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, current smokers
eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, never smokers
eststo m7: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*(1) + demographic + policy controls: preferred specification, former smokers
eststo m8: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 8 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_state.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_state.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



log close
