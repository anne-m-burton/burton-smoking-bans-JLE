*****
/*
Anne Burton
Smoking and Drinking Project
Build BRFSS analysis data set from raw BRFSS data files (imported from SAS)

Sample:
- Dates: Jan 2004 - December 2012
- Smoking: 
- Drinking: 
- Unit of observation: individual
*/

clear all

set more off
capture log close

log using "$build_log/build_brfss_individual_data.txt", text replace



********************************************************************************
******** read in BRFSS data from SAS XPORT file ***************
forvalues i = 2004(1)2012 {
	import sasxport5 "$build_data_brfss/brfss_raw_`i'.XPT", clear
	save "$build_data_brfss/brfss_raw_`i'.dta", replace
	}


******** clean BRFSS data ********
forvalues i = 2004(1)2012 {

use "$build_data_brfss/brfss_raw_`i'.dta", clear
*looks like each wave has interviews in multiple years... creating a wave variable so i don't forget why some obs. are missing questions for some years

gen wave = `i'

ren _state fips
destring imonth iday iyear, replace


*** controls you actually use!!
*_ageg5yr marital sex race2 _educag emp_emp county_state time_moyr region_moyr


*** sex ***
label values sex sex
label define sex 		///
	1	"Male"			///
	2	"Female"		///
	9	"Refused", replace

	
*** age ***
	label values age age
	label define age				///
		7	"Don't Know/Not Sure"	///
		9	"Refused", replace

	
*** race ***
label values race2 race2
label define race2												///
	1	"Non-Hispanic white"									///
	2	"Non-Hispanic black"									///
	3	"Non-Hispanic Asian"									///
	4	"Non-Hispanic Native Hawaiian/Pacific Islander"			///
	5	"Non-Hispanic American Indian/Alaska Native"			///
	6	"Non-Hispanic other race"								///
	7	"Non-Hispanic multiracial"								///
	8	"Hispanic"												///
	9	"Don't Know/Not Sure/Refused", replace

	

*** marital status ***
label values marital marital
label define marital											///
	1	"Married"												///
	2	"Divorced"												///
	3	"Widowed"												///
	4	"Separated"												///
	5	"Never Married"											///
	6	"Member of Unmarried Couple"							///
	9	"Refused", replace


/*
brfss county coverage
2004 has county code for about 85%
2005 has county code for about 85%
2006 has county code for about 80%
2007 has county code for about 90%
2008 has county code for about 90%
2009 has county code for about 90%
2010 has county code for about 90%
2011 has county code for about 90%
2012 has county code for about 90%
*/

*county codes!!!!!!!

*2004-2010 (FIPS county codes)
if `i' >= 2004 & `i' <= 2010 {
label values ctycode ctycode
label define ctycode											///
	777		"Don't Know/Not Sure"								///
	999		"Refused", replace
	}
	
*2011-2012 (ANSI county codes)
if `i' >= 2011 & `i' <= 2012 {
label values ctycode1 ctycode1
label define ctycode1											///
	777		"Don't Know/Not Sure"								///
	999		"Refused", replace
	}

*************************
* employment status
gen empstat = employ


label values empstat empstat
label define empstat											///
	1	"Employed for wages"									///
	2	"Self-employed"											///
	3	"Out of work for 1+ years"								///
	4	"Out of work for <1 year"								///
	5	"Homemaker"												///
	6	"Student"												///
	7	"Retired"												///
	8	"Unable to work"										///
	9	"Refused", replace

*generate new variables
gen emp_emp = .
replace emp_emp = 1 if empstat == 1 | empstat == 2
replace emp_emp = 0 if empstat > 2 & empstat < 9
label variable emp_emp "=1 if employed"

gen emp_ue = .
replace emp_ue = 1 if empstat == 3 | empstat == 4
replace emp_ue = 0 if empstat < 3 | (empstat > 4 & empstat < 9)
label variable emp_ue "=1 if unemployed"

gen emp_uelr = .
replace emp_uelr = 1 if empstat == 3
replace emp_uelr = 0 if empstat < 3 | (empstat > 3 & empstat < 9)
label variable emp_uelr "=1 if unemployed 1+ years"

gen emp_uesr = emp_ue - emp_uelr
label variable emp_uesr "=1 if unemployed <1 year"

gen emp_nilf = .
replace emp_nilf = 1 if empstat > 4 & empstat < 9
replace emp_nilf = 0 if empstat < 5
label variable emp_nilf "=1 if not in labor force"

gen emp_home = .
replace emp_home = 1 if empstat == 5
replace emp_home = 0 if empstat < 5 | (empstat > 5 & empstat < 9)
label variable emp_home "=1 if homemaker"

gen emp_student = .
replace emp_student = 1 if empstat == 6
replace emp_student = 0 if empstat < 6 | (empstat > 6 & empstat < 9)
label variable emp_student "=1 if student"

gen emp_ret = .
replace emp_ret = 1 if empstat == 7
replace emp_ret = 0 if empstat < 7 | empstat == 8
label variable emp_ret "=1 if retired"

gen emp_disabled = .
replace emp_disabled = 1 if empstat == 8
replace emp_disabled = 0 if empstat < 8
label variable emp_disabled "=1 if unable to work"


******************
*income

ren income2 hhincome
	
label values hhincome hhincome
label define hhincome											///
	1	"< $10,000"												///
	2	"$10,000-14,999"										///
	3	"$15,000-19,999"										///
	4	"$20,000-24,999"										///
	5	"$25,000-34,999"										///
	6	"$35,000-49,999"										///
	7	"$50,000-74,999"										///
	8	"$75,000+"												///
	10	"$50,000+"												///
	77	"Don't Know/Not Sure"									///
	99	"Refused", replace



***************
*** smoking ***
***************

/********************
anne-made smoking variables:

smoke_everyday
smoke_someday
smoke_no
smoke_never
smoke_former
smoke_current
*********************/

*smoked 100+ cigs lifetime
label values smoke100 smoke100
label define smoke100										///
	1	"Yes"											///
	2	"No"												///
	7	"Don't Know/Not Sure"								///
	9	"Refused", replace
	
*current smoking status

*2004
if `i' == 2004 {
label values smokeday smokeday
label define smokeday										///
	1	"Every day"										///
	2	"Some days"										///
	3	"Not at all"											///
	7	"Don't Know/Not Sure"								///
	9	"Refused", replace

*replacing smoking status with "not at all" if respondent has not smoked 100+ cigarettes in lifetime (bc respondent wasn't asked the question)
replace smokeday = 3 if smokeday == . & smoke100 == 2

gen smoke_current = .
replace smoke_current = 1 if smokeday == 1 | smokeday == 2
replace smoke_current = 0 if smokeday == 3
label variable smoke_current "Current smoker"

*smoke_no is defined as not a current smoker
gen smoke_no = 1-smoke_current
label variable smoke_no "Not a current smoker"

*smoke_never is defined as not having smoked 100+ cigs in lifetime
gen smoke_never = .
replace smoke_never = 1 if smoke100 == 2
replace smoke_never = 0 if smoke100 == 1 & smokeday >= 1 & smokeday <= 3 /*don't want to include people who "don't know" or "refuse" to answer the current smoking status question*/
label variable smoke_never "Never smoker"

*smoke_former is defined as having smoked 100+ cigs in lifetime but reporting current status as no smoking
*not smoke_former is defined as being a current smoker or a never smoker
gen smoke_former = .
replace smoke_former = 1 if smoke100 == 1 & smokeday == 3
replace smoke_former = 0 if smoke_current == 1 | smoke_never == 1
label variable smoke_former "Former smoker"

	}
	
*2005-2012
if `i' >= 2005 & `i' <= 2012 {
label values smokday2 smokday2
label define smokday2											///
	1	"Every day"											///
	2	"Some days"											///
	3	"Not at all"												///
	7	"Don't Know/Not Sure"									///
	9	"Refused", replace


*replacing smoking status with "not at all" if respondent has not smoked 100+ cigarettes in lifetime (bc respondent wasn't asked the question)
replace smokday2 = 3 if smokday2 == . & smoke100 == 2

gen smoke_current = .
replace smoke_current = 1 if smokday2 == 1 | smokday2 == 2
replace smoke_current = 0 if smokday2 == 3
label variable smoke_current "Current smoker"

*smoke_no is defined as not a current smoker
gen smoke_no = 1-smoke_current
label variable smoke_no "Not a current smoker"
	
*smoke_never is defined as not having smoked 100+ cigs in lifetime
gen smoke_never = .
replace smoke_never = 1 if smoke100 == 2
replace smoke_never = 0 if smoke100 == 1 & smokday2 >= 1 & smokday2 <= 3
label variable smoke_never "Never smoker"

*smoke_former is defined as having smoked 100+ cigs in lifetime but reporting current status as no smoking
*not smoke_former is defined as being a current smoker or a never smoker
gen smoke_former = .
replace smoke_former = 1 if smoke100 == 1 & smokday2 == 3
replace smoke_former = 0 if smoke_current == 1 | smoke_never == 1
label variable smoke_former "Former smoker"


*former smokers plus never smokers should add up to smoke_no
}

****************
*** drinking ***
****************

/*******************
anne-made drinking variables:

drink_ext
drink_unc_day
drink_unc_amt
drink_binge_times_past30
drink_unc_max
*********************/


*drank any alcohol in past 30 days

	
*2005 to 2010
if `i' >= 2005 & `i' <= 2010 {
label values drnkany4 drnkany4
label define drnkany4											///
	1		"Yes"												///
	2		"No"												///
	7		"Don't Know/Not Sure"								///
	9		"Refused", replace
	}

*# days out of past 30 respondent drank alcohol
*in 2011 and later, they just ask how many days
*in 2005 to 2010 first they ask whether respondent drank, then they ask how many days so need to recode values
*in 2004, they just ask how many days

*101-107 is days per week - 100
*201-230 is days per month - 200


*2004
if `i' == 2004 {
label values alcday3 alcday3
label define alcday3											///
	777		"Don't Know/Not Sure"								///
	888		"None"												///
	999		"Refused", replace
	}

*2005-2010
if `i' >= 2005 & `i' <= 2010 {
label values alcday4 alcday4
label define alcday4											///
	777		"Don't Know/Not Sure"								///
	888		"None"												///
	999		"Refused", replace
	}

*2011-2012
if `i' >= 2011 & `i' <= 2012 {
label values alcday5 alcday5
label define alcday5											///
	777		"Don't Know/Not Sure"								///
	888		"None"												///
	999		"Refused", replace
	}

* make a variable for number of days drank alcohol in the past 30 (unconditional, so includes people who didn't drink at all)
gen drink_unc_day = .


*2004
if `i' == 2004 {
replace drink_unc_day = (alcday3-100)*30/7 if alcday3 > 100 & alcday3 < 108
replace drink_unc_day = 0 if alcday3 == 888
replace drink_unc_day = alcday3-200 if alcday3 > 200 & alcday3 < 231
	}

*2005-2010
if `i' >= 2005 & `i' <= 2010 {
replace drink_unc_day = 0 if drnkany4 == 2 | alcday4 == 888
replace drink_unc_day = (alcday4-100)*30/7 if alcday4 > 100 & alcday4 < 108
replace drink_unc_day = alcday4-200 if  alcday4 > 200 & alcday4 < 231
	}
*people who say yes they drank in the past 30 days but they drank 0 days out of past 30 (alcday4 = 888, drnkany4 = 1) are coded as drank 0 days...

*2011-2012
if `i' >= 2011 & `i' <= 2012 {
replace drink_unc_day = (alcday5-100)*30/7 if alcday5 > 100 & alcday5 < 108
replace drink_unc_day = 0 if alcday5 == 888
replace drink_unc_day = alcday5-200 if alcday5 > 200 & alcday5 < 231
	}
tab drink_unc_day iyear, missing

label variable drink_unc_day "Alcohol consumption, \# of days (unconditional)"
tab drink_unc_day, missing
*tab alcday5, missing

gen drink_ext = .
replace drink_ext = 100 if drink_unc_day > 0 & drink_unc_day < 31
replace drink_ext = 0 if drink_unc_day == 0
label var drink_ext "Alcohol consumption, extensive margin"

*avg # drinks consumed on days respondent drank alcohol (unconditional, so includes people who didn't drink at all)
gen drink_unc_amt = .
label variable drink_unc_amt "Alcohol consumption, amount per day (unconditional)"

*2004
if `i' == 2004 {
label values avedrnk avedrnk
label define avedrnk											///
	77	"Don't Know/Not Sure"									///
	99	"Refused", replace
*replacing avg. # drinks with a 0 if respondent reported drinking 0 days of last 30
replace avedrnk = 0 if avedrnk == . & drink_unc_day == 0
replace drink_unc_amt = avedrnk if avedrnk < 77
	}

*2005-2012
if `i' >= 2005 & `i' <= 2012 {
label values avedrnk2 avedrnk2
label define avedrnk2											///
	77	"Don't Know/Not Sure"									///
	99	"Refused", replace
*replacing avg. # drinks with a 0 if respondent reported drinking 0 days of last 30
replace avedrnk2 = 0 if avedrnk2 == . & drink_unc_day == 0
replace drink_unc_amt = avedrnk2 if avedrnk2 < 77
	}

*# occasions (not days) respondent binge drank (5+ men, 4+ women)
gen drink_binge_times_past30 = .
label variable drink_binge_times_past30 "# Times in Past 30 Days Binge Drank"

*2005 and earlier
*prior to 2006 they ask everybody about 5+ drinks... 2006 and later they ask 5+ for men and 4+ for women... not sure how to deal with this (make a dummy?)

*2004 to 2005
if `i' >= 2004 & `i' <= 2005 {
label values drnk2ge5 drnk2ge5
label define drnk2ge5											///
	77	"Don't Know/Not Sure"									///
	88	"None"													///
	99	"Refused", replace

	
*replacing drnk2ge5 with None if respondents reported drinking 0 days of last 30
replace drnk2ge5 = 88 if drnk2ge5 == . & drink_unc_day == 0
replace drink_binge_times_past30 = drnk2ge5 if drnk2ge5 < 77
replace drink_binge_times_past30 = 0 if drnk2ge5 == 88
	}
	
	

*2006 to 2012
if `i' >= 2006 & `i' <= 2012 {
label values drnk3ge5 drnk3ge5
label define drnk3ge5											///
	77	"Don't Know/Not Sure"									///
	88	"None"													///
	99	"Refused", replace

*replacing drnk3ge5 with None if respondents reported drinking 0 days of last 30
replace drnk3ge5 = 88 if drnk3ge5 == . & drink_unc_day == 0
replace drink_binge_times_past30 = drnk3ge5 if drnk3ge5 < 77
replace drink_binge_times_past30 = 0 if drnk3ge5 == 88


	}



*max # drinks in 1 occasion on past 30 days
*not available in 2004
if `i' >= 2005 & `i' <= 2012 {
label values maxdrnks maxdrnks									
label define maxdrnks 											///
	77	"Don't Know/Not Sure"									///
	99	"Refused", replace
	
	
*replacing maxdrnks with a 0 if respondent reported drinking 0 days of last 30
*fix maxdrnks for 2004 (should be missing for all obs)
replace maxdrnks = 0 if drink_unc_day == 0

gen drink_unc_max = .
replace drink_unc_max = maxdrnks if maxdrnks < 77
label variable drink_unc_max "Alcohol consumption, max. (unconditional)"
	}

save "$build_data_brfss/brfss_clean_`i'.dta", replace
*end of data cleaning
}

*now append all waves of data to get brfss clean master data file
use "$build_data_brfss/brfss_clean_2004.dta", clear

forvalues i = 2005(1)2012 {
	append using "$build_data_brfss/brfss_clean_`i'.dta", force
	}
	
*** make new variables for all years here, so you don't have to do it multiple times ***

*treating finalwt and llcpwt as equivalent
gen annewt = _finalwt
replace annewt = _llcpwt if _finalwt == .

* survey-set the data
svyset _psu [pweight=annewt], strata(_ststr)

ren fips fips_state_code
gen fips_county_code = .
replace fips_county_code = ctycode if wave <= 2010
replace fips_county_code = ctycode1 if wave == 2011 | wave == 2012

*change unreal county codes to missing
*777 = don't know/not sure
*999 = refused
*888 = not listed in the 2011/2012 codebooks/questionnaires, but the 2021 questionnaire says 888 = county in another state (all 888 values are for cell phone respondents so I think it's if you moved states but kept your cell phone #)
replace fips_county_code = . if fips_county_code == 777 | fips_county_code == 999 | fips_county_code == 888

*now make a flag for "no county code," which will be used to generate "county coverage" measures
gen flag_no_county = .
replace flag_no_county = 1 if fips_county_code == .
replace flag_no_county = 0 if fips_county_code != .
gen flag_county = 1-flag_no_county
label variable flag_county "=1 if obs has non-missing fips county code"

*** get summary stats of sample coverage ***
gsort iyear
by iyear: sum flag_county

*see what the sample size is like for each state for each year
gsort fips_state_code
by fips_state_code: tab iyear

*see what % of each state's observations have a county code for each year
gsort iyear fips_state_code
by iyear fips_state_code: tab flag_county


*make interview date into same format as smoking ban data (month-year level)
gen time_moyr = ym(iyear, imonth)
format time_moyr %tm

gen year = yofd(dofm(time_moyr))

* sample = 2004-2012 so drop the handful of interviews that were conducted in 2013 (in the 2012 wave)
drop if year < 2004 | year > 2012

* make demographic indicator variables (from categorical ones you use in regressions)
gen age_1834 = 0
replace age_1834 = 1 if age >= 18 & age <= 34
gen age_3554 = 0
replace age_3554 = 1 if age >= 35 & age <= 54
gen age_55plus = 0
replace age_55plus = 1 if age >= 55 & age <= 99
gen race_black = (race2 == 2)
gen race_asian = (race2 == 3)
gen race_hispanic = (race2 == 8)
gen race_white = (race2 == 1)
gen race_other = 0
replace race_other = 1 if race2 >= 4 & race2 <= 7
gen edu_maxhs = 0
replace edu_maxhs = 1 if _educag == 1 | _educag == 2
gen edu_leastcoll = 0
replace edu_leastcoll = 1 if _educag == 3 | _educag == 4
gen female = (sex == 2)
gen marital_married = (marital == 1)


* make any don't know/refused demographic variables "missing" bc they are still showing up in the regressions with the fixed effects as their own "group"

replace _ageg5yr = . if _ageg5yr == 14
replace marital = . if marital == 9
replace race2 = . if race2 == 9
replace _educag = . if _educag == 9

replace race_black = . if race2 == .
replace race_asian = . if race2 == .
replace race_hispanic = . if race2 == .
replace race_white = . if race2 == .
replace race_other = . if race2 == .
replace age_1834 = . if _ageg5yr == .
replace age_3554 = . if _ageg5yr == .
replace age_55plus = . if _ageg5yr == .
replace marital_married = . if marital == .
replace edu_maxhs = . if _educag == .
replace edu_leastcoll = . if _educag == .

tab age_1834, missing
tab age_3554, missing
tab age_55plus, missing
tab race_black, missing
tab race_asian, missing
tab race_hispanic, missing
tab race_white, missing
tab race_other, missing
tab edu_maxhs, missing
tab edu_leastcoll, missing
tab female, missing
tab marital_married, missing
tab emp_emp, missing

* label demographic variables for your summary stats tables (made in analysis_sd_brfss_sumstats)
label variable female "Fraction female"
label variable race_black "Fraction Black"
label variable race_asian "Fraction Asian"
label variable race_hispanic "Fraction Hispanic"
label variable race_white "Fraction white"
label variable race_other "Fraction other race"
label variable age_1834 "Fraction age 18-34"
label variable age_3554 "Fraction age 35-54"
label variable age_55plus "Fraction age 55+"
label variable emp_emp "Fraction employed"
label variable marital_married "Fraction married"
label variable edu_maxhs "Fraction high school or less"
label variable edu_leastcoll "Fraction some college or more"


*** smoking variables ***
gen smoke_current_pct = smoke_current*100
gen smoke_never_pct = smoke_never*100
gen smoke_former_pct = smoke_former*100
gen smoking_status = .

replace smoking_status = 1 if smoke_current == 1
replace smoking_status = 3 if smoke_never == 1
replace smoking_status = 4 if smoke_former == 1


*** drinking variables ***

*create variable for number of drinks drank in past 30 days
gen drink_tot = drink_unc_day*drink_unc_amt
label var drink_tot "Alcohol consumption, total"

*create variable for number of drinks drank in past 30 days that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_tot_c = drink_tot
replace drink_tot_c = . if drink_unc_amt > 30
label variable drink_tot_c "Alcohol consumption, total (excludes > 30/day)"

*create variable for number of days drank in past 30 days that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_unc_day_c = drink_unc_day
replace drink_unc_day_c = . if drink_unc_amt > 30
label variable drink_unc_day_c "Alcohol consumption, \# days (unconditional; excludes > 30/day)"

*create variable for number of days drank in past 30 days conditional on drinking
gen drink_day = drink_unc_day
replace drink_day = . if drink_ext == 0
label var drink_day "Alcohol consumption, \# days"

*create variable for number of days drank in past 30 days (conditional on drinking) that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_day_c = drink_unc_day
replace drink_day_c = . if drink_ext == 0
replace drink_day_c = . if drink_unc_amt > 30
label variable drink_day_c "Alcohol consumption, \# days (excludes > 30/day)"

*make variable that's amount drunk conditional on drinking
gen drink_int = drink_tot
replace drink_int = . if drink_ext == 0
label var drink_int "Alcohol consumption, intensive margin"

*create variable that's amount drunk conditional on drinking that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_int_c = drink_int
replace drink_int_c = . if drink_unc_amt > 30
label variable drink_int_c "Alcohol consumption, intensive margin (excludes > 30/day)"

*create variable for avg. # drinks drunk per day that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_unc_amt_c = drink_unc_amt
replace drink_unc_amt_c = . if drink_unc_amt > 30
label variable drink_unc_amt_c "Alcohol consumption, amount per day (uncondtional; excludes > 30/day)"

*create variable for avg. # drinks drunk per day (conditional on drinking that day)
gen drink_amt = drink_unc_amt if drink_unc_amt > 0
label var drink_amt "Alcohol consumption, amount per day"

*create avg. # drinks/day variable that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_amt_c = drink_amt
replace drink_amt_c = . if drink_unc_amt > 30
label variable drink_amt_c "Alcohol consumption, amount per day (excludes > 30/day)"

*create variable for maximum # drinks that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_unc_max_c = drink_unc_max
replace drink_unc_max_c = . if drink_unc_amt > 30
label variable drink_unc_max_c "Alcohol consumption, max. (unconditional; excludes > 30/day)"

*create variable for maximum # drinks (conditional on drinking)
gen drink_max = drink_unc_max
replace drink_max = . if drink_ext == 0
label var drink_max "Alcohol consumption, max."

*create variable for maximum # drinks (conditional on drinking) that excludes outliers (reported drinking an average of > 30 drinks per day)
gen drink_max_c = drink_unc_max
replace drink_max_c = . if drink_ext == 0
replace drink_max_c = . if drink_unc_amt > 30
label variable drink_max_c "Alcohol consumption, max. (excludes > 30/day)"


* only keep the variables and observations you need
keep wave annewt *state* *county* idate imonth iday *year* time_moyr flag_* *smok* *drink* *age* *race* *hisp* female *marital* *edu* *emp* hhincome sex _msacode

drop if fips_state_code == 72 | fips_state_code == 78

save "$build_data/brfss_clean_2004_2012.dta", replace


log close
