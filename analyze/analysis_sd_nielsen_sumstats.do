* S+D: Nielsen data summary statistics
* drinking and smoking outcomes
* unit of obs at annual level

set more off
capture log close

log using "$analyze_log/analysis_sd_nielsen_sumstats.txt", text replace

use "$analysis_data/nielsen_household_merged.dta", clear


*make ever smoking ban and always smoking ban variables
gen bar_ban = subject_county_bar_ban
replace bar_ban = 1 if bar_ban > 0
bysort county_state: egen ever_bar_ban = max(bar_ban)
tab ever_bar_ban, missing

*check it's coded correctly (should have 0 obs in bar_ban = 1, ever_bar_ban = 0)
tab bar_ban ever_bar_ban, missing

*label variables
label variable subject_county_bar_ban "Fraction bar ban"
label variable bar_ban "Binary bar ban"
label variable ever_bar_ban "Ever bar ban"
label variable subject_county_restaurant_ban_v1 "Fraction restaurant-only ban"

label variable alc_servings "Alcohol purchases: total servings"
label variable alc_any "Alcohol purchases: extensive margin (p.p.)"
label variable alc_servings_1 "Alcohol purchases: intensive margin"
label variable smoker "Fraction smoking households"
label variable cig_any "Cigarette purchases: extensive margin (p.p.)"
label variable cig_packs_1 "Cigarette purchases: intensive margin" 

local summ_nielsen_vars "subject_county_bar_ban bar_ban ever_bar_ban subject_county_restaurant_ban_v1 alc_servings alc_any alc_servings_1 smoker cig_any cig_packs_1"

* Table OA2: summary statistics of outcome variables by treatment status, Nielsen data
eststo clear
eststo: qui estpost summarize `summ_nielsen_vars' [aw = projection_factor]
eststo: qui estpost summarize `summ_nielsen_vars' [aw = projection_factor] if ever_bar_ban == 0
eststo: qui estpost summarize `summ_nielsen_vars' [aw = projection_factor] if bar_ban == 0 & ever_bar_ban == 1
eststo: qui estpost summarize `summ_nielsen_vars' [aw = projection_factor] if ever_bar_ban == 1

esttab using "$out/summ_stats_table_nielsen.rtf", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")
esttab using "$out/summ_stats_table_nielsen.tex", replace compress nogaps main(mean 2) aux(sd 2) label nostar nodepvar unstack nonotes mtitles("Full Sample" "Never Smoking Ban" "Before Smoking Ban" "Ever Smoking Ban")


log close
