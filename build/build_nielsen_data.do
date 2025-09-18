*****
/*
Anne Burton
Smoking and Drinking Project
Build Nielsen analysis data set from raw consumer panel files

Sample:
- Dates: Jan 2004 - December 2012
- Smoking: 
- Drinking: 
- Unit of observation: household (aggregate to county-quarter?)
*/

clear all

set more off
capture log close

log using "$build_log/build_nielsen_data.txt", text replace

* import and save Nielsen data as .dta files *


local datatypes "panelists products_extra trips"

forvalues y = 2004(1)2012 {
	foreach datatype of local datatypes {
		disp "datatype is `datatype' and year is " `y'		
		disp "year is " `y'
		import delimited "$nielsen_data/`y'/Annual_Files/`datatype'_`y'.tsv", clear
		save "$nielsen_data/clean/nielsen_cp_`datatype'_raw_`y'.dta", replace
	}
}

forvalues y = 2004(1)2012 {
	disp "year is " `y'
	import delimited "$nielsen_data/`y'/Annual_Files/purchases_`y'.tsv", clear
	save "$nielsen_data/clean/nielsen_cp_purchases_raw_`y'.dta", replace
		
}



*retailers, products, and brand variations are 1 big master file each
local files "brand_variations products retailers"
foreach file of local files {
	disp "file is `file'"
	import delimited "$nielsen_data/Master_Files/Latest/`file'.tsv", clear
	save "$nielsen_data/clean/nielsen_cp_`file'_raw.dta", replace
	}

*clean products dataset
use "$nielsen_data/clean/nielsen_cp_products_raw.dta", clear

keep if department_descr == "ALCOHOLIC BEVERAGES" | product_group_descr == "TOBACCO & ACCESSORIES"

save "$nielsen_data/nielsen_cp_products_alc_cigs_raw.dta", replace


use "$nielsen_data/nielsen_cp_products_alc_cigs_raw.dta", clear

*standardize units of alcohol (it's currently in mL, L, and oz)
gen alc_ml = .
replace alc_ml = size1_amount if department_descr == "ALCOHOLIC BEVERAGES" & size1_units == "ML"
replace alc_ml = size1_amount*1000 if department_descr == "ALCOHOLIC BEVERAGES" & size1_units == "LI"
replace alc_ml = size1_amount*29.5735 if department_descr == "ALCOHOLIC BEVERAGES" & size1_units == "OZ"

*for some reason there is 1 type of salem cigarettes that are allegedly measured in ounces not count... making a flag
gen cig_odd_size_flag = .
replace cig_odd_size_flag = 1 if product_module_descr == "CIGARETTES" & size1_units == "OZ"

save "$nielsen_data/nielsen_cp_products_alc_cigs_clean.dta", replace


*append purchases datasets to each other and merge with products dataset
use "$nielsen_data/clean/nielsen_cp_purchases_raw_2004.dta", clear

forvalues y = 2005(1)2012 {
	append using "$nielsen_data/clean/nielsen_cp_purchases_raw_`y'.dta"
	}
	
save "$nielsen_data/clean/nielsen_cp_purchases_2004_2012.dta", replace


*merge purchases datasets with products dataset for each year
forvalues i = 2004(1)2012 {
	use "$nielsen_data/clean/nielsen_cp_purchases_raw_`i'.dta", clear
	fmerge m:1 upc upc_ver_uc using "$nielsen_data/nielsen_cp_products_alc_cigs_clean.dta"
	keep if _merge != 1

	gen not_bought_flag = .
	replace not_bought_flag = 1 if _merge == 2
	replace not_bought_flag = 0 if _merge == 3

	drop _merge

	save "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_`i'.dta", replace
}


*append purchases datasets to each other
use "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_2004.dta", clear

forvalues y = 2005(1)2012 {
	append using "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_`y'.dta"
}

save "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_clean_2004_2012.dta", replace


*append trips datasets to each other
use "$nielsen_data/clean/nielsen_cp_trips_raw_2004.dta", clear

forvalues y = 2005(1)2012 {
	append using "$nielsen_data/clean/nielsen_cp_trips_raw_`y'.dta"
	}

save "$nielsen_data/clean/nielsen_cp_trips_2004_2012.dta", replace

*merge purchases (w/product info) with trips dataset
use "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_clean_2004_2012.dta", clear

fmerge m:1 trip_code_uc using "$nielsen_data/clean/nielsen_cp_trips_2004_2012.dta"

*dropped trips where neither alcohol nor cigarettes were bought
keep if _merge != 2

*if i'm understanding the structure of the data correctly, no_trips_flag should be perfectly collinear with not_bought_flag
gen no_trips_flag = .
replace no_trips_flag = 1 if _merge == 1
replace no_trips_flag = 0 if _merge == 3

drop _merge

save "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_trips_clean_2004_2012.dta", replace

*append household datasets to each other
use "$nielsen_data/clean/nielsen_cp_panelists_raw_2004.dta", clear

forvalues y = 2005(1)2012 {
	append using "$nielsen_data/clean/nielsen_cp_panelists_raw_`y'.dta"
	}
	
ren household_cd household_code

save "$nielsen_data/clean/nielsen_cp_panelists_2004_2012.dta", replace

*merge purchases (w/product and trip info) with household info
use "$nielsen_data/clean/nielsen_cp_alc_cigs_purchases_trips_clean_2004_2012.dta", clear
fmerge m:1 household_code panel_year using "$nielsen_data/clean/nielsen_cp_panelists_2004_2012.dta"

*purchase date
label variable purchase_date "(string) date of trip"

split purchase_date, parse("-") destring

ren purchase_date1 purchase_date_yr
ren purchase_date2 purchase_date_mo
ren purchase_date3 purchase_date_day

gen purchase_date_v1 = mdy(purchase_date_mo, purchase_date_day, purchase_date_yr)
label variable purchase_date_v1 "date of trip (mm/dd/yyyy)"
format purchase_date_v1 %td

gen purchase_date_v2 = ym(purchase_date_yr, purchase_date_mo)
label variable purchase_date_v2 "date of trip (mm/yyyy)"
format purchase_date_v2 %tm


*sober_household_flag = 1 if household never scanned in purchases of tobacco or alcohol for home consumption
gen sober_household_flag = .
replace sober_household_flag = 1 if _merge == 2
replace sober_household_flag = 0 if _merge == 1 | _merge == 3

*no_household_bought_flag = 1 if no household bought that specific tobacco or alcohol product
gen no_household_bought_flag = .
replace no_household_bought_flag = 1 if _merge == 1
replace no_household_bought_flag = 0 if _merge == 2 | _merge == 3

drop _merge


*standardize drinks (beer, wine, liquor)
*approximation: beer = 12 oz/serving, wine = 5 oz (150 ml)/serving, liquor = 1.5 oz/serving

*drop all the sparkling cider lol
drop if product_module_descr == "WINE - NON ALCOHOLIC"

*drop all the fruits/vegetables in alcohol...
drop if product_module_descr == "FRUIT AND VEGETABLE IN ALCOHOL"

gen alc_servings = .
replace alc_servings = multi*alc_ml/150 if product_group_descr == "WINE"
replace alc_servings = multi*alc_ml/29.5735/12 if product_group_descr == "BEER"
replace alc_servings = multi*alc_ml/29.5735/1.5 if product_group_descr == "LIQUOR"

*make variables for the types of alcohol, will run robustness check of purchases by alcohol type
gen wine = 0
replace wine = 1 if product_group_descr == "WINE"
gen beer = 0
replace beer = 1 if product_group_descr == "BEER"
gen liquor = 0
replace liquor = 1 if product_group_descr == "LIQUOR"

local alctypes "beer wine liquor"
foreach type of local alctypes {
	gen alc_servings_`type' = alc_servings*`type'
	label variable alc_servings_`type' "servings of `type'"
}

label variable alc_servings "servings of alcohol"

drop if household_code == . & panel_year == .

*generate smoker variables
*first pass: define a household as a smoking household if the household bought cigarettes in that calendar year
gen buy_cigs = 1 if product_module_descr == "CIGARETTES" | product_module_descr == "TOBACCO-SMOKING"

bysort household_code purchase_date_yr: egen smoker = max(buy_cigs)
replace smoker = 0 if smoker == .

sum smoker, detail

sort household_code panel_year
by household_code panel_year: gen num_purchases = _n

sum smoker if num_purchases == 1, detail
tab smoker

expand 12 if sober_household == 1

replace purchase_date_yr = panel_year if sober_household == 1
bysort sober_household household_code panel_year: replace purchase_date_mo = _n if sober_household == 1

replace purchase_date_v2 = ym(purchase_date_yr, purchase_date_mo) if sober_household == 1
format purchase_date_v2 %tm


*convert to cigarette packs
gen cig_packs = multi*size1_amount/20 if product_module_descr == "CIGARETTES"
label variable cig_packs "# packs of cigarettes"


*executive decision: here is where i DROP purchases made outside the panel year when the household moves to a different county/state
sort household_code purchase_date_yr purchase_date_v1
by household_code purchase_date_yr: gen num_purchases_temp = _n
gen fips_county_cd_v1 = fips_county_cd if num_purchases_temp == 1
gen fips_state_cd_v1 = fips_state_cd if num_purchases_temp == 1
bysort household_code purchase_date_yr: egen fips_county_cd_v2 = max(fips_county_cd_v1)
bysort household_code purchase_date_yr: egen fips_state_cd_v2 = max(fips_state_cd_v1)
drop if fips_county_cd_v2 != fips_county_cd | fips_state_cd_v2 != fips_state_cd

sort household_code purchase_date_v2

* clean and/or make demographic control variables--only need these for the poisson robustness check b/c ppmlhdfe didn't like the HH FEs

*race
label variable race "race"
label values race race
label define race ///
	1	"white" ///
	2	"black" ///
	3	"asian" ///
	4	"other", replace
	
tab race panel_year, missing

*hispanic origin
label variable hispanic_origin "Hispanic origin"
label values hispanic_origin hispanic_origin
label define hispanic_origin ///
	1	"hispanic" ///
	2	"non-hispanic", replace

tab hispanic_origin panel_year, missing

*combine race and hispanic origin
gen race_v1 = .
replace race_v1 = 1 if race == 1 & hispanic == 2
replace race_v1 = 2 if race == 2 & hispanic == 2
replace race_v1 = 3 if hispanic == 1
replace race_v1 = 4 if race == 3 & hispanic == 2
replace race_v1 = 5 if hispanic == 2 & (race != 1 & race != 2 & race != 3)
	
tab race_v1 panel_year, missing

*educational attainment of male head
label variable male_head_education "male head edu."
label values male_head_education male_head_education
label define male_head_education ///
	1	"grade school" ///
	2	"some high school" ///
	3	"high school grad." ///
	4	"some college" ///
	5	"college grad." ///
	6	"post-college grad." ///
	0	"no male head/unknown", replace
	
tab male_head_education panel_year, missing

*educational attainment of female head
label variable female_head_education "female head edu."
label values female_head_education female_head_education
label define female_head_education ///
	1	"grade school" ///
	2	"some high school" ///
	3	"high school grad." ///
	4	"some college" ///
	5	"college grad." ///
	6	"post-college grad." ///
	0	"no female head/unknown", replace

tab female_head_education panel_year, missing
tab female_head_education male_head_education, missing

*maximum (known) educational attainment of household heads
gen head_education_temp = max(male_head_education, female_head_education)
gen head_education = . if head_education_temp == 0
replace head_education = 1 if head_education_temp == 1 | head_education_temp == 2
replace head_education = 2 if head_education_temp == 3
replace head_education = 3 if head_education_temp == 4
replace head_education = 4 if head_education_temp == 5 | head_education_temp == 6

tab head_education male_head_education, missing
tab head_education female_head_education, missing

drop head_education_temp


*age of female HH head
label variable female_head_age "age bracket of female head"
label values female_head_age female_head_age
label define female_head_age ///
	1	"< 25" ///
	2	"25-29" ///
	3	"30-34" ///
	4	"35-39" ///
	5	"40-44" ///
	6	"45-49" ///
	7	"50-54" ///
	8	"55-64" ///
	9	"65+" ///
	0	"no female head", replace
	
tab female_head_age household_size, missing

*age of male HH head
label variable male_head_age "age bracket of male head"
label values male_head_age male_head_age
label define male_head_age ///
	1	"< 25" ///
	2	"25-29" ///
	3	"30-34" ///
	4	"35-39" ///
	5	"40-44" ///
	6	"45-49" ///
	7	"50-54" ///
	8	"55-64" ///
	9	"65+" ///
	0	"no male head", replace
	
tab male_head_age household_size, missing
tab female_head_age male_head_age, missing

*maximum (known) age of HH head
gen head_age = max(male_head_age, female_head_age)
replace head_age = . if head_age == 0

tab head_age male_head_age, missing
tab head_age female_head_age, missing

*employment status of male head
label variable male_head_employment "employment status male head"
label values male_head_employment male_head_employment
label define male_head_employment ///
	1	"< 30 hours" ///
	2	"30-34 hours" ///
	3	"35+ hours" ///
	9	"not employed for pay" ///
	0	"no male head", replace
	
tab male_head_employment male_head_age, missing
	
*employment status of female head
label variable female_head_employment "employment status female head"
label values female_head_employment female_head_employment
label define female_head_employment ///
	1	"< 30 hours" ///
	2	"30-34 hours" ///
	3	"35+ hours" ///
	9	"not employed for pay" ///
	0	"no female head", replace
	
tab female_head_employment female_head_age, missing
tab male_head_employment female_head_employment, missing

gen head_employment = . if male_head_employment == 0 & female_head_employment == 0
replace head_employment = 1 if (male_head_employment >=1 & male_head_employment <= 3) | (female_head_employment >=1 & female_head_employment <= 3)
replace head_employment = 0 if head_employment == . & (male_head_employment == 9 | female_head_employment == 9)

tab head_employment male_head_employment, missing
tab head_employment female_head_employment, missing

gen household_num_adults = household_size
forvalues i = 1(1)7{
	replace household_num_adults = household_num_adults - 1 if purchase_date_yr-member_`i'_birth < 18
}

*age and presence of children
label variable age_and_presence_of_children "age brackets of minor children in HH"
label values age_and_presence_of_children age_and_presence_of_children
label define age_and_presence_of_children ///
	1	"<6 only" ///
	2	"6-12 only" ///
	3	"13-17 only" ///
	4	"<6 & 6-12" ///
	5	"<6 & 13-17" ///
	6	"6-12 & 13-17" ///
	7	"< 6, 6-12, 13-17" ///
	9	"none", replace

gen children = 1
replace children = 0 if age_and_presence_of_children == 9

tab household_size household_num_adults if children == 0
tab household_size household_num_adults if children == 1

*household composition
label variable household_composition "who lives with head"
label values household_composition household_composition
label define household_composition ///
	1	"married" ///
	2	"female head + other relatives" ///
	3	"male head + other relatives" ///
	5	"female living alone" ///
	6	"female + non-relatives" ///
	7	"male living alone" ///
	8	"male + non-relatives", replace

gen female_head = 0
replace female_head = 1 if household_composition == 2 | household_composition == 5 | household_composition == 6
label variable female_head "=1 if female (unmarried) head"

gen male_head = 0
replace male_head = 1 if household_composition == 3 | household_composition == 7 | household_composition == 8
label variable male_head "=1 if male (unmarried) head"


*make a dataset that gets monthly household purchases of alcohol and cigarettes w/household demographic characteristics
collapse projection_factor panelist_zipcd fips_state_cd fips_county_cd smoker (firstnm) household_size household_composition head_age marital_status race_v1 head_education head_employment household_num_adults children female_head male_head (sum) alc_servings* cig_packs (max) buy_cigs, by(household_code fips_state_desc fips_county_desc purchase_date_yr purchase_date_mo purchase_date_v2)


*now make a new dataset that is just a cross-section of the households for each panel year, to then expand to get a household-month unit of observation, which i can then merge with the real data
preserve 

sort household_code purchase_date_yr purchase_date_mo
by household_code purchase_date_yr: gen num_purchases = _n
tab num_purchases

bysort household_code purchase_date_yr: egen max_months = max(num_purchases)
tab max_months

keep if num_purchases == 1

keep household_code fips_state_desc fips_county_desc projection_factor panelist_zipcd fips_state_cd fips_county_cd smoker household_size household_composition head_age marital_status race_v1 head_education head_employment household_num_adults children female_head male_head purchase_date_yr purchase_date_mo
expand 12
bysort household_code purchase_date_yr: replace purchase_date_mo = _n

gen purchase_date_v2 = ym(purchase_date_yr, purchase_date_mo)

save "$nielsen_data/nielsen_cp_monthly_cross-section_2004_2012.dta", replace

restore

*now merge the real data with the cross section!
merge 1:1 household_code purchase_date_yr purchase_date_mo using "$nielsen_data/nielsen_cp_monthly_cross-section_2004_2012.dta"

replace alc_servings = 0 if _merge == 2
replace cig_packs = 0 if _merge == 2

gen alc_any = 1
replace alc_any = 0 if alc_servings == 0

gen cig_any = 1
replace cig_any = 0 if cig_packs == 0

*rename variables
ren fips_state_cd fips_state_code
ren fips_county_cd fips_county_code
ren panelist_zipcd panelist_zip_code

gen alc_servings_1 = alc_servings
replace alc_servings_1 = . if alc_servings == 0

gen cig_packs_1 = cig_packs
replace cig_packs_1 = . if cig_packs == 0

gen year = purchase_date_yr

* each year's wave starts the sunday before jan 1, so for the 2004 wave (jan 1 = thursday), the first purchases occur on dec 28, 2003 (sunday)
drop if year == 2003

drop _merge

*transform alc_any (extensive margin) into percentage
replace alc_any = alc_any*100
label variable alc_any "whether household purchased off-premises alcohol in past month (100 = yes)"

replace cig_any = cig_any*100
label variable cig_any "whether household purchased cigarettes in past month (100 = yes)"

gen time_moyr = purchase_date_v2
format time_moyr %tm

*** label variable values ***

* (max) age of head
label variable head_age "age bracket of eldest head"
label values head_age head_age
label define head_age ///
	1	"< 25" ///
	2	"25-29" ///
	3	"30-34" ///
	4	"35-39" ///
	5	"40-44" ///
	6	"45-49" ///
	7	"50-54" ///
	8	"55-64" ///
	9	"65+", replace

* marital status
label variable marital_status "marital status of heads"
label values marital_status marital_status
label define marital_status ///
	1	"married" ///
	2	"widowed" ///
	3	"divorced/separated" ///
	4	"single", replace

* race/ethnicity
label variable race_v1 "race & Hispanic origin"
label values race_v1 race_v1
label define race_v1 ///
	1	"non-hispanic white" ///
	2	"non-hispanic black" ///
	3	"hispanic" ///
	4	"non-hispanic asian" ///
	5	"non-hispanic other", replace

* (max) education of head
label variable head_education "max head edu."
label values head_education head_education
label define head_education ///
	1	"less than high school" ///
	2	"high school grad" ///
	3	"some college" ///
	4	"college grad", replace
	

save "$nielsen_data/nielsen_cp_monthly_alc_cigs_2004_2012.dta", replace


log close
exit
