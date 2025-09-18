* S+D: two-way FE event-study regressions using BRFSS data
* drinking outcomes
* unit of obs at individual level (treatment assigned based on county and year)

clear all
set more off
capture log close

log using "$analyze_log/analysis_sd_brfss_event_studies.txt", text replace

*****************************************************************************************
*	individual-level event studies--annual. 4 years pre-period, 5 years post-period
*****************************************************************************************
use "$analysis_data/brfss_event_study_data.dta", clear

*using the "min" definition of treatment because avg and max have partially treated obs (the places where min = 1) in the pre-period. also, of places with a min law, 78% had the avg law implemented at the same time (14% with a min law never had an average law, so like small cities where no other cities/larger entities implemented)


*** unconditional drinking event studies (aka not by smoking status) ***
eststo clear

* figure 2, panel a: full-margin drinking
eststo m1: reghdfe drink_tot bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m1"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor(black) offset(-0.01)) ///
		(`model', keep(bb_neg1) omitted lcolor(black) mcolor(black)) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") subtitle("Total Alcohol Consumption (Number of Servings)", size(3.5) position(11)) name(es_drink_t)
* change marker color from lavender to black for journal formatting reqs "147 141 210"
* no title for journal formatting reqs title("Event Study: Effect of Bar Smoking Bans" "on Overall Alcohol Consumption") 
graph export "$out/event_study_ind_drink_tot.png", replace
graph export "$out/event_study_ind_drink_tot.eps", replace
graph export "$out/event_study_ind_drink_tot.pdf", replace


* figure 2, panel b: extensive-margin drinking
eststo m2: reghdfe drink_ext bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m2"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor(black) offset(-0.01)) /// 
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor(black)) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") subtitle("Extensive-Margin Alcohol Consumption (p.p.)", size(3.5) position(11)) name(es_drink_ext)
* change marker color from lavender to black for journal formatting reqs "147 141 210"
* no title for journal formatting reqs title("Event Study: Effect of Bar Smoking Bans on" "Extensive-Margin Alcohol Consumption") 
graph export "$out/event_study_ind_drink_ext.png", replace
graph export "$out/event_study_ind_drink_ext.eps", replace
graph export "$out/event_study_ind_drink_ext.pdf", replace


* figure 3: intensive-margin drinking
eststo m3: reghdfe drink_int bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m3"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor(black) offset(-0.01)) /// 
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor(black)) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ylabel(-6(2)6, angle(horizontal)) yscale(range(-6 6)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") subtitle("Intensive-Margin Alcohol Consumption (Number of Servings)", size(3.5) position(11)) name(es_drink_int)
* change marker color from lavender to black for journal formatting reqs "147 141 210"
* no title for journal formatting reqs title("Event Study: Effect of Bar Smoking Bans on" "Intensive-Margin Alcohol Consumption") 
graph export "$out/event_study_ind_drink_int.png", replace
graph export "$out/event_study_ind_drink_int.eps", replace
graph export "$out/event_study_ind_drink_int.pdf", replace


*** now do the drinking-by-smoking event studies ***

*** min ***

* figure oa3, top-left panel: full-margin drinking for current smokers
eststo m13: reghdfe drink_tot bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack if smoke_current == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m13"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-6(2)6, angle(horizontal)) yscale(range(-6 6)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans on Overall" "Alcohol Consumption, Current Smokers") name(es_drink_tot_sc)
graph export "$out/event_study_ind_drink_tot_sc.png", replace
graph export "$out/event_study_ind_drink_tot_sc.pdf", replace

* figure oa3, top-right panel: full-margin drinking for never smokers
eststo m14: reghdfe drink_tot bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack if smoke_never == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m14"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-6(2)6, angle(horizontal)) yscale(range(-6 6)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans on Overall" "Alcohol Consumption, Never Smokers") name(es_drink_tot_sn)
graph export "$out/event_study_ind_drink_tot_sn.png", replace
graph export "$out/event_study_ind_drink_tot_sn.pdf", replace

* figure oa3, bottom panel: full-margin drinking for former smokers
eststo m15: reghdfe drink_tot bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack if smoke_former == 1 [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m15"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-6(2)6, angle(horizontal)) yscale(range(-6 6)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans on Overall" "Alcohol Consumption, Former Smokers") name(es_drink_tot_sf)
graph export "$out/event_study_ind_drink_tot_sf.png", replace
graph export "$out/event_study_ind_drink_tot_sf.pdf", replace



*** now do the smoking event studies ***

*** "min" smoking ban (treatment when 1st place implements) ***

* figure oa4, top-left panel: extensive-margin smoking, current smokers
eststo m4: reghdfe smoke_current_pct bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m4"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans" "on Current-Smoking Status") name(es_smoke_current)
graph export "$out/event_study_ind_smoke_current.png", replace
graph export "$out/event_study_ind_smoke_current.pdf", replace


* figure oa4, top-right panel: extensive-margin smoking, never smokers
eststo m5: reghdfe smoke_never_pct bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m5"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans" "on Never-Smoking Status") name(es_smoke_never)
graph export "$out/event_study_ind_smoke_never.png", replace
graph export "$out/event_study_ind_smoke_never.pdf", replace


	
* figure oa4, bottom panel: extensive-margin smoking, former smokers
eststo m6: reghdfe smoke_former_pct bb_pre_et_agb_year_* bb_post_et_agb_year_* bb_neg1 rest_ban_year bac08 cig_tax_pack [pweight = annewt], absorb(_ageg5yr marital sex race2 _educag emp_emp county_state year region_year) vce(cluster county_state)

test bb_pre_et_agb_year_2 bb_pre_et_agb_year_3 bb_pre_et_agb_year_4

local model "m6"
coefplot (`model', keep(bb_pre_et_agb_year_4 bb_pre_et_agb_year_3 bb_pre_et_agb_year_2) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
		 (`model', keep(bb_neg1) omitted lcolor(black) mcolor("147 141 210")) ///
		 (`model', keep(bb_post_et_agb_year_0 bb_post_et_agb_year_1 bb_post_et_agb_year_2 bb_post_et_agb_year_3 bb_post_et_agb_year_4 bb_post_et_agb_year_5) lcolor(black) mcolor("147 141 210") offset(-0.01)) ///
	, vertical ylabel(-4(2)4, angle(horizontal)) yscale(range(-4 4)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lc(black)) xline(4, lpattern(dash) lc(black)) ciopts(recast(rline) lpattern(dash) lcolor("black")) coeflabels(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") order(bb_pre_et_agb_year_4 = "t-4" bb_pre_et_agb_year_3 = "t-3" bb_pre_et_agb_year_2 = "t-2" bb_neg1 = "t-1" bb_post_et_agb_year_0 = "t" bb_post_et_agb_year_1 = "t+1" bb_post_et_agb_year_2 = "t+2" bb_post_et_agb_year_3 = "t+3" bb_post_et_agb_year_4 = "t+4" bb_post_et_agb_year_5 = "t+5") xtitle("Number of Years Since Bar & Restaurant Smoking Ban Effective") title("Event Study: Effect of Bar Smoking Bans" "on Former-Smoking Status") name(es_smoke_former)
graph export "$out/event_study_ind_smoke_former.png", replace
graph export "$out/event_study_ind_smoke_former.pdf", replace


log close
		