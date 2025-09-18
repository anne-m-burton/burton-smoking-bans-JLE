* S+D: two-way FE regressions using Nielsen data
* unconditional drinking outcomes
* unit of obs at county-year level

set more off
capture log close

log using "$analyze_log/analysis_sd_nielsen_household_twfe.txt", text replace

use "$analysis_data/nielsen_household_merged.dta", clear


eststo clear

* amount of alcohol purchased (past month): table 3, panel a
local outcome "alc_servings"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))

summ household_num_adults if _est_m1 == 1, detail 


eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel a, column 2
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)


* any alcohol purchased (past month): table 3, panel b
eststo clear

local outcome "alc_any"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel b, column 2
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)


* intensive-margin alcohol purchases (past month): table 3, panel c
eststo clear

local outcome "alc_servings_1"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

qui summ `outcome' if (subject_county_bar_ban == 0 & subject_county_restaurant_ban_v1 == 0 & never_treated_r == 0) [aweight = projection_factor]
qui estadd scalar drink_mean_r = r(mean), replace
qui estadd scalar drink_percent_r = 100*(e(b)[1,2]/r(mean))


*make a table where I include all 4 models: bar (+ restaurant) ban
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

*make a table where I include all 4 models: restaurant-only ban: table OA3, panel c, column 2
local include_models "m1 m2 m3 m4"

* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_r.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_r.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean_r Pre-Ban Mean" "drink_percent_r % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_rest*) coeflabels(subject_county_restaurant_ban_v1 "Restaurant-Only Ban") star(* 0.10 ** 0.05 *** 0.01)


*** now do regressions for smokers (alcohol by smoking status) ***

* amount of alcohol purchased (past month): table 5, panel a, column 1
local outcome "alc_servings"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_smoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_smoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* any alcohol purchased (past month): table 5, panel b, column 1
eststo clear

local outcome "alc_any"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_smoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_smoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)
                  


* intensive-margin alcohol purchases (past month): table 5, panel c, column 1
eststo clear

local outcome "alc_servings_1"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_smoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_smoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** now do regressions for nonsmokers (alcohol by smoking status) ***

* amount of alcohol purchased (past month): table 5, panel a, column 2
local outcome "alc_servings"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_nonsmoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_total_nonsmoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* any alcohol purchased (past month): table 5, panel b, column 2
eststo clear

local outcome "alc_any"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_nonsmoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_ext_nonsmoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)
                  

* intensive-margin alcohol purchases (past month): table 5, panel c, column 2
eststo clear

local outcome "alc_servings_1"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 0 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 0) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_nonsmoker.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_drink_int_nonsmoker.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


*** now do regressions for smoking ***

* smoking (any purchases past month): table OA7, panel a
eststo clear

local outcome "cig_any"

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
esttab `include_models' using "$out/nielsen_household_smoke.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_smoke.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


* smoking (number of packs purchased per month for smokers): table OA7, panel b
eststo clear

local outcome "cig_packs"

eststo m1: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m2: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m3: reghdfe `outcome' subject_county_bar_ban_d subject_county_rest_ban_d bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster county_state)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))

eststo m4: reghdfe `outcome' subject_county_bar_ban subject_county_restaurant_ban_v1 bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state time_moyr region_moyr) vce(cluster fips_state_code)

qui summ `outcome' if (subject_county_bar_ban == 0 & never_treated == 0 & smoker == 1) [aweight = projection_factor]
qui estadd scalar drink_mean = r(mean), replace
qui estadd scalar drink_percent = 100*(e(b)[1,1]/r(mean))


*make a table where I include all 4 models
local include_models "m1 m2 m3 m4"


* Output regression table
estfe `include_models', labels(county_state "County FE" time_moyr "Month-Year FE" household_code "Household FE" cig_tax_pack "Alcohol/Cigarette Policies")

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_smoke_int.rtf", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)

* Run estout/esttab
esttab `include_models' using "$out/nielsen_household_smoke_int.tex", replace compress noconstant se(2) b(2) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("drink_mean Pre-Ban Mean" "drink_percent % Effect") sfmt(4 4 4 2 2 2) nomtitles keep(subject_county_bar_ban*) coeflabels(subject_county_bar_ban "Bar and Restaurant Ban") star(* 0.10 ** 0.05 *** 0.01)


log close
