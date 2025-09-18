* S+D: two-way FE regressions using BRFSS data
* drinking outcomes
* unit of obs at individual-month level

set more off
capture log close

log using "$analyze_log/analysis_sd_brfss_individual_twfe.txt", text replace

use "$analysis_data/brfss_individual_merged.dta", clear

*** unconditional drinking regressions ***
eststo clear

* total alcohol consumption (past 30 days): table 2, panel a (effect of bar/rest smoking bans on alcohol consumption--brfss)
local outcome "drink_tot"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel a, column 1
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)



* extensive-margin alcohol consumption (past 30 days): table 2, panel b (effect of bar/rest smoking bans on alcohol consumption--brfss)
eststo clear

local outcome "drink_ext"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel b, column 1
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin: table 2, panel c (effect of bar/rest smoking bans on alcohol consumption--brfss)
eststo clear

local outcome "drink_int"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = annewt]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel c, column 1
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)


* # days drinking: appendix table OA9, panel a (effect of bar/rest smoking bans on disaggregated measures of alcohol consumption--conditional on drinking in past 30 days, brfss)
eststo clear

local outcome "drink_day"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_days.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_days.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* amount per day: appendix table OA9, panel b (effect of bar/rest smoking bans on disaggregated measures of alcohol consumption--conditional on drinking in past 30 days, brfss)
eststo clear

local outcome "drink_amt"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_avg.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_avg.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



* max amount: appendix table OA9, panel c (effect of bar/rest smoking bans on disaggregated measures of alcohol consumption--conditional on drinking in past 30 days, brfss)
eststo clear

local outcome "drink_max"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_max.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_max.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)




*** drinking regressions for current smokers ***
eststo clear

* total alcohol consumption (past 30 days): table 4, panel a, column 1 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
local outcome "drink_tot"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_current.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_current.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days): table 4, panel b, column 1 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

local outcome "drink_ext"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_current.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_current.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin: table 4, panel c, column 1 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

*twfe + restaurant-only ban as controls--no other controls 
local outcome "drink_int"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_current == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_current == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_current.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_current.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** drinking regressions for never smokers ***
eststo clear

* total alcohol consumption (past 30 days): table 4, panel a, column 2 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
local outcome "drink_tot"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_never.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_never.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days): table 4, panel b, column 2 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

local outcome "drink_ext"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_never.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_never.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin: table 4, panel c, column 2 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

local outcome "drink_int"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_never == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_never == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_never.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_never.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** drinking regressions for former smokers ***
eststo clear

* total alcohol consumption (past 30 days): table 4, panel a, column 3 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
local outcome "drink_tot"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_former.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_total_former.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* extensive-margin alcohol consumption (past 30 days): table 4, panel b, column 3 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

local outcome "drink_ext"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_former.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_ext_former.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin: table 4, panel c, column 3 (effect of bar/rest smoking bans on alcohol consumption by smoking status--brfss)
eststo clear

local outcome "drink_int"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoke_former == 1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoke_former == 1) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_former.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_drink_int_former.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



*** smoking regressions ***
eststo clear

* current smoker: appendix table OA6, panel a (effect of bar/rest smoking bans on smoking status--brfss)
local outcome "smoke_current_pct"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_current.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_current.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* never smoker: appendix table OA6, panel b (effect of bar/rest smoking bans on smoking status--brfss)
eststo clear

local outcome "smoke_never_pct"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_never.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_never.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* former smoker: appendix table OA6, panel c (effect of bar/rest smoking bans on smoking status--brfss)
eststo clear

local outcome "smoke_former_pct"

*twfe + restaurant-only ban as controls--no other controls 
eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = annewt], absorb(county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(1) + demographic + policy controls: preferred specification
eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but with binary bar/restaurant ban variables, instead of fraction of county pop subject to ban
eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

*(2) but standard errors clustered at state level not county level
eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = annewt]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_former.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/brfss_individual_smoke_former.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)



log close
