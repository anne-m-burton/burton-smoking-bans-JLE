* S+D: two-way FE regressions using BRFSS data
* drinking outcomes
* unit of obs at annual level

set more off
capture log close

log using "$analyze_log/analysis_sd_nielsen_household_robust.txt", text replace

use "$analysis_data/nielsen_household_merged.dta", clear


*** census division-by-season heterogeneity analysis (aka do people in places that are super cold in the winter months respond differently?): table 7 ***

* drinking outcomes
eststo clear

* total alcohol purchases
eststo m1: reghdfe alc_servings bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* extensive-margin alcohol purchases
eststo m2: reghdfe alc_any bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_any if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_any if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* intensive-margin alcohol purchases
eststo m3: reghdfe alc_servings_1 bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings_1 if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings_1 if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

*make a table where I include all 3 outcomes
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* drinking-by-smoking outcomes
eststo clear

* total alcohol purchases for smokers
eststo m1: reghdfe alc_servings bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))


* total alcohol purchases for nonsmokers
eststo m2: reghdfe alc_servings bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))


* extensive-margin alcohol purchases for smokers
eststo m3: reghdfe alc_any bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_any if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_any if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* extensive-margin alcohol purchases for nonsmokers
eststo m4: reghdfe alc_any bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_any if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_any if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* intensive-margin alcohol purchases for smokers
eststo m5: reghdfe alc_servings_1 bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings_1 if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings_1 if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

* intensive-margin alcohol purchases for nonsmokers
eststo m6: reghdfe alc_servings_1 bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ alc_servings_1 if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_c = r(mean), replace
qui estadd scalar drink_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ alc_servings_1 if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,2]/r(mean))

*make a table where I include all 6 drinking-by-smoking outcomes
local include_models "m1 m2 m3 m4 m5 m6"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_by_smoke_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_by_smoke_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_c Pre-Ban Mean: Cold" "drink_percent_c % Effect: Cold" "drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** poisson for alcohol bc so many 0s: table OA5, panel b ***
eststo clear

* total alcohol consumption: unconditional wrt smoking status
* controlling for FEs for (max) head age bins, marital status of HH, HH race/ethnicity, (max) head education, (max) head employment, # adults in HH, whether children in HH, female (unmarried) head, male (unmarried) head
ppmlhdfe alc_servings subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(head_age marital_status race_v1 head_education head_employment household_num_adults children female_head male_head county_state time_moyr region_moyr) vce(cluster county_state) d

margins, dydx(subject_county_bar_ban) post
eststo m1

summ alc_servings if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total alcohol consumption: smoking hh
ppmlhdfe alc_servings subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(head_age marital_status race_v1 head_education head_employment household_num_adults children female_head male_head county_state time_moyr region_moyr) vce(cluster county_state) d

margins, dydx(subject_county_bar_ban) post
eststo m2

summ alc_servings if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total alcohol consumption: nonsmoking hh
ppmlhdfe alc_servings subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(head_age marital_status race_v1 head_education head_employment household_num_adults children female_head male_head county_state time_moyr region_moyr) vce(cluster county_state) d

margins, dydx(subject_county_bar_ban) post
eststo m3

summ alc_servings if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 3 outcomes
local include_models "m1 m2 m3"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_poisson.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_poisson.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** weather smoking outcomes: table OA8 ***
eststo clear

* extensive-margin cigarette purchases
eststo m1: reghdfe cig_any bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ cig_any if (bar_cold == 0 & cold == 1 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar smoke_mean_c = r(mean), replace
qui estadd scalar smoke_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ cig_any if (bar_none == 0 & cold == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,2]/r(mean))

* intensive-margin cigarette purchases
eststo m2: reghdfe cig_packs bar_cold bar_none restaurant_v1_cold restaurant_v1_none cold bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

test bar_cold = bar_none

qui summ cig_packs if (bar_cold == 0 & cold == 1 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar smoke_mean_c = r(mean), replace
qui estadd scalar smoke_percent_c = 100*(e(b)[1,1]/r(mean))

qui summ cig_packs if (bar_none == 0 & cold == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar smoke_mean = r(mean), replace
qui estadd scalar smoke_percent = 100*(e(b)[1,2]/r(mean))

*make a table where I include all 2 smoking outcomes
local include_models "m1 m2"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_smoke_cold.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean_c Pre-Ban Mean: Cold" "smoke_percent_c % Effect: Cold" "smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_smoke_cold.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("smoke_mean_c Pre-Ban Mean: Cold" "smoke_percent_c % Effect: Cold" "smoke_mean Pre-Ban Mean" "smoke_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(bar_cold bar_none) coeflabels(bar_cold "Cold" bar_none "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** disaggregated purchases by type of alcohol (beer, wine, liquor): table OA10 ***

eststo clear

* amount of beer purchased (past month)
local outcome "alc_servings_beer"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_beer.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_beer.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


eststo clear

* amount of wine purchased (past month)
local outcome "alc_servings_wine"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_wine.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_wine.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


eststo clear

* amount of liquor purchased (past month)
local outcome "alc_servings_liquor"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_liquor.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_liquor.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** drop the handful of counties that had a bar ban before a restaurant ban: column 4 of tables 3, OA7, and OA10 ***
preserve

drop if flag_bar_first == 1

* drinking outcomes
eststo clear

* total alcohol consumption
eststo m1: reghdfe alc_servings subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_servings if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* extensive-margin alcohol consumption
eststo m2: reghdfe alc_any subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_any if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* intensive-margin alcohol consumption
eststo m3: reghdfe alc_servings_1 subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_servings_1 if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* extensive-margin cigarette purchases
eststo m4: reghdfe cig_any subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ cig_any if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* intensive-margin cigarette purchases
eststo m5: reghdfe cig_packs subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ cig_packs if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total beer consumption
eststo m6: reghdfe alc_servings_beer subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_servings_beer if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total wine consumption
eststo m7: reghdfe alc_servings_wine subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_servings_wine if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

* total liquor consumption
eststo m8: reghdfe alc_servings_liquor subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ alc_servings_liquor if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 8 outcomes
local include_models "m1 m2 m3 m4 m5 m6 m7 m8"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" marital "Demographics" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_nobarfirst.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_nobarfirst.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


restore


*** state-level analysis ***
eststo clear

* amount of alcohol purchased (past month): table OA12, panel a
local outcome "alc_servings"

eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 6 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6"


* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_state.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_state.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* any alcohol purchased (past month): table OA12, panel b
eststo clear

local outcome "alc_any"

eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 6 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6"


* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_state.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_state.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin alcohol purchases (past month): table OA12, panel c
eststo clear

local outcome "alc_servings_1"

eststo m1: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m5: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m6: reghdfe `outcome' subject_state_bar_ban subject_state_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code fips_state_code time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_state_bar_ban == 0 & ever_state_bar_ban == 1 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 6 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4 m5 m6"

* Output regression table
estfe `include_models', labels(fips_state_code "State FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_state.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_state.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_state_bar_ban*) coeflabels(subject_state_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


log close
