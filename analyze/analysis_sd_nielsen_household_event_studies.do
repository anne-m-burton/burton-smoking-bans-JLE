* S+D: two-way FE event-study regressions using Nielsen data
* drinking outcomes
* unit of obs at household level (annual treatment)

set more off
capture log close

log using "$analyze_log/analysis_sd_nielsen_household_event_studies.txt", text replace


use "$analysis_data/nielsen_event_study_data.dta", clear

eststo clear

* figure OA5, top panel: extensive-margin cigarette purchases
local outcome cig_any

eststo m4: reghdfe `outcome' bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = projection_factor], absorb(household_code county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m4"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans" "on Extensive-Margin Cigarette Purchases") name(es_smoke_n_current)
graph export "$out/event_study_hh_cig_any.png", replace
graph export "$out/event_study_hh_cig_any.pdf", replace

* figure OA5, bottom panel: intensive-margin smoking, smokers
local outcome cig_packs

eststo m5: reghdfe `outcome' bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack if smoker == 1 [pweight = projection_factor], absorb(household_code county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m5"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans" "on Intensive-Margin Cigarette Purchases") name(es_smoke_n_int)
graph export "$out/event_study_hh_cig_packs.png", replace
graph export "$out/event_study_hh_cig_packs.pdf", replace


log close
		