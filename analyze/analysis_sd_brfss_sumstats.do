* S+D: BRFSS data summary statistics
* drinking and smoking outcomes
* unit of obs at individual level (monthly treatment)

set more off
capture log close

log using "$analyze_log/analysis_sd_brfss_sumstats.txt", text replace


*** BRFSS Summary statistics table ***
use "$analysis_data/brfss_individual_merged.dta", clear

*make an always-treated bar ban variable (bar ban implemented before or during 2004q1)
*update first effective date for bar ban by making untreated have 0 and making places with bans implemented after my sample period also have 0s
tab bar_ban_first_eff_min, missing
gen bar_ban_first_m = bar_ban_first_eff_min
replace bar_ban_first_m = 0 if bar_ban_first_eff_min == .
replace bar_ban_first_m = 0 if bar_ban_first_m > ym(2012,12)
format bar_ban_first_m %tm
tab bar_ban_first_m, missing
*when you format a date as %tm and have untreated as 0's not missing, it treats the 0 as 1960m1 fyi

gen always_bar_ban = 0
replace always_bar_ban = 1 if bar_ban_first_m <= ym(2004,1) & bar_ban_first_m != 0
bysort always_bar_ban: tab bar_ban_first_m, missing

gen any_bar_ban = 0
replace any_bar_ban = 1 if subject_county_bar_ban > 0

gen ever_bar_ban = 0
replace ever_bar_ban = 1 if bar_ban_first_eff_min <= ym(2012, 12)

* label bar ban variables
label variable any_bar_ban "Binary bar ban"
label variable ever_bar_ban "Ever bar ban"


* make pre-smoking-ban, smoking ban, and never-smoking-ban averages for drinking outcomes
local drinks "tot ext int day amt max"
foreach drink of local drinks {
    gen drink_`drink'_ever_ban_pre = drink_`drink' if (any_bar_ban == 0 & ever_bar_ban == 1)
	gen drink_`drink'_ever_ban = drink_`drink' if (ever_bar_ban == 1)
	gen drink_`drink'_never_ban = drink_`drink' if (ever_bar_ban == 0)
}

* label variables
label var drink_tot_ever_ban_pre "Alcohol consumption, total (per capita): before smoking ban"
label var drink_tot_ever_ban "Alcohol consumption, total (per capita): ever smoking ban"
label var drink_tot_never_ban "Alcohol consumption, total (per capita): never smoking ban"

label var drink_ext_ever_ban_pre "Alcohol consumption, extensive margin: before smoking ban"
label var drink_ext_ever_ban "Alcohol consumption, extensive margin: ever smoking ban"
label var drink_ext_never_ban "Alcohol consumption, extensive margin: never smoking ban"

label var drink_int_ever_ban_pre "Alcohol consumption, intensive margin: before smoking ban"
label var drink_int_ever_ban "Alcohol consumption, intensive margin: ever smoking ban"
label var drink_int_never_ban "Alcohol consumption, intensive margin: never smoking ban"

label var drink_day_ever_ban_pre "Alcohol consumption, \# days: before smoking ban"
label var drink_day_ever_ban "Alcohol consumption, \# days: ever smoking ban"
label var drink_day_never_ban "Alcohol consumption, \# days: never smoking ban"

label var drink_amt_ever_ban_pre "Alcohol consumption, amount per day: before smoking ban"
label var drink_amt_ever_ban "Alcohol consumption, amount per day: ever smoking ban"
label var drink_amt_never_ban "Alcohol consumption, amount per day: never smoking ban"

label var drink_max_ever_ban_pre "Alcohol consumption, max.: before smoking ban"
label var drink_max_ever_ban "Alcohol consumption, max.: ever smoking ban"
label var drink_max_never_ban "Alcohol consumption, max.: never smoking ban"

local summ_control_vars "subject_county_bar_ban any_bar_ban ever_bar_ban subject_county_restaurant_ban_v1 female race_black race_asian race_hispanic race_white race_other age_1834 age_3554 age_55plus emp_emp marital_married edu_maxhs edu_leastcoll bac08 cig_tax_pack"

local summ_alc_vars "subject_county_bar_ban any_bar_ban ever_bar_ban subject_county_restaurant_ban_v1 drink_tot drink_ext drink_int drink_day drink_amt drink_max smoke_current smoke_never smoke_former"

*** table 1 summary statistics of alcohol and smoking outcomes by treatment status, brfss ***
eststo clear
eststo: estpost summarize `summ_alc_vars' [aw = annewt]
eststo: qui estpost summarize `summ_alc_vars' [aw = annewt] if  (ever_bar_ban == 0)
eststo: qui estpost summarize `summ_alc_vars' [aw = annewt] if  (any_bar_ban == 0 & ever_bar_ban == 1)
eststo: qui estpost summarize `summ_alc_vars' [aw = annewt] if  (ever_bar_ban == 1)

esttab using "$out/summ_stats_table_brfss_individual.rtf", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")
esttab using "$out/summ_stats_table_brfss_individual.tex", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")

*** appendix table OA1 summary statistics of control variables by treatment status, brfss ***
eststo clear
eststo: qui estpost summarize `summ_control_vars' [aw = annewt]
eststo: qui estpost summarize `summ_control_vars' [aw = annewt] if  (ever_bar_ban == 0)
eststo: qui estpost summarize `summ_control_vars' [aw = annewt] if  (any_bar_ban == 0 & ever_bar_ban == 1)
eststo: qui estpost summarize `summ_control_vars' [aw = annewt] if  (ever_bar_ban == 1)

esttab using "$out/summ_stats_table_brfss_individual_controls.rtf", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")
esttab using "$out/summ_stats_table_brfss_individual_controls.tex", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")

* get the stat for the footnote about what % of observations (that are for counties ever covered by a smoking ban) were covered by laws affecting > 1/2 pop right away vs. later vs. never
preserve

keep if ever_bar_ban == 1

*to get % where > 1/2 pop covered in same year as first law (half = 1)
gen half = 1 if bar_ban_first_eff_min == bar_ban_first_eff_avg
replace half = 0 if bar_ban_first_eff_min != bar_ban_first_eff_avg
tab half

*to get % where 1/2 pop covered in later year (but eventually) as first law
gen half_later = 1 if bar_ban_first_eff_avg > bar_ban_first_eff_min & bar_ban_first_eff_avg != .
replace half_later = 0 if half_later != 1
replace half_later = 0 if bar_ban_first_eff_avg > ym(2012, 12) & bar_ban_first_eff_avg != .
tab half_later

*to get % where 1/2 pop never covered (missing + 2015)
tab bar_ban_first_eff_avg, missing

restore


*** figure 1: map of smoking bans ***

use "$build_data/smoking_bans.dta", clear

gen bar_ban_timing = .
replace bar_ban_timing = 1 if bar_ban_first_eff_min < ym(2004, 01)
replace bar_ban_timing = 2 if bar_ban_first_eff_min >= ym(2004, 01) & bar_ban_first_eff_min <= ym(2007, 12)
replace bar_ban_timing = 3 if bar_ban_first_eff_min >= ym(2008, 01) & bar_ban_first_eff_min <= ym(2012, 12)
	
gen county = fips_state_code*1000 + fips_county_code
keep if time_moyr == ym(2004, 01)

* only keep necessary variables 
keep county fips_county_code fips_state_code bar_ban_timing

maptile bar_ban_timing, geo(county2014) cutvalues(1(1)3) twopt(legend(order(1 2 3 4) lab(1 "no ban as of 2012") label(2 "pre-2004") lab(3 "2004-2007") lab(4 "2008-2012"))) fcolor(gs12 gs6 black) ndfcolor(white) stateoutline(vthin)

graph export "$out/bar_map.png", replace
graph export "$out/bar_map.eps", replace
graph export "$out/bar_map.pdf", replace

log close
