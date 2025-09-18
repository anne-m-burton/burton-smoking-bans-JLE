*****
/*
Anne Burton
Smoking and Drinking Project
Build policy control variables datasets

Sample:
- Dates: Jan 2004 - December 2012
- BAC limits from the Alcohol Policy Information System (APIS)
- Cigarette taxes from the Tax Burden on Tobacco (TBOT)
*/

clear all

set more off
capture log close

log using "$build_log/build_controls.txt", text replace

* first import a dataset that contains state names, postal abbreviations, and fips codes ***
import excel "$build_data/state_fips_codes.xlsx", sheet("Sheet1") firstrow clear

save "$build_data/state_fips_codes.dta", replace


***************************
* clean alcohol policy data
***************************

*** import and clean the BAC data ***

/*sources: 
https://alcoholpolicy.niaaa.nih.gov/apis-policy-topics/adult-operators-of-noncommercial-motor-vehicles/12/changes-over-time#page-content
https://alcoholpolicy.niaaa.nih.gov/apis-policy-topics/adult-operators-of-noncommercial-motor-vehicles/12#page-content
*/


* changes over time
import excel "$build_data/adult-operators-of-noncommercial-motor-vehicles_changes.xlsx", sheet("Worksheet 1") firstrow clear

drop CitationsCount Citations JurisNote RowNote PerSe

split DateRange, parse(" - ")

gen start_date = date(DateRange1, "MDY")
format start_date %td

gen end_date = date(DateRange2, "MDY")
format end_date %td

split Jurisdiction, parse(" (")
ren Jurisdiction1 state_name

* you don't need per se BAC changes over time and 2 states, MA and SC, have those in this dataset. it's adding an extra row for those states and messing up the start/end dates of the BAC policy so addressing that with these lines of code
bys state_name BACLimit: gen number = _n
tab number

bys state_name BACLimit: egen min_start_date = min(start_date)
bys state_name BACLimit: egen max_end_date = max(end_date)
format min_start_date %td
format max_end_date %td

drop if number == 2
drop start_date end_date number
ren min_start_date start_date
ren max_end_date end_date
*** 

drop Jurisdiction Jurisdiction2 DateRange DateRange1 DateRange2

merge m:1 state_name using "$build_data/state_fips_codes.dta"
* _merge = 2 denotes states that did not have any BAC limit changes between January 1, 1998 and January 1, 2021
drop if _merge == 2
drop _merge

sort fips_state_code start_date
by fips_state_code: gen number = _n

reshape wide BACLimit start_date end_date, i(state_name) j(number)

save "$build_data/bac_changes.dta", replace

* policies as of January 1, 2021
import excel "$build_data/adult-operators-of-noncommercial-motor-vehicles_2021.xlsx", sheet("Worksheet 1") firstrow clear

ren BACLimit bac_limit

split Jurisdiction, parse(" (")
ren Jurisdiction1 state_name

drop Jurisdiction Jurisdiction2 CitationsCount Citations JurisNote RowNote Policiesasof PerSe
drop if state_name == "United States"

merge 1:1 state_name using "$build_data/state_fips_codes.dta"
drop _merge

*make the dataset be monthly, starting in 2004 and going through 2012
expand 108

bys fips_state_code: gen number = _n
gen time_moyr = ym(2004, 01)
format time_moyr %tm

replace time_moyr = time_moyr + number - 1
drop number

merge m:1 fips_state_code using "$build_data/bac_changes.dta"
drop _merge

replace bac_limit = BACLimit1 if start_date1 == td(01jan1998)
replace bac_limit = BACLimit2 if time_moyr > mofd(end_date1)

gen bac08 = (bac_limit == 0.08)

drop BACL* start_date* end_date*

order fips_state_code time_moyr state_name state_abbr bac_limit bac08

label variable bac08 "BAC 0.08\%"

save "$build_data/alc_policies.dta", replace

***************************
* clean tobacco policy data
***************************

import excel "$build_data/tbot_vol51_1970_2016.xls", sheet("The_Tax_Burden_on_Tobacco_Volum") firstrow clear
label values SubMeasureIdDisplayOrder sub
label define sub												///
	1	"average cost per pack ($)"								///
	2	"cigarette consumption (# packs sold per capita)"		///
	3	"federal + state tax as % of retail price (%)"			///
	4	"federal + state tax per pack ($)"						///
	5	"gross cigarette tax revenue ($)"						///
	6	"state tax per pack ($)"


keep LocationAbbr LocationDesc Year Data_Value SubMeasureIdDisplayOrder

reshape wide Data_Value, i(LocationDesc Year) j(SubMeasureIdDisplayOrder)

*rename the variables so you know what they are...
ren Year year

ren Data_Value1 avgpackcost
label variable avgpackcost "average cost per pack ($)"

ren Data_Value2 packspercap
label variable packspercap "cigarette consumption (# packs sold per capita)"

ren Data_Value3 fedstatetax_pct_retail
label variable fedstatetax_pct_retail 	"federal + state tax as % of retail price (%)"

ren Data_Value4 fedstatetax_pack
label variable fedstatetax_pack "federal + state tax per pack ($)"

ren Data_Value5 cigtaxrev
label variable cigtaxrev "gross cigarette tax revenue ($)"

ren Data_Value6 statetax_pack
label variable statetax_pack "state tax per pack ($)"

gen retail_est = fedstatetax_pack/fedstatetax_pct_retail*100
label variable retail_est "estimated retail price"

gen pack_est = cigtaxrev/fedstatetax_pack
label variable pack_est "estimated # packs sold"

ren LocationDesc state

save "$build_data/tbot_2016.dta", replace

keep state year LocationAbbr fedstatetax_pack

keep if year >= 2004 & year <= 2012

ren state state_name
ren LocationAbbr state
ren fedstatetax_pack cig_tax_pack

label variable cig_tax_pack "Cigarette tax per pack (\$)"


save "$build_data/cig_policies.dta", replace


log close
