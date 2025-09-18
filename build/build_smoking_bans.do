*****
/*
Anne Burton
Smoking and Drinking Project
Build smoking ban treatment dataset from an American Nonsmokers' Rights Foundation pdf file that I copied, pasted, and formatted in excel

Sample:
- Dates: Jan 1990 - December 2012
- Unit of observation: starts out at city/county/state level and I'm converting all to county
*/

clear all

set more off
capture log close

log using "$build_log/build_smoking_bans.txt", text replace

*******************************************************************
* import smoking ban treatment dates from excel (smoke-free laws) *
*******************************************************************

import excel "$build_data/smoke_free_laws_1jul2018_copied.xlsx", sheet("Sheet1") cellrange(A9:L1571) firstrow

*delete rows that are blank or the year headers
drop if SmokefreePopulation == .

*rename variables
ren NoteThejurisdictionsaffect locality
ren State state
ren SmokefreeRestaurants r_eff_date
ren SmokefreeFreestandingBars b_eff_date
ren nodate flag_nodate
ren nobars flag_nobars

label variable r_eff_date "restaurant effective date"
label variable b_eff_date "bar effective date"

local types = "r b"
local times = "day month year"

foreach type of local types {
	foreach time of local times {
		gen `type'_eff_`time' = .
		}
	}

*fix obs. that don't have a known effective date (just effective year)
replace flag_nodate = 1 if r_eff_date == "N/D" | b_eff_date == "N/D"
*Sesser, IL
foreach type of local types {
	replace `type'_eff_year = 2017 if locality == "Sesser" & state == "IL"
	replace `type'_eff_date = "" if `type'_eff_date == "N/D"
	}
*fix obs. that don't have freestanding bars
replace flag_nobars = 1 if b_eff_date == "N/A"
replace b_eff_date = "" if flag_nobars == 1

*split effective dates into day-month-year
foreach type of local types {
	split `type'_eff_date, p("/")
		forvalues i = 1(1)3 {
			destring `type'_eff_date`i', replace
			}
	replace `type'_eff_month = `type'_eff_date1
	replace `type'_eff_day = `type'_eff_date2
	replace `type'_eff_year = `type'_eff_date3
	drop `type'_eff_date1 `type'_eff_date2 `type'_eff_date3
	}
	
*make entry variable that combines year and month into 1 variable
foreach type of local types {
	gen `type'_entry_moyr = ym(`type'_eff_year, `type'_eff_month)
	format `type'_entry_moyr %tm
	}
label variable b_entry_moyr "Year and Month of Effective Date of Smoking Ban in Bars"
label variable r_entry_moyr "Year and Month of Effective Date of Smoking Ban in Restaurants"

*if locality has a + next to its name, note that
*the + denotes that the county ban covered incorporated areas in addition to unincorporated areas
*a lack of + for a county denotes that the county ban only covered the unincorporated areas (e.g. King County excluding Seattle)
drop plus
gen flag_inc_plus_un = .
replace flag_inc_plus_un = 1 if strmatch(locality, "*+*") == 1
replace flag_inc_plus_un = 0 if (strmatch(locality,"*County*") == 1 | strmatch(locality, "*Parish*") == 1 | (strmatch(locality, "*Borough*") == 1 & state == "AK")) & flag_inc_plus_un != 1
gen flag_uninc_only = 1 - flag_inc_plus_un

label variable flag_inc_plus_un "=1 if county ban covers incorp. + unincorp."
label variable flag_uninc_only "=1 if county ban covers only unincorp."

*if locality has a ~ next to its name, note that
*the ~ denotes that the locality had an earlier smoke-free law that was repealed, weakened, or postponed so I should look into these localities individually
drop tilde
gen flag_most_recent_law = .
replace flag_most_recent_law = 1 if strmatch(locality, "*~*") == 1
*replace flag_most_recent_law = 0 if strmatch(locality, "*~*") == 0

label variable flag_most_recent_law "=1 if earlier law = repealed, etc."

* * and ** are on the column headers not the localities so not actually a variable
drop star
drop twostar

*generate an indicator variable for a state
gen flag_state = .
replace flag_state = 1 if locality == "Utah"
replace flag_state = 1 if locality == "California"
replace flag_state = 1 if locality == "Delaware"
replace flag_state = 1 if locality == "Florida"
replace flag_state = 1 if locality == "New York"
replace flag_state = 1 if locality == "Connecticut"
replace flag_state = 1 if locality == "Maine"
replace flag_state = 1 if locality == "Idaho"
replace flag_state = 1 if locality == "Massachusetts"
replace flag_state = 1 if locality == "Rhode Island"
replace flag_state = 1 if locality == "Vermont"
replace flag_state = 1 if locality == "Montana"
replace flag_state = 1 if locality == "Washington" & state == "WA"
replace flag_state = 1 if locality == "Washington" & state == "DC"
replace flag_state = 1 if locality == "New Jersey"
replace flag_state = 1 if locality == "Colorado"
replace flag_state = 1 if locality == "Hawaii"
replace flag_state = 1 if locality == "Ohio"
replace flag_state = 1 if locality == "Nevada" & state == "NV"
replace flag_state = 1 if locality == "Louisiana"
replace flag_state = 1 if locality == "Arizona"
replace flag_state = 1 if locality == "New Mexico"
replace flag_state = 1 if locality == "New Hampshire"
replace flag_state = 1 if locality == "Minnesota"
replace flag_state = 1 if locality == "Illinois"
replace flag_state = 1 if locality == "Maryland"
replace flag_state = 1 if locality == "Iowa"
replace flag_state = 1 if locality == "Oregon"
replace flag_state = 1 if locality == "Nebraska"
replace flag_state = 1 if locality == "North Carolina"
replace flag_state = 1 if locality == "Michigan"
replace flag_state = 1 if locality == "Kansas"
replace flag_state = 1 if locality == "Wisconsin"
replace flag_state = 1 if strmatch(locality, "South Dakota*") == 1
replace flag_state = 1 if locality == "Indiana"
replace flag_state = 1 if locality == "North Dakota"
replace flag_state = 1 if locality == "Pennsylvania"
label variable flag_state "=1 if locality is a state"


/*"no" states:
Alabama
Alaska
Arkansas
Georgia
Kentucky
Mississippi
Missouri
Oklahoma
Pennsylvania (has workplace ban but no bar/restaurant ban)
South Carolina
Tennessee
Texas
Virginia
West Virginia
Wyoming
*/

*generate an indicator variable for a county
gen flag_county = .
replace flag_county = 1 if strmatch(locality, "*County*") == 1
replace flag_county = 1 if strmatch(locality, "*Borough*") == 1 & state == "AK"
replace flag_county = 1 if strmatch(locality, "*Parish*") == 1
label variable flag_county "=1 if locality is a county"

*generate a variable for locality type
gen locality_type = .
replace locality_type = 1 if flag_state == 1
replace locality_type = 2 if flag_county == 1
replace locality_type = 3 if flag_state == . & flag_county == .
label variable locality_type "= type of locality"

label values locality_type locality_type
label define locality_type ///
	1	"state"	///
	2	"county"	///
	3	"city", replace
	
*make an indicator variable for coterminous city-county. code by hand
gen flag_coterminous = 0
replace flag_coterminous = 1 if locality == "Anchorage" & state == "AK"
replace flag_coterminous = 1 if strmatch(locality, "*Haines*") == 1 & state == "AK"
replace flag_coterminous = 1 if locality == "Juneau" & state == "AK"
replace flag_coterminous = 1 if locality == "Sitka" & state == "AK"
replace flag_coterminous = 1 if strmatch(locality, "*Skagway*") == 1 & state == "AK"
replace flag_coterminous = 1 if locality == "San Francisco" & state == "CA"
replace flag_coterminous = 1 if locality == "Honolulu" & state == "HI"
replace flag_coterminous = 1 if strmatch(locality, "*Lexington*") == 1 & state == "KY"
replace flag_coterminous = 1 if locality == "Nantucket" & state == "MA"
replace flag_coterminous = 1 if locality == "New York City" & state == "NY"
replace flag_coterminous = 1 if locality == "Philadelphia" & state == "PA"

/*
untreated:
Broomfield, CO
Denver, CO
Menominee, WI
New Orleans, LA
Yakutat, AK
Wrangell, AK

untreated consolidated city-counties:
https://www.census.gov/programs-surveys/popest/guidance-geographies/terms-and-definitions.html
Anaconda + Deer Lodge County, MT
Butte + Silver Bow County, MT
Columbus + Muscogee County, GA
Cusseta + Chattahoochee County, GA
Georgetown + Quitman County, GA
Los Alamos + Los Alamos County, NM
Lynchburg + Moore County, TN
Macon (+ Payne) + Bibb County, GA
Preston + Webster County, GA
Statenville + Echols County, GA
*/

*make an indicator variable for independent cities. code by hand
*https://www2.census.gov/geo/pdfs/reference/GARM/Ch4GARM.pdf
gen flag_independent_city = 0
replace flag_independent_city = 1 if locality == "Baltimore" & state == "MD"
replace flag_independent_city = 1 if locality == "St. Louis" & state == "MO"

*untreated independent city: Carson City, NV

	
save "$build_data/smoke_free_laws_1jul2018.dta", replace



***********************************************************************
* import and clean place data from census to match city laws with counties *
***********************************************************************

*** 2010 ANSI place file ***

*import the data from .txt format
import delimited "$build_data/ansi_place-to-county_2010.txt", clear

*some cities span multiple counties so get each county as its own variable
split county, parse(", ")

*make a dummy variable for cities with multiple counties
gen mult_county = 1 if county2 != ""
replace mult_county = 0 if county2 == ""
label variable mult_county "=1 if city spans >1 county"

*rename the ANSI fips code variables to fit my nomenclature
ren statefp fips_state_code
ren placefp fips_place_code

*rename other variables to fit my nomenclature
ren type place_type

/*
place types:
incorporated place: e.g., "cities, towns, villages"
census designated place: "closely settled, unincorporated communities that are locally recognized and identified by name"
1 place cannot be simultaneously part of an incorporated place and a cdp at the same time

county subdivision: components of counties, either minor civil divisions (e.g., townships) or census county divisions like in alaska

https://www.census.gov/programs-surveys/bas/information/cdp.html
https://www2.census.gov/geo/pdfs/reference/GARM/Ch8GARM.pdf
*/

*now that all the counties are listed separately, don't need the original variable with all the counties combined (need to drop it for reshape to work)
drop county

*some observations list counties with undefined county subdivisions but the counties are elsewhere in this dataset (so dropping these obs)
drop if placename == "County Subdivisions not defined"

*reshape the data so that each observation is a city-county pair
reshape long county, i(state fips_state_code fips_place_code placename place_type funcstat mult_county) j(county_number)

*reshape makes 5 observations for each place, but I only need the observations with a county in them, so I'm dropping the observations w/blank counties
drop if county == ""

*rename county to fit my nomenclature
ren county county_name

*drop puerto rican places because they aren't in your analysis
drop if fips_state_code == 72

save "$build_data/ansi_place-to-county_2010_clean.dta", replace


*** 2010 ANSI county file ***

*import the data from .txt format
import delimited "$build_data/ansi_county_codes_2010.txt", clear

*label all the variables
ren v1 state
ren v2 fips_state_code
ren v3 fips_county_code
ren v4 county_name
ren v5 fips_class_code

*change different county spellings by hand
replace county_name = "Doña Ana County" if county_name == "Dona Ana County" & state == "NM"

*drop u.s. territories & puerto rico because they aren't in your analysis
drop if fips_state_code > 56

save "$build_data/ansi_county_codes_2010_clean.dta", replace

*** merge place file and county file ***
use "$build_data/ansi_place-to-county_2010_clean.dta", clear

merge m:1 county_name fips_state_code using "$build_data/ansi_county_codes_2010_clean.dta"

/*non-merged observations accounted for
*kalawao county, hawaii has no places
*james city county has no places in master data and the county seat is williamsburg, which is an independent entity
*powhatan county has no places in master data
*/

drop _merge

*now make the names just the city name (no town, city, cdp, etc.)
split placename, parse(" town")
split placename1, parse(" city")
split placename11, parse(" CDP")
split placename111, parse(" borough")
split placename1111, parse(" village")
split placename11111, parse(" municipality")

ren placename111111 city
drop placename*

*change some city names by hand to be consistent with other data

replace fips_place_code = 36540 if city == "Kachemak" & state == "AK"

*castle pines cdp changed name to castle pines village cdp, and castle pines north city changed name to castle pines city
replace fips_place_code = 12393 if city == "Castle Pines" & state == "CO"
replace city = "Castle Pines Village" if city == "Castle Pines" & state == "CO"
replace fips_place_code = 12387 if city == "Castle Pines North" & state == "CO"
replace city = "Castle Pines" if city == "Castle Pines North" & state == "CO"
replace city = "Raymer" if city == "Raymer (New Raymer)" & state == "CO"

replace city = "DeFuniak Springs" if city == "De Funiak Springs" & state == "FL"
replace fips_place_code = 50875 if city == "Ocean Breeze Park" & state == "FL"
replace city = "Ocean Breeze" if city == "Ocean Breeze Park" & state == "FL"

replace city = "DeWitt" if city == "De Witt" & state == "IA"


replace city = "Holmdel Township" if city == "Holmdel" & state == "NJ"
replace city = "Livingston Township" if city == "Livingston" & state == "NJ"

replace city = "Montville Township" if city == "Montville" & state == "NJ"

replace city = "Española" if city == "Espanola" & state == "NM"

replace fips_place_code = 81935 if city == "Waverly City" & state == "OH"
replace city = "Waverly" if city == "Waverly City" & state == "OH"

replace city = "Parkers Crossroads" if city == "Parker's Crossroads" & state == "TN"

replace fips_place_code = 850 if fips_place_code == 625 & city == "Alburg" & state == "VT"
replace city = "Alburgh" if city == "Alburg" & state == "VT"


/*South Fulton, Georgia didn't incorporate until 2016 so it's not in the 2010 ANSI place codes file
https://en.wikipedia.org/wiki/South_Fulton,_Georgia*/
save "$build_data/city-county_pairs.dta", replace



**********************************************
*** now bring in city population estimates ***
**********************************************

*** 2000-2009 Incorporated Places Population Estimates file ***
*https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/cities/totals/sub-est2009-ip.csv
*import the raw data (csv file)
import delimited "$build_data/census_incorporated_place_pop_est_2000_2009.csv", encoding(ISO-8859-2) clear

*make an indicator variable for "formed/incorporated after the 2000 census"
*https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2000-2009/sub-est2009-ip.pdf
gen flag_post_2000 = 0
replace flag_post_2000 = 1 if popcensus_2000 == "X"
label variable flag_post_2000 "=1 if formed post-2000-Census"

*make a variable for destrung census population estimates
gen pop_census_2000 = popcensus_2000
replace pop_census_2000 = "" if flag_post_2000 == 1
destring pop_census_2000, replace

*now make the names just the city name (no town, city, cdp, etc.)
split name, parse(" town")
split name1, parse(" city")
split name11, parse(" CDP")
split name111, parse(" borough")
split name1111, parse(" village")
split name11111, parse(" municipality")
split name111111, parse(" UT")

ren name1111111 city
drop name*


*change some city names (and place codes as needed) by hand to be consistent with other data

*alaska
*https://www2.census.gov/geo/pdfs/reference/Geography_Notes.pdf
replace place = 36540 if city == "Kachemak" & statename == "Alaska"

*california
replace city = "La Cañada Flintridge" if city == "La Cańada Flintridge" & statename == "California"

*colorado
*https://en.wikipedia.org/wiki/Castle_Pines_(city),_Colorado
*Castle Pines North changed name to Castle Pines in 2010
replace place = 12387 if city == "Castle Pines North" & statename == "Colorado"
replace city = "Castle Pines" if city == "Castle Pines North" & statename == "Colorado"
replace city = "Cañon City" if city == "Cańon City" & statename == "Colorado"
replace place = 14765 if city == "Creede" & statename == "Colorado"
replace city = "City of Creede" if city == "Creede" & statename == "Colorado"

*florida
replace city = "DeFuniak Springs" if city == "De Funiak Springs" & statename == "Florida"
replace city = "DeLand" if city == "De Land" & statename == "Florida"
*https://en.wikipedia.org/wiki/Ocean_Breeze,_Florida
*Ocean Breeze Park changed name to Ocean Breeze in 2012
replace place = 50875 if city == "Ocean Breeze Park" & statename == "Florida"
replace city = "Ocean Breeze" if city == "Ocean Breeze Park" & statename == "Florida"

*iowa
replace city = "DeWitt" if city == "De Witt" & statename == "Iowa"

*massachusetts
replace place = 840 if city == "Agawam" & statename == "Massachusetts"
replace city = "Agawam Town" if city == "Agawam" & statename == "Massachusetts"
replace place = 19370 if city == "Easthampton" & statename == "Massachusetts"
replace city = "Easthampton Town" if city == "Easthampton" & statename == "Massachusetts"
replace place = 25172 if city == "Franklin" & statename == "Massachusetts"
replace city = "Franklin Town" if city == "Franklin" & statename == "Massachusetts"
replace place = 40710 if city == "Methuen" & statename == "Massachusetts"
replace city = "Methuen Town" if city == "Methuen" & statename == "Massachusetts"
replace place = 73440 if city == "Watertown" & statename == "Massachusetts"
replace city = "Watertown Town" if city == "Watertown" & statename == "Massachusetts"
replace place = 77890 if city == "West Springfield" & statename == "Massachusetts"
replace city = "West Springfield Town" if city == "West Springfield" & statename == "Massachusetts"

*there's a village of grosse pointe shores, mi that was incorporated in 1911 and then incorporated as a city (Village of Grosse Pointe Shores, A Michigan City) in 2009
*http://gpshoresmi.gov/OurCommunity/AboutGrossePointeShores.aspx
replace place = 82453 if city == "Grosse Pointe Shores" & statename == "Michigan"
replace city = "Village of Grosse Pointe Shores" if city == "Grosse Pointe Shores" & statename == "Michigan"

replace city = "Española" if city == "Espanola" & statename == "New Mexico"

*fixing the typo in the fips place code for 2000-2009 for lake santeetlah, nc (the 2000-2010 subcounty pop est, the 2010-2018 ip pop est, and the 2010-2018 subcounty pop est all have place code 35614, while 2000-2009 ip pop est has 36513)
*https://www2.census.gov/geo/docs/reference/bndrychange/united-states.txt
replace place = 36514 if city == "Lake Santeetlah" & statename == "North Carolina"

replace place = 81935 if city == "Waverly City" & statename == "Ohio"
replace city = "Waverly" if city == "Waverly City" & statename == "Ohio"

replace place = 83090 if city == "West Carrollton City" & statename == "Ohio"
replace city = "West Carrollton" if city == "West Carrollton City" & statename == "Ohio"

replace city = "DeCordova" if city == "deCordova" & statename == "Texas"

replace place = 850 if city == "Alburg" & statename == "Vermont"
replace city = "Alburgh" if city == "Alburg" & statename == "Vermont"

/* places with potentially problematic city comparisons across decades that are treated in my smoking bans paper:

*note: census areas in alaska are for statistical purposes only; they have no government, therefore they have no authority to implement a smoking ban. BUT census areas can contain cities, which can pass laws

Petersburg, AK
	-wrangell-petersburg census area was split into 2: 1) wrangell city and borough and 2) petersburg census area
	-wrangell = untreated for entire sample period
	-petersburg = treated (bar + restaurant bans) effective nov 1, 2010, which falls under 2010-2019 census pop estimates
	-pca est. pop = 4,260
	-wrangell est. pop = 2,448
	-use that same split for splitting pop in earlier years if necessary (aka if these places are even in the brfss)
	-new geography = 100% treated
	-https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2000.html

	Skagway, AK
	-skagway-hoonah-angoon census area was split into 2: 1) skagway municipality and 2) hoonah-angoon census area
	-hoonah-angoon = untreated
	-skagaway = treated (bar + restaurant bans) effective aug 26, 2011, which falls under 2010-2019 census pop estimates
	-haca est. pop = 2,574
	-skagway est. pop = 862
	-use that same split for splitting pop in earlier years if necessary (aka if these places are even in the brfss)
	-new geography = 100% treated
	-https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2000.html
	
	treated alaska places:
	-locality					borough/census area				restaurant ban?		year eff		bar ban?		year eff
	----------					--------------------			---------------		---------		--------		--------
	-nunam iqua					kusilvak ca						restaurant			2000
	-barrow						north slope	borough				restaurant			2002
	-koyuk						nome ca							restaurant			2003
	-dillingham					dillingham ca					restaurant			2003				bar				2013
	-fairbanks					fairbanks						workplace only		2004
	-juneau						juneau							restaurant			2005				bar				2008
	-sitka						sitka							restaurant			2005
	-anchorage					anchorage						restaurant			2007				bar				2007
	-klawock					prince of wales-hyder ca		restaurant			2007				bar				2007
	-unalaska					aleutians west ca				restaurant			2009				bar				2009
	-haines borough				haines							restaurant			2010				bar				2010
	-petersburg (now) borough	petersburg borough				restaurant			2010				bar				2010
	-skagway borough			skagway borough					restaurant			2011				bar				2011
	-nome						nome ca							restaurant			2011				bar				2011
	-palmer						matanuska-susitna				restaurant			2013				bar				2013
	
Dunwoody, GA (workplace smoking ban implemented 2008. so n/a)
South Fulton, GA (restaurant smoking ban implemented 2018. so n/a)
Braintree, MA (workplace, restaurant, and bar smoking bans implemented 2002, but it was a CDP before so can get pop data)
Framingham, MA (workplace bans implemented 2003, restaurant and bar smoking bans implemented 2004 same day as state ban. so n/a)
Greenfield, MA (workplace, restaurant, and bar smoking bans implemented 2014, but it was a CDP before so can get pop data. so n/a)
Southbridge, MA (workplace, restaurant, and bar smoking bans implemented 2014, but it was a CDP before so can get pop data. so n/a)
Weymouth, MA (restaurant and bar smoking bans implemented 2002, but it was a CDP before so can get pop data)
Winthrop, MA (workplace, restaurant, and bar smoking bans implemented 2015, but it was a CDP before so can get pop data. so n/a)
Byram, MS (workplace, restaurant, and bar smoking bans implemented 2011)

for these cities that converted from CDPs to cities during my sample period
use the CDP pop as the city pop pre-incorporation

Dunwoody, GA
Braintree, MA
Framingham, MA
Greenfield, MA
Southbridge, MA
Weymouth, MA
Winthrop, MA
Byram, MS
*/

/* places that didn't merge for the 2000-2009 and 2010-2018:

things to deal with/check:
	1. mountainboro, al (marshall/etowah counties treatment status): 1 city in marshall county becomes treated during sample period
			marshall and etowah counties both in BRFSS every year of sample--it's fine bc county pop comes from a different file
	2. petersburg, ak (petersburg treated + weird definition/boundary changes): NOT in BRFSS
	3. honolulu, hi (honolulu/urban honolulu thing): consolidated city-county govt so it's fine
	4. spencer mountain, nc (what happened to it): per wikipedia, there were 2 residents left in 2015, so NC legislature introduced a bill to suspend the town's charter until more people lived in the town
	5. arlington, va: untreated so it's fine
	6. columbia, va: dissolved in 2016
	7. edna bay, ak (part of the census area/borough annexing/reorganizing etc.) NOT in BRFSS
	8. whale pass, ak (part of the census area/borough annexing/reorganizing etc.) NOT in BRFSS
	9. braintree, ma (need to get pop figures bc technically treated before state ban)
	10. weymouth, ma (need to get pop figures bc technically treated before state ban)



city			state			notes
-----			-------			--------
Mountainboro	Alabama			untreated @ city + county (marshall) level. annexed by boaz (also untreated). only issue = boaz spans marshall +
									etowah counties. need to confirm that all of marshall and etowah counties are untreated (e.g., no other cities)
									sorted out in the county pop:
									yes albertville treated and that'll get accounted for when dividing by etowah county pop which is from a 
									different file
Petersburg	Alaska				
College City	Arkansas		untreated @ city + county (lawrence) level. changed from town to city in 2005. 
Magnet Cove	Arkansas			untreated @ city + county (hot spring) level.
Macon	Georgia					untreated @ city + county (bibb) level. became consolidated city-county (macon-bibb county).
Payne	Georgia					untreated @ city + county (bibb) level. absorbed into macon-bibb county (also untreated).
Riverside	Georgia				untreated @ city + county (colquitt) level.
Honolulu	Hawaii				HI state bar + rest ban eff 11/16/2006. treated for entire sample period @ city level. hawaii has no incorporated places but a consolidated city-county . see earlier code (search "honolulu"). https://www.honolulu.gov/
Birds	Illinois				IL state bar + rest ban eff 01/01/2008. untreated @ city + county (lawrence) level. disincorporated in 2009.
Garden Prairie	Illinois		IL state bar + rest ban eff 01/01/2008. untreated @ city + county (boone) level. incorporated, disincorporated 
									and redefined as a township, maybe reinc?
Whiteash	Illinois			IL state bar + rest ban eff 01/01/2008. untreated @ city + county (williamson) level. dissolved as a village and 
									redefined as a CDP in 2015
Fredericksburg	Indiana			IN state rest ban eff 07/01/2012. untreated @ city + county (washington) level. disincorporated in 2012.
Center Junction	Iowa			IA state bar + rest ban eff 07/01/2008. untreated @ city + county (jones) level. disincorporated in 2015.
Millville	Iowa				IA state bar + rest ban eff 07/01/2008. untreated @ city + county (clayton) level. disincorporated in 2014.
Mount Sterling	Iowa			IA state bar + rest ban eff 07/01/2008. untreated @ city + county (van buren) level. disincorporated in 2012.
Mount Union	Iowa				IA state bar + rest ban eff 07/01/2008. untreated @ city + county (henry) level. disincorporated in 2016.
Treece	Kansas					KS state bar + rest ban eff 07/01/2010. untreated @ city + county (cherokee) level. disincorporated in 2012.
Lone Oak	Kentucky			untreated @ city + county (mccracken) level. disincorporated in 2008.
Wallins Creek	Kentucky		untreated @ city + county (harlan) level. disincorporated sometime after 2010.
Water Valley	Kentucky		untreated @ city + county (graves) level. disincorporated in 2015.
Ronneby	Minnesota				MN state bar + rest ban eff 10/01/2007 so no problem. annexed by maywood township in 2009. untreated @ city + 
									county (benton) level.
Tenney	Minnesota				MN state bar + rest ban eff 10/01/2007 so no problem. annexed by campbell township in 2011. untreated @ city + 
									county (wilkin) level.
Thomson	Minnesota				MN state bar + rest ban eff 10/01/2007. merged w/carlton city in 2015. AND carlton county smoking ban eff
									06/01/2007 so no problem
Bradleyville	Missouri		untreated @ city + county (taney) level. incorporated in 2002 and disincorporated in 2009.
Burgess	Missouri				untreated @ city + county (barton) level. 
Climax Springs	Missouri		untreated @ city + county (camden) level. annexed by union township in 2008 (benton county). benton + union
									township untreated. all incorporated places in benton + camden counties are untreated
Goss	Missouri				untreated @ city + county (monroe) level. incorporated in 2001 and inactive now
Lakeside	Missouri			untreated @ city + county (miller) level. no longer active place as of 2009.
La Tour	Missouri				untreated @ city + county (johnson) level. disincorporated in 2009.
Macks Creek	Missouri			untreated @ city + county (camden) level. disincorporated in 2012.
Pinhook	Missouri				untreated @ city + county (mississippi) level. became inactive in 2013.			
Quitman	Missouri				treated @ city level in 2017 after sample period, untreated @ county (nodaway) level. disincorporated in 2012.
Rayville	Missouri			untreated @ city + county (ray) level. disincorporated in 2012.
St. George	Missouri			untreated @ city level. restaurants treated @ county (st. louis) level in 2011 so no problem. disincorporated in
									2011.
Silver Creek	Missouri		untreated @ city + county (newton) level. merged into joplin city in 2013. used to be part of shoal creek
									township in 2013. joplin + shoal creek also untreated.
Vinita Terrace	Missouri		untreated @ city level. restaurants treated @ county (st. louis) level in 2011 so no problem. annexed by university
									township as a result of redistricting in 2002 (also untreated).
Zalma	Missouri				untreated @ city + county (bollinger) level. currently unincorporated unclear why in 2000-2009
Seneca	Nebraska				NE state bar + rest ban eff 06/01/2009. untreated @ city + county (thomas) level. disincorporated in 2014.
Altmar	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem. redefined as a CDP in 2013. 
									untreated @ city + county (oswego) level. 
Barneveld	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Bridgewater	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
East Randolph	New York		NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Edwards	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Forestville	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Hermon	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Herrings	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Keeseville	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Limestone	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Lyons	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Macedon	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Perrysburg	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Pike	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Port Henry	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Prospect	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Randolph	New York			NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Salem	New York				NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Seneca Falls	New York		NY state bar + rest ban eff 07/24/2003 before sample period so no problem.
Centerville	North Carolina		NC state bar + rest ban eff 01/02/2010. untreated @ city + county (franklin) level. 
									disincorporated in 2017/redefined as CDP.
Spencer Mountain	North Carolina	NC state bar + rest ban eff 01/02/2010. untreated @ city + county (gaston) level. not matching bc legislature 
									introduced a bill suspending the town charter until the town repopulated (had 2 people in 2015)
									https://en.wikipedia.org/wiki/Spencer_Mountain,_North_Carolina
Cherry Fork	Ohio				OH state bar + rest ban eff 12/07/2006. untreated @ city + county (adams) level. disincorporated in 2014 so np
Fort Shawnee	Ohio			OH state bar + rest ban eff 12/07/2006. untreated @ city + county (allen) disincorporated 2012 so no problem
Orient	Ohio					OH state bar + rest ban eff 12/07/2006. untreated @ city + county (pickaway) level. redefined as CDP in 2015.
St. Martin	Ohio				OH state bar + rest ban eff 12/07/2006. untreated @ city + county (brown) level disincorporated 2011 so np
Salesville	Ohio				OH state bar + rest ban eff 12/07/2006. untreated @ city + county (guernsey) level. disincorporated 2016 so np
Somerville	Ohio				OH state bar + rest ban eff 12/07/2006. untreated @ city + county (butler) level. disincorporated 
									2016/merged in milford township (untreated)
Uniopolis	Ohio				OH state bar + rest ban eff 12/07/2006. untreated @ city + county (auglaize) level. disincorporated into 
									union township 2013
Avard	Oklahoma				untreated @ city + county (woods) level. disincorporated in 2010.
Capron	Oklahoma				untreated @ city + county (woods) level. deactivated in 2010.
Cardin	Oklahoma				untreated @ city + county (ottawa) level. deactivated in 2012.
Picher	Oklahoma				untreated @ city + county (ottawa) level. deactivated in 2012.
Shady Grove	Oklahoma			untreated @ city + county (pawnee) level. disincorporated in 2006.
Shamrock	Oklahoma			untreated @ city + county (creek) level. deactivated in 2013.
Damascus	Oregon				OR state bar + rest ban eff 01/01/2009. untreated @ city + county (clackamas) level. incorporated in 2004. 
									disincorporation vote in 2016, finalized 2020
Lumber City	Pennsylvania		untreated @ city + county (clearfield) level. fips code 45448. dissolved in 2014. 
Strausstown	Pennsylvania		untreated @ city + county (berks) level. merged w/upper tulpehocken township in 2016 (untreated).
Roswell	South Dakota			SD state bar + rest ban eff 11/10/2010. untreated @ city + county (miner) level. disincorporated and 
									merged into roswell township 2012
Iron City	Tennessee			untreated @ city + counties (lawrence + wayne) level. disincorporated in 2010 and redefined as a CDP in 2011. all 
									incorporated places in lawrence + wayne counties = untreated
Lakewood	Tennessee			untreated @ city + county (davidson) level. disincorporated in 2011 and added to nashville-davidson metro govt 
									(untreated)
Ophir	Utah					UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (tooele) level. 
									disincorporated in 2016 and redefined as a CDP.
Sunnyside	Utah				UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (carbon) level. merged 
									w/east carbon in 2013 (untreated).
Cabot	Vermont					VT state bar + rest ban eff 09/01/2005. untreated @ city + county (washington) level. disincorporated in 2010.
Northfield	Vermont				VT state bar + rest ban eff 09/01/2005. untreated @ city + county (washington) level. disincorporated + redefined 
									as a CDP in 2014.
North Westminster	Vermont		VT state bar + rest ban eff 09/01/2005. untreated @ city + county (windham) level. disincorporated in 2010 + 
									redefined as a CDP in 2012.
Arlington	Virginia			untreated @ city/county (arlington county coextensive w/Arlington CDP) level. not in 2010-2018 file
Columbia	Virginia			untreated @ city + county (fluvanna) level. disincorporated in 2016. 
									https://en.wikipedia.org/wiki/Columbia,_Virginia
Silver Lake	Wisconsin			WI state bar + rest ban eff 07/05/2010. untreated @ city + county (kenosha) level. merged with towns of salem, 
									trevor, camp lake, and wilmot to make salem lakes in 2017 (all untreated).

---------------- 2010-2018 only below ----------------------------------

Perdido Beach	Alabama			untreated @ city + county (baldwin) level. incorporated in 2009.
Semmes	Alabama					untreated @ city + county (mobile) level. incorporated in 2011.
Edna Bay	Alaska				untreated @ city + county (prince of wales-hyder ca/prince of wales-outer ketchikan ca) level. annexed into 
									prince of wales-hyder ca in 2008. unsure why not matching
Whale Pass	Alaska				untreated @ city + county (prince of wales-hyder ca/prince of wales-outer ketchikan ca) level. annexed into 
									prince of wales-hyder ca in 2008. unsure why not matching
Tusayan	Arizona					untreated @ city level. coconino county rest ban eff 2/3/2004. AZ state bar + rest ban eff 05/01/2007. 
									incorporated in 2010.
Southside	Arkansas			untreated @ city + county (independence) level. incorporated in 2014.
Eastvale	California			CA state bar + rest ban eff 01/01/1998. incorporated in 2010. untreated @ city level. riverside county bar + rest 
									ban eff 2/23/17.
Jurupa Valley	California		CA state bar + rest ban eff 01/01/1998. incorporated in 2011. untreated @ city level. riverside county bar + rest 
									ban eff 2/23/17.
Estero	Florida					FL state rest ban eff 07/01/2003. incorporated in 2015. untreated @ city + county (lee) level.
Indiantown	Florida				FL state rest ban eff 07/01/2003. incorporated in 2017. untreated @ city + county (martin) level.
Westlake	Florida				FL state rest ban eff 07/01/2003. incorporated in 2016. untreated @ city + county (palm beach) level.
Brookhaven	Georgia				untreated @ city + county (dekalb) level (dekalb has workplace-only ban). incorporated 12/17/2012. 
Dunwoody	Georgia				untreated @ city + county (dekalb) level (dunwoody + dekalb both have workplace-only ban). incorporated in 2008.
Echols County consolidated government	Georgia	untreated @ county (echols) level no incorporated municipalities in the county...
Macon-Bibb County	Georgia		untreated @ city-ish (macon) + county (bibb) level. consolidated from macon city and bibb county in 2014.
Peachtree Corners	Georgia		untreated @ city + county (gwinnett) level. incorporated in 2012.
South Fulton	Georgia			rest ban eff 2/27/18. untreated @ county (fulton) level. incorporated 2016/2017.
Stonecrest	Georgia				untreated @ city + county (dekalb) level. incorporated in 2016/2017.
Tucker	Georgia					untreated @ city + county (dekalb) level. incorporated in 2015/2016.
Urban Honolulu	Hawaii			city/county level (honolulu) rest ban eff 07/01/2003. HI state bar + rest ban eff 11/16/2006.
St. Rose	Illinois			IL state bar + rest ban eff 01/01/2008. incorporated in 2016. untreated @ city + county (clinton) level.
Greeley County unified government (balance)	Kansas	KS state bar + rest ban eff 07/01/2010. consolidated govt in 2009. all incorporated places in greeley county = untreated
Sanford	Maine					ME state bar + rest ban eff 01/01/2004. incorporated in 2013. untreated @ city + county (york) level.
Amesbury Town	Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. untreated @ city + county (essex) level.
Braintree Town	Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. city bar + rest ban eff 01/01/2002. untreated @
									 county (norfolk) level.
Framingham	Massachusetts		MA state bar + rest ban eff 07/05/2004. incorporated in 2018. city bar + rest ban eff 07/05/2004. untreated @ 
									county (middlesex) level.
Greenfield Town	Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. city bar + rest ban eff 04/01/2014. untreated @ 
									county (franklin) level.
Palmer Town	Massachusetts		MA state bar + rest ban eff 07/05/2004. incorporated in 2009. untreated @ city + county (hampden) level.
Southbridge Town Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. city bar + rest ban eff 03/20/2014. untreated @ 
									county (worcester) level.
Weymouth Town	Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. city bar + rest ban eff 01/02/2002. untreated @ 
									county (norfolk) level.
Winthrop Town	Massachusetts	MA state bar + rest ban eff 07/05/2004. incorporated in 2009. city bar + rest ban eff 06/01/2015. untreated @ 
									county (suffolk) level.
Rice Lake	Minnesota			MN state bar + rest ban eff 10/01/2007. incorporated in 2015. untreated @ city + county (st. louis) level.
Byram	Mississippi				city bar + rest ban eff 12/10/2011. untreated @ county (hinds) level. incorporated in 2009.
Diamondhead	Mississippi			city rest ban eff 01/01/2016. untreated @ county (hancock) level. incorporated in 2012.
Charmwood	Missouri			untreated @ city + county (franklin) level. incorporated in 2011.
Jane	Missouri				untreated @ city + county (mcdonald) level. reincorporated in 2005.
Lake Tekakwitha	Missouri		untreated @ city + county (jefferson) level. incorporated in 2009.
Peaceful Village	Missouri	untreated @ city + county (jefferson) level. incorporated in 2008.
Anthony	New Mexico				NM state bar + rest ban eff 06/15/2007. incorporated in 2010. untreated @ city level. bar + rest ban eff @ county 
									(dona ana) level 02/08/2002.
Kirtland	New Mexico			NM state bar + rest ban eff 06/15/2007. incorporated in 2015. untreated @ city + county (san juan) level.
Rio Communities	New Mexico		NM state bar + rest ban eff 06/15/2007. incorporated in 2013. untreated @ city + county (valencia) level.
Archer Lodge	North Carolina	NC state bar + rest ban eff 01/02/2010. incorporated in 2009. untreated @ city + county (johnston) level.
Fontana Dam	North Carolina		NC state bar + rest ban eff 01/02/2010. incorporated in 2011. untreated @ city + county (graham) level.
Carlton Landing	Oklahoma		untreated @ city + county (pittsburg) level. incorporated in 2013. 
James Island	South Carolina	untreated @ city level. bar + rest ban eff @ county (charleston) level 10/04/2012. incorporated 05/17/2012.
Van Wyck	South Carolina		untreated @ city level. bar + rest ban eff @ county (lancaster) level 03/01/2013. incorporated in 2017. 
Brant Lake	South Dakota		SD state bar + rest ban eff 11/10/2010. incorporated in 2016. untreated @ city + county (lake) level.
Buffalo Chip	South Dakota	SD state bar + rest ban eff 11/10/2010. "incorporated" in 2015 but judge ruled in 2019 that it was invalid. 
									untreated @ city + county (meade) level.
Coupland	Texas				untreated @ city + county (williamson) level. incorporated in 2012.
Coyote Flats	Texas			untreated @ city + county (johnson) level. incorporated in 2010.
Ivanhoe	Texas					ivanhoe + ivanhoe north both untreated @ city + county (tyler) level. incorporated in 2009, merged w/ivanoe north 
									city in 2010. 
Kingsbury	Texas				untreated @ city + county (guadalupe) level. incorporated in 2015.
Plantersville	Texas			untreated @ city + county (grimes) level. incorporated in 2017.
Providence Village	Texas		untreated @ city + county (denton) level. incorporated in 2010.
Sandy Oaks	Texas				untreated @ city + county (bexar) level. incorporated in 2014.
Sandy Point	Texas				untreated @ city + county (brazoria) level. incorporated in 2002 but not reported until 2012.
San Elizario	Texas			untreated @ city + county (el paso) level. incorporated in 2013.
Spring Branch	Texas			untreated @ city + county (comal) level. incorporated in 2015.
Staples	Texas					untreated @ city + county (guadalupe) level. incorporated in 2010.
Cedar Highlands	Utah			UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (iron) level. incorporated 
									in 2018 and dissolved in 2020.
Dutch John	Utah				UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (daggett) level. 
									incorporated in 2014 eff 2016.
Interlaken	Utah				UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (wasatch) level. 
									incorporated in 2015.
Millcreek	Utah				UT state rest ban eff 01/01/1995 + bar ban eff 01/01/2009. untreated @ city + county (salt lake) level. 
									incorporated in 2016.
Bloomfield	Wisconsin			WI state bar + rest ban eff 07/05/2010. untreated @ city + county (walworth) level. incorporated 12/20/2011.
Bristol	Wisconsin				WI state bar + rest ban eff 07/05/2010. untreated @ city + county (kenosha) level. incorporated in 2009.
Fox Crossing	Wisconsin		WI state bar + rest ban eff 07/05/2010. fox crossing + menasha untreated @ city level. bar + rest ban eff @ 
									county (winnebago) level 07/05/2010. incorporated in 2016 formerly the town of menasha.
Harrison	Wisconsin			WI state bar + rest ban eff 07/05/2010. incorporated in 2013 and formed from part of harrison town in calumet 
									county + part of buchanan town in outagamie county. untreated @ cities + counties (calumet + buchanan) level.
Maine	Wisconsin				WI state bar + rest ban eff 07/05/2010. untreated @ city + county (marathon) level. incorporated in 2015.
Salem Lakes	Wisconsin			WI state bar + rest ban eff 07/05/2010. untreated @ city + county (kenosha) level. incorporated in 2017 (a bunch 
									of cities merged and became salem lakes--see note for silver lake)
Somers	Wisconsin				WI state bar + rest ban eff 07/05/2010. untreated @ city + county (kenosha) level. incorporated in 2015.
Summit	Wisconsin				WI state bar + rest ban eff 07/05/2010. untreated @ city + county (waukesha) level. incorporated in 2010.
Windsor	Wisconsin				WI state bar + rest ban eff 07/05/2010. untreated @ city level. bar + rest ban eff @ county (dane) level 
									08/15/2009. incorporated in 2015.
*/


*rename the geography variables to be consistent across datasets
ren state fips_state_code
ren place fips_place_code

*rename pop base variable to be consistent with my naming conventions
ren popbase_2000 pop_base_2000

*only keep the variables you need
keep sumlev fips_state_code fips_place_code city statename pop_* flag_post_2000

save "$build_data/census_incorporated_place_pop_est_2000_2009_clean.dta", replace


*** 2010-2018 Incorporated Places Population Estimates file ***
*https://www.census.gov/data/tables/time-series/demo/popest/2010s-total-cities-and-towns.html

*import the raw data (csv file) and save it as a .dta file
import delimited "$build_data/census_incorporated_place_pop_est_2010_2018.csv", rowrange(3) clear

*split the geoid2 variable into the state fips code and the fips place code
*to split up the variable I need to convert it from numeric to string and then count the characters (substring takes a piece of the string)
*the "%07.0f" makes the string variable be in a 7-digit format, so for states with fips codes < 10, it makes them 01, 02, etc. so it works
*-7 means 7 characters from the end (+7 means 7 characters from the beginning)
gen state = substr(string(geoid2, "%07.0f"),-7,2)
gen place = substr(string(geoid2, "%07.0f"),-5,5)
*now destring the variables!
destring state, replace
destring place, replace

*split the geodisplaylabel variable into the incorporated place name and the state name
split geodisplaylabel, parse(", ")
*rename place name and state name
ren geodisplaylabel1 name
ren geodisplaylabel2 statename

*check to see if it worked
tab statename


*change some city names by hand to be consistent with other data

*it's called Islamorada, Village of Islands
*https://www.islamorada.fl.us/
replace name = "Islamorada, Village of Islands village" if geodisplaylabel == "Islamorada, Village of Islands village; Florida"
replace statename = "Florida" if geodisplaylabel == "Islamorada, Village of Islands village; Florida"


replace name = "Lynchburg, Moore County metropolitan government" if geodisplaylabel == "Lynchburg, Moore County metropolitan government; Tennessee"
replace statename = "Tennessee" if geodisplaylabel == "Lynchburg, Moore County metropolitan government; Tennessee"


*now check to see if there are any weird names left
tab statename

*make an indicator variable for "formed/incorporated after the 2010 census"
*https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2018/sub-est2018.pdf
gen flag_post_2010 = 0
replace flag_post_2010 = 1 if rescen42010 == "(X)"
label variable flag_post_2010 "=1 if formed post-2010-Census"

*make a variable for destrung census population estimates
gen pop_census_2010 = rescen42010
replace pop_census_2010 = "" if flag_post_2010 == 1
destring pop_census_2010, replace

*now make the names just the city name (no town, city, cdp, etc.)
split name, parse(" town")
split name1, parse(" city")
split name11, parse(" CDP")
split name111, parse(" borough")
split name1111, parse(" village")
split name11111, parse(" municipality")
split name111111, parse(" UT")

ren name1111111 city
drop name*

*change some city names (and place codes as needed) by hand to be consistent with other data

*alaska
*change utqiagvik, ak to barrow, ak (name changed in 2016 and i'm using the name that was in effect in my sample period)
*change place code too
*https://en.wikipedia.org/wiki/Utqiagvik,_Alaska
replace place = 5200 if city == "Utqiagvik" & statename == "Alaska"
replace city = "Barrow" if city == "Utqiagvik" & statename == "Alaska"

replace city = "Raymer" if city == "Raymer (New Raymer)" & statename == "Colorado"

*bellerive, mo voted to change name to bellerive acres in 2016, after sample period. changing name back to bellerive to be consistent w end of sample
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2398078,City%20of%20Bellerive%20Acres
*https://en.wikipedia.org/wiki/Bellerive,_Missouri
replace place = 4240 if place == 4248 & state == 29
replace city = "Bellerive" if place == 4240 & state == 29

replace city = "Parkers Crossroads" if city == "Parker's Crossroads" & statename == "Tennessee"

*rename the population variables to be consistent across decades/datasets
forvalues i = 2010(1)2018 {
	ren respop7`i' pop_`i'
	}
ren resbase42010 pop_base_2010
	
*rename the geography variables to be consistent across datasets
ren state fips_state_code
ren place fips_place_code

*only keep the variables you need
keep fips_state_code fips_place_code city statename pop_* flag_post_2010

save "$build_data/census_incorporated_place_pop_est_2010_2018_clean.dta", replace


*** merge 2000-2009 and 2010-2018 incorporated place population estimates ***
use "$build_data/census_incorporated_place_pop_est_2000_2009_clean.dta", clear

merge 1:1 fips_state_code fips_place_code city statename using "$build_data/census_incorporated_place_pop_est_2010_2018_clean.dta"
drop _merge

save "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v1.dta", replace

*https://www.census.gov/programs-surveys/bas/information/cdp.html


* export the cities that I have to make special adjustments to (the ones that incorporated during my sample period AND implemented bar/restaurant bans by the end of my sample period)
preserve

keep if statename == "Massachusetts" | statename == "Mississippi"
drop if statename == "Mississippi" & city != "Byram"
keep if statename != "Massachusetts" | (statename == "Massachusetts" & city == "Braintree Town") | (statename == "Massachusetts" & city == "Weymouth Town")

export excel using "$build_data/smoking_ban_city_pop_projections", sheetreplace firstrow(variables)

restore

* clean the subcounty population estimates files to get pop estimates by county for cities that span multiple counties
*** 2000-2010 Subcounty Population Estimates file ***
*https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/cities/
*import the raw data (csv file)
import delimited "$build_data/census_subcounty_pop_est_2000_2010.csv", encoding(ISO-8859-2) clear

*make an indicator variable for (pt.) in the name (those are parts of the place, e.g. if a city spans multiple counties they have the city pop in 1 row and then the pop separated by counties in multiple other rows)
gen flag_pt = strmatch(name, "*(pt.)*")
label variable flag_pt "=1 if (pt.) in name"

*make an indicator variable for "formed/incorporated after the 2000 census"
*https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2000-2009/sub-est2009.pdf
gen flag_post_2000 = 0
replace flag_post_2000 = 1 if census2000pop == "X"
label variable flag_post_2000 "=1 if formed post-2000-Census"

*now make the names just the city name (no town, city, cdp, etc.)
split name, parse(" town")
split name1, parse(" city")
split name11, parse(" CDP")
split name111, parse(" borough")
split name1111, parse(" village")
split name11111, parse(" municipality")
split name111111, parse(" UT")

ren name1111111 city
drop name*

*change some city names by hand to be consistent with other data
*https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.html

*https://en.wikipedia.org/wiki/Castle_Pines_(city),_Colorado
*Castle Pines North changed name to Castle Pines in 2010
*Castle Pines CDP changed name to Castle Pines Village CDP in 2010
replace place = 12387 if city == "Castle Pines North" & stname == "Colorado"
replace city = "Castle Pines" if city == "Castle Pines North" & stname == "Colorado"
replace city = "DeFuniak Springs" if city == "De Funiak Springs" & stname == "Florida"
*https://en.wikipedia.org/wiki/Ocean_Breeze,_Florida
*Ocean Breeze Park changed name to Ocean Breeze in 2012
replace place = 50875 if city == "Ocean Breeze Park" & stname == "Florida"
replace city = "Ocean Breeze" if city == "Ocean Breeze Park" & stname == "Florida"
*https://en.wikipedia.org/wiki/McRae%E2%80%93Helena,_Georgia
*McRae and Helena merged to become McRae-Helena in 2015--so after my smoking bans sample period...
replace city = "Old Town" if city == "Oldtown" & stname == "Illinois"
replace city = "Balance of Old Town" if city == "Balance of Oldtown" & stname == "Illinois"
*https://en.wikipedia.org/wiki/Fillmore_Township,_Montgomery_County,_Illinois
*Fillmore and South Fillmore merged to become Fillmore Consolidated Township in 2016--so after my smoking bans sample period...
replace city = "DeWitt" if city == "De Witt" & stname == "Iowa"
replace city = "LaSalle Parish" if city == "La Salle Parish" & stname == "Louisiana"
replace city = "Balance of LaSalle Parish" if city == "Balance of La Salle Parish" & stname == "Louisiana"
replace city = "Grayling charter" if city == "Grayling" & stname == "Michigan"
replace city = "Española" if city == "Espanola" & stname == "New Mexico"
replace city = "Tuscarora Nation Reservation" if city == "Tuscarora Reservation" & stname == "New York"
replace city = "Harriet-Lein" if city == "Harriet-Lien" & stname == "North Dakota"
replace place = 850 if sumlev == 162 & city == "Alburg" & stname == "Vermont"
replace city = "Alburgh" if city == "Alburg" & stname == "Vermont"
replace cousub = 860 if city == "Balance of Alburg" & stname == "Vermont"
replace city = "Balance of Alburgh" if city == "Balance of Alburg" & stname == "Vermont"
replace cousub = 24050 if city == "Balance of Enosburg" & stname == "Vermont"
replace city = "Balance of Enosburgh" if city == "Balance of Enosburg" & stname == "Vermont"
replace cousub = 24050 if city == "Enosburg" & stname == "Vermont"
replace city = "Enosburgh" if city == "Enosburg" & stname == "Vermont"
replace city = "Poy Sippi" if city == "Poysippi" & stname == "Wisconsin"

*make a variable that facilitates cross-census merging for flag_pt
*some cities appear to have been split into multiple counties post-2010 census, so flag_pt = 0 for the 2000s pop estimates but it = 1 for the 2010s pop estimates and vice versa
gen flag_pt_merge = flag_pt
replace flag_pt_merge = 1 if city == "Trafford" & county == 73 & stname == "Alabama"
replace flag_pt_merge = 1 if city == "Lavonia" & county == 119 & stname == "Georgia"
replace flag_pt_merge = 1 if city == "Crete" & county == 197 & stname == "Illinois"
replace flag_pt_merge = 1 if city == "Benson" & county == 101 & stname == "North Carolina"
replace flag_pt_merge = 1 if city == "Maysville" & county == 49 & stname == "Oklahoma"
replace flag_pt_merge = 1 if city == "Springtown" & county == 367 & stname == "Texas"

save "$build_data/census_subcounty_pop_est_2000_2010_clean.dta", replace

*** 2010-2018 Subcounty Population Estimates file ***
*https://www.census.gov/data/tables/time-series/demo/popest/2010s-total-cities-and-towns.html
*import the raw data (csv file)
import delimited "$build_data/census_subcounty_pop_est_2010_2018.csv", encoding(ISO-8859-2) clear

*make an indicator variable for (pt.) in the name (those are parts of the place, e.g. if a city spans multiple counties they have the city pop in 1 row and then the pop separated by counties in multiple other rows)
gen flag_pt = strmatch(name, "*(pt.)*")
label variable flag_pt "=1 if (pt.) in name"

*make an indicator variable for "formed/incorporated after the 2010 census"
*https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2018/sub-est2018.pdf
gen flag_post_2010 = 0
replace flag_post_2010 = 1 if census2010pop == "A"
label variable flag_post_2010 "=1 if formed post-2010-Census"

*now make the names just the city name (no town, city, cdp, etc.)
split name, parse(" town")
split name1, parse(" city")
split name11, parse(" CDP")
split name111, parse(" borough")
split name1111, parse(" village")
split name11111, parse(" municipality")
split name111111, parse(" UT")

ren name1111111 city
drop name*

*change some city names by hand to be consistent with other data
*change oglala lakota county, sd to shannon county, sd and kusilvak census area, ak to wade hampton census area, ak (names changed in 2015 and using names that were in effect at the end of my sample period)
*https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.html
replace city = "Balance of Wade Hampton Census Area" if city == "Balance of Kusilvak Census Area" & stname == "Alaska"
replace city = "Wade Hampton Census Area" if city == "Kusilvak Census Area" & stname == "Alaska"
*changing county code for Wade Hampton Census Area/Kusilvak Census Area from 158 to 270 to be consistent across decades
replace county = 270 if county == 158 & stname == "Alaska"
*change utqiagvik, ak to barrow, ak (name changed in 2016 and i'm using the name that was in effect in my sample period)
*change place code too
*https://en.wikipedia.org/wiki/Utqiagvik,_Alaska
replace place = 5200 if city == "Utqiagvik" & stname == "Alaska"
replace city = "Barrow" if city == "Utqiagvik" & stname == "Alaska"
replace place = 36550 if city == "Kachemak" & stname == "Alaska"
*kake and port alexander, alaska used to be in the wrangell-petersburg census area (now it appears to be in the prince of wales-hyder census area per wikipedia) so changing county code to be consistent across decades
*https://ready.alaska.gov/SEOC/EAS_Plan_Acrobat/EAS_Appendix_K.pdf
replace county = 195 if county == 198 & city == "Kake" & stname == "Alaska"
replace county = 195 if county == 198 & city == "Port Alexander" & stname == "Alaska"

replace city = "Española" if city == "Espańola" & stname == "New Mexico"

replace city = "Balance of Shannon County" if city == "Balance of Oglala Lakota County" & stname == "South Dakota"
replace city = "Shannon County" if city == "Oglala Lakota County" & stname == "South Dakota"
*changing county code for Shannon County/Oglala Lakota County from 102 to 113 to be consistent across decades
replace county = 113 if county == 102 & stname == "South Dakota"

*make a variable that facilitates cross-census merging for flag_pt
*some cities appear to have been split into multiple counties post-2010 census, so flag_pt = 0 for the 2000s pop estimates but it = 1 for the 2010s pop estimates and vice versa
gen flag_pt_merge = flag_pt
replace flag_pt_merge = 1 if city == "Arlington Heights" & county == 31 & stname == "Illinois"
replace flag_pt_merge = 1 if city == "Palatine" & county == 31 & stname == "Illinois"
replace flag_pt_merge = 1 if city == "Willow Springs" & county == 31 & stname == "Illinois"
replace flag_pt_merge = 1 if city == "Forest" & county == 65 & stname == "Ohio"
replace flag_pt_merge = 1 if city == "Gordonsville" & county == 137 & stname == "Virginia"

save "$build_data/census_subcounty_pop_est_2010_2018_clean.dta", replace

*** merge and clean the subcounty population estimates ***

use "$build_data/census_subcounty_pop_est_2000_2010_clean.dta", clear

merge 1:1 sumlev state county place cousub city stname flag_pt_merge using "$build_data/census_subcounty_pop_est_2010_2018_clean.dta"
sort state city county

*make variables for destrung census population estimates
gen pop_census_2000 = census2000pop
replace pop_census_2000 = "" if flag_post_2000 == 1
destring pop_census_2000, replace
gen pop_census_2010 = census2010pop
replace pop_census_2010 = "" if flag_post_2010 == 1
destring pop_census_2010, replace

sort stname city county place

*rename variables to be consistent with incorporated place dataset
ren state fips_state_code
ren county fips_county_code
ren place fips_place_code
ren stname statename
ren estimatesbase2000 pop_base_2000
forvalues i = 2000(1)2009 {
	ren popestimate07`i' pop_`i'
	}
ren estimatesbase2010 pop_base_2010
forvalues i = 2010(1)2018 {
	ren popestimate`i' pop_`i'
	}

	
* check unmatched places
preserve
keep if _merge != 3
forvalues i = 1(1)56 {
	disp "state equals `i'"
	tab city _merge if fips_state_code == `i' & flag_post_2010 != 1
	}
restore


drop _merge

*3 reservations in ny state need a county subdivision code in place of a fips place code in order to properly merge with the ansi county codes data
replace fips_place_code = cousub if fips_state_code == 36 & (city == "Cattaraugus Reservation" | city == "Oil Springs Reservation" | city == "Tonawanda Reservation")


*save the subcounty population estimates
save "$build_data/census_subcounty_pop_est_2000_2018_clean.dta", replace

*save the places that incorporated after 2000 and so aren't in both decades of census incorporated place data
preserve
keep if statename == "Massachusetts" | statename == "Mississippi"
*keep the cities you need
keep if city == "Braintree Town" | city == "Weymouth Town" | city == "Byram"
*only need 1 observation per city (sumlev 162 is the incorporated place value--all the pop estimates are the same so it doesn't really matter which one i use, just being consistent)
keep if sumlev == 162
*only keep the variables i need
keep sumlev fips_state_code fips_place_code statename city pop_* flag_*
*don't need the flag for (pt.)
drop flag_pt

save "$build_data/incorporated_places_post-2000-census_pop_estimates_2000_2018.dta", replace

restore


/*places that are ok not matching

*Lake View, AL
*Trafford, AL
*Trinity, AL

*Petersburg not in BRFSS
per Census website (url above)
Petersburg Borough, Alaska (02-195):
Created from part of former Petersburg Census Area (02-195) and part of Hoonah-Angoon Census Area (02-105) effective January 3, 2013 estimated population 3,203.

*College City, AR merged with Walnut Ridge in 2017
https://en.wikipedia.org/wiki/College_City,_Arkansas

Magnet Cove, AR's incorporation as a city was suspended in 2006 :O
https://en.wikipedia.org/wiki/Magnet_Cove,_Arkansas

*Timnath, CO

Chattahoochee Hills, GA incorporated in 2007 so not sure why it's not in the 2000-2010 file...
http://www.chatthillshistory.com/

parts of lavonia, ga match in the merge, but there's 1 part remaining in a different county (code 147) with 0 population that's only in the 2010-2018 file... weird parts!! (pt.)

city of Macon and Bibb County, GA consolidated in 2012
https://en.wikipedia.org/wiki/Macon,_Georgia

Payne was abolished in 2015 and before that was completely surrounded by Macon
https://en.wikipedia.org/wiki/Payne,_Georgia

Peachtree Corners, GA incorporated in 2012

parts of ray city, ga match in the merge, but there's 1 part remaining in a different county (code 173) with a very small population that's only in the 2010-2018 file

*https://en.wikipedia.org/wiki/McRae%E2%80%93Helena,_Georgia
*McRae and Helena merged to become McRae-Helena in 2015--so after my smoking bans sample period...

*Roswell, GA

*Honolulu, HI

*https://en.wikipedia.org/wiki/Fillmore_Township,_Montgomery_County,_Illinois
*Fillmore and South Fillmore merged to become Fillmore Consolidated Township in 2016--so after my smoking bans sample period...
*/


*** now get population info for counties that only have non-incorporated places ***
use "$build_data/census_subcounty_pop_est_2000_2018_clean.dta", clear

keep if city == "Kalawao County" | city == "James City County" | city == "Powhatan County"

gen county_name = city

keep sumlev fips_state_code fips_county_code fips_place_code statename county_name city pop_* flag_* funcstat

save "$build_data/census_non_ip_counties_pop_est_2000_2018_clean.dta", replace


*** create corrected population estimates for cities that span multiple counties (using the subcounty file, which has estimates broken down by city AND county)

*first get a list of all the cities that span multiple counties
use "$build_data/city-county_pairs.dta", clear
keep if mult_county == 1

*collierville, tn is only in shelby county, but the ansi file incorrectly lists it as being in both shelby and fayette counties (it borders fayette county)--fix
*https://geonames.usgs.gov/apex/f?p=138:3:10148539361779::NO:3:P3_FID,P3_TITLE:2406295,Town%20of%20Collierville
*https://en.wikipedia.org/wiki/Collierville,_Tennessee
drop if city == "Collierville" & fips_state_code == 47 & county_name == "Fayette County"

*now drop the county subdivisions that are "fictious entities" created by the census and duplicates of city-county-state observations

*first sort by state, city, county, and functional status
*why functional status? the order goes "active", "fictitious", "inactive", "statistical"--definitely want to keep all the actives so don't want to record them as the "duplicates"
sort fips_state_code city fips_county_code funcstat
by fips_state_code city fips_county_code: gen duplicate = _n

*note that the only duplicates are those with funcstat F for fictitious--don't need those!
tab funcstat duplicate, missing
*also note that the place type for these fictitious entities = county subdivision
tab place_type duplicate, missing

*now drop the duplicates!
drop if duplicate == 2
drop duplicate

sort fips_state_code city fips_county_code

save "$build_data/city-county_mult_county_pairs.dta", replace

*now merge that info into the subcounty population estimate file
use "$build_data/census_subcounty_pop_est_2000_2018_clean.dta", clear

merge m:1 fips_state_code fips_place_code fips_county_code city using "$build_data/city-county_mult_county_pairs.dta"

*they're not all merging--the "master-only" ones are fine because they are places that don't span multiple counties
*it's fine if inactive or "statistical entities" from the using don't merge
tab funcstat if _merge == 2

*greenhorn, or inactive--apparently it's a ghost town!!
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2410658,City%20of%20Greenhorn
*https://sos.oregon.gov/archives/exhibits/ghost/Pages/mining-greenhorn.aspx

*only keep the matched values (in order to "update" the pop estimates)
keep if _merge == 3
drop _merge

*don't keep the state-county-MCD-incorporated place/balance (sumlev 71)--creating lots of duplicates for merging, because lots of incorporated places that cross county boundaries also cross MCD (minor civil division) boundaries, but I don't need those pop estimates (just the city-county pairs)
drop if sumlev == 71

*only keep the variables you need
keep sumlev fips_state_code fips_county_code fips_place_code statename city pop_* flag_* funcstat

save "$build_data/census_subcounty_pop_est_mult_counties_2000_2018_clean.dta", replace


*** now merge in the newly incorporated places pop estimates ***

*the update replace options for merge update missing variable values in the master dataset with the values from the using dataset (update) and replace updates all values of variables in master with nonmissing values from using--using it here because the whole point of merging in the massachusetts/mississippi data from the county subdivision files is to get the population estimates for 2000-2009!
*only need to use "update" and not both "update" and "replace"
use "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v1.dta", clear

merge 1:1 fips_state_code fips_place_code statename city using "$build_data/incorporated_places_post-2000-census_pop_estimates_2000_2018.dta", update

drop _merge

*now merge in the city-county pair info
*note that you need to replace every mult_county pop estimates with the ones from the subcounty file because the subcounty file splits out the population for each city by county! do this several hundred rows below this line
merge 1:m fips_state_code fips_place_code city using "$build_data/city-county_pairs.dta"

sort fips_state_code city

*** for places that incorporated after the 2010 census, fill in the county info by hand... ***
gen flag_no_ansi = .
replace flag_no_ansi = 0 if _merge == 2 | _merge == 3
label variable flag_no_ansi "=1 if not in 2010 ANSI place file"

*mountainboro, al
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2406217,Town%20of%20Mountainboro%20(historical)
replace state = "AL" if city == "Mountainboro" & statename == "Alabama"
replace place_type = "Incorporated Place" if city == "Mountainboro" & statename == "Alabama"
replace mult_county = 0 if city == "Mountainboro" & statename == "Alabama"
replace county_number = 1 if city == "Mountainboro" & statename == "Alabama"
replace county_name = "Etowah County" if city == "Mountainboro" & statename == "Alabama"
replace fips_county_code = 55 if city == "Mountainboro" & statename == "Alabama"
replace flag_no_ansi = 1 if city == "Mountainboro" & statename == "Alabama"

*semmes, al
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2680031,City%20of%20Semmes
replace state = "AL" if city == "Semmes" & statename == "Alabama"
replace place_type = "Incorporated Place" if city == "Semmes" & statename == "Alabama"
replace mult_county = 0 if city == "Semmes" & statename == "Alabama"
replace county_number = 1 if city == "Semmes" & statename == "Alabama"
replace county_name = "Mobile County" if city == "Semmes" & statename == "Alabama"
replace fips_county_code = 97 if city == "Semmes" & statename == "Alabama"
replace flag_no_ansi = 1 if city == "Semmes" & statename == "Alabama"

*southside, ar
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2771128,City%20of%20Southside
replace state = "AR" if city == "Southside" & statename == "Arkansas"
replace place_type = "Incorporated Place" if city == "Southside" & statename == "Arkansas"
replace mult_county = 0 if city == "Southside" & statename == "Arkansas"
replace county_number = 1 if city == "Southside" & statename == "Arkansas"
replace county_name = "Independence County" if city == "Southside" & statename == "Arkansas"
replace fips_county_code = 63 if city == "Southside" & statename == "Arkansas"
replace flag_no_ansi = 1 if city == "Southside" & statename == "Arkansas"

*jurupa valley, ca
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2702867,City%20of%20Jurupa%20Valley
replace state = "CA" if city == "Jurupa Valley" & statename == "California"
replace place_type = "Incorporated Place" if city == "Jurupa Valley" & statename == "California"
replace mult_county = 0 if city == "Jurupa Valley" & statename == "California"
replace county_number = 1 if city == "Jurupa Valley" & statename == "California"
replace county_name = "Riverside County" if city == "Jurupa Valley" & statename == "California"
replace fips_county_code = 65 if city == "Jurupa Valley" & statename == "California"
replace flag_no_ansi = 1 if city == "Jurupa Valley" & statename == "California"

*westlake, fl
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2786554,City%20of%20Westlake
replace state = "FL" if city == "Westlake" & statename == "Florida"
replace place_type = "Incorporated Place" if city == "Westlake" & statename == "Florida"
replace mult_county = 0 if city == "Westlake" & statename == "Florida"
replace county_number = 1 if city == "Westlake" & statename == "Florida"
replace county_name = "Palm Beach County" if city == "Westlake" & statename == "Florida"
replace fips_county_code = 99 if city == "Westlake" & statename == "Florida"
replace flag_no_ansi = 1 if city == "Westlake" & statename == "Florida"

*brookhaven, ga
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2746306,City%20of%20Brookhaven
replace state = "GA" if city == "Brookhaven" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "Brookhaven" & statename == "Georgia"
replace mult_county = 0 if city == "Brookhaven" & statename == "Georgia"
replace county_number = 1 if city == "Brookhaven" & statename == "Georgia"
replace county_name = "DeKalb County" if city == "Brookhaven" & statename == "Georgia"
replace fips_county_code = 89 if city == "Brookhaven" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "Brookhaven" & statename == "Georgia"

*macon-bibb county, ga
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2761437,Macon-Bibb%20County
replace state = "GA" if city == "Macon-Bibb County" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "Macon-Bibb County" & statename == "Georgia"
replace mult_county = 0 if city == "Macon-Bibb County" & statename == "Georgia"
replace county_number = 1 if city == "Macon-Bibb County" & statename == "Georgia"
replace county_name = "Bibb County" if city == "Macon-Bibb County" & statename == "Georgia"
replace fips_county_code = 21 if city == "Macon-Bibb County" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "Macon-Bibb County" & statename == "Georgia"

*mcrae-helena, ga
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2770965,City%20of%20McRae-Helena
replace state = "GA" if city == "McRae-Helena" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "McRae-Helena" & statename == "Georgia"
replace mult_county = 1 if city == "McRae-Helena" & statename == "Georgia"
replace county_number = 1 if city == "McRae-Helena" & statename == "Georgia"
replace county_name = "Telfair County" if city == "McRae-Helena" & statename == "Georgia"
replace fips_county_code = 271 if city == "McRae-Helena" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "McRae-Helena" & statename == "Georgia"
expand 2 if city == "McRae-Helena" & statename == "Georgia"
bysort fips_state_code fips_place_code city: gen temp_number = _n
replace county_number = 2 if city == "McRae-Helena" & statename == "Georgia" & temp_number == 2
replace county_name = "Wheeler County" if city == "McRae-Helena" & statename == "Georgia" & temp_number == 2
replace fips_county_code = 309 if city == "McRae-Helena" & statename == "Georgia" & temp_number == 2
drop temp_number

*peachtree corners, ga
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2710337,City%20of%20Peachtree%20Corners
replace state = "GA" if city == "Peachtree Corners" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "Peachtree Corners" & statename == "Georgia"
replace mult_county = 0 if city == "Peachtree Corners" & statename == "Georgia"
replace county_number = 1 if city == "Peachtree Corners" & statename == "Georgia"
replace county_name = "Gwinnett County" if city == "Peachtree Corners" & statename == "Georgia"
replace fips_county_code = 135 if city == "Peachtree Corners" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "Peachtree Corners" & statename == "Georgia"

*south fulton, ga
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2786574,City%20of%20South%20Fulton
replace state = "GA" if city == "South Fulton" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "South Fulton" & statename == "Georgia"
replace mult_county = 0 if city == "South Fulton" & statename == "Georgia"
replace county_number = 1 if city == "South Fulton" & statename == "Georgia"
replace county_name = "Fulton County" if city == "South Fulton" & statename == "Georgia"
replace fips_county_code = 121 if city == "South Fulton" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "South Fulton" & statename == "Georgia"

*stonecrest, ga
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2786721,City%20of%20Stonecrest
replace state = "GA" if city == "Stonecrest" & statename == "Georgia"
replace place_type = "Incorporated Place" if city == "Stonecrest" & statename == "Georgia"
replace mult_county = 0 if city == "Stonecrest" & statename == "Georgia"
replace county_number = 1 if city == "Stonecrest" & statename == "Georgia"
replace county_name = "DeKalb County" if city == "Stonecrest" & statename == "Georgia"
replace fips_county_code = 89 if city == "Stonecrest" & statename == "Georgia"
replace flag_no_ansi = 1 if city == "Stonecrest" & statename == "Georgia"

*birds, il
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2398125,Village%20of%20Birds%20(historical)
replace state = "IL" if city == "Birds" & statename == "Illinois"
replace place_type = "Incorporated Place" if city == "Birds" & statename == "Illinois"
replace mult_county = 0 if city == "Birds" & statename == "Illinois"
replace county_number = 1 if city == "Birds" & statename == "Illinois"
replace county_name = "Lawrence County" if city == "Birds" & statename == "Illinois"
replace fips_county_code = 101 if city == "Birds" & statename == "Illinois"
replace flag_no_ansi = 1 if city == "Birds" & statename == "Illinois"

*st. rose, il
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2786434,Village%20of%20Saint%20Rose
replace state = "IL" if city == "St. Rose" & statename == "Illinois"
replace place_type = "Incorporated Place" if city == "St. Rose" & statename == "Illinois"
replace mult_county = 0 if city == "St. Rose" & statename == "Illinois"
replace county_number = 1 if city == "St. Rose" & statename == "Illinois"
replace county_name = "Clinton County" if city == "St. Rose" & statename == "Illinois"
replace fips_county_code = 27 if city == "St. Rose" & statename == "Illinois"
replace flag_no_ansi = 1 if city == "St. Rose" & statename == "Illinois"

*lone oak, ky
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2404951,City%20of%20Lone%20Oak%20(historical)
replace state = "KY" if city == "Lone Oak" & statename == "Kentucky"
replace place_type = "Incorporated Place" if city == "Lone Oak" & statename == "Kentucky"
replace mult_county = 0 if city == "Lone Oak" & statename == "Kentucky"
replace county_number = 1 if city == "Lone Oak" & statename == "Kentucky"
replace county_name = "McCracken County" if city == "Lone Oak" & statename == "Kentucky"
replace fips_county_code = 145 if city == "Lone Oak" & statename == "Kentucky"
replace flag_no_ansi = 1 if city == "Lone Oak" & statename == "Kentucky"

*bellerive acres, mo
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2398078,City%20of%20Bellerive%20Acres
replace state = "MO" if city == "Bellerive Acres" & statename == "Missouri"
replace place_type = "Incorporated Place" if city == "Bellerive Acres" & statename == "Missouri"
replace mult_county = 0 if city == "Bellerive Acres" & statename == "Missouri"
replace county_number = 1 if city == "Bellerive Acres" & statename == "Missouri"
replace county_name = "St. Louis County" if city == "Bellerive Acres" & statename == "Missouri"
replace fips_county_code = 189 if city == "Bellerive Acres" & statename == "Missouri"
replace flag_no_ansi = 1 if city == "Bellerive Acres" & statename == "Missouri"

*bradleyville, mo
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2398164,Village%20of%20Bradleyville%20(historical)
replace state = "MO" if city == "Bradleyville" & statename == "Missouri"
replace place_type = "Incorporated Place" if city == "Bradleyville" & statename == "Missouri"
replace mult_county = 0 if city == "Bradleyville" & statename == "Missouri"
replace county_number = 1 if city == "Bradleyville" & statename == "Missouri"
replace county_name = "Taney County" if city == "Bradleyville" & statename == "Missouri"
replace fips_county_code = 213 if city == "Bradleyville" & statename == "Missouri"
replace flag_no_ansi = 1 if city == "Bradleyville" & statename == "Missouri"

*charmwood, mo
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2748236,Town%20of%20Charmwood
replace state = "MO" if city == "Charmwood" & statename == "Missouri"
replace place_type = "Incorporated Place" if city == "Charmwood" & statename == "Missouri"
replace mult_county = 0 if city == "Charmwood" & statename == "Missouri"
replace county_number = 1 if city == "Charmwood" & statename == "Missouri"
replace county_name = "Franklin County" if city == "Charmwood" & statename == "Missouri"
replace fips_county_code = 71 if city == "Charmwood" & statename == "Missouri"
replace flag_no_ansi = 1 if city == "Charmwood" & statename == "Missouri"

*jane, mo
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2741106,Town%20of%20Jane
replace state = "MO" if city == "Jane" & statename == "Missouri"
replace place_type = "Incorporated Place" if city == "Jane" & statename == "Missouri"
replace mult_county = 0 if city == "Jane" & statename == "Missouri"
replace county_number = 1 if city == "Jane" & statename == "Missouri"
replace county_name = "McDonald County" if city == "Jane" & statename == "Missouri"
replace fips_county_code = 119 if city == "Jane" & statename == "Missouri"
replace flag_no_ansi = 1 if city == "Jane" & statename == "Missouri"

*fontana dam, nc
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2749514,Town%20of%20Fontana%20Dam
replace state = "NC" if city == "Fontana Dam" & statename == "North Carolina"
replace place_type = "Incorporated Place" if city == "Fontana Dam" & statename == "North Carolina"
replace mult_county = 0 if city == "Fontana Dam" & statename == "North Carolina"
replace county_number = 1 if city == "Fontana Dam" & statename == "North Carolina"
replace county_name = "Graham County" if city == "Fontana Dam" & statename == "North Carolina"
replace fips_county_code = 75 if city == "Fontana Dam" & statename == "North Carolina"
replace flag_no_ansi = 1 if city == "Fontana Dam" & statename == "North Carolina"

*avard, ok
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2411655,Town%20of%20Avard%20(historical)
replace state = "OK" if city == "Avard" & statename == "Oklahoma"
replace place_type = "Incorporated Place" if city == "Avard" & statename == "Oklahoma"
replace mult_county = 0 if city == "Avard" & statename == "Oklahoma"
replace county_number = 1 if city == "Avard" & statename == "Oklahoma"
replace county_name = "Woods County" if city == "Avard" & statename == "Oklahoma"
replace fips_county_code = 151 if city == "Avard" & statename == "Oklahoma"
replace flag_no_ansi = 1 if city == "Avard" & statename == "Oklahoma"

*carlton landing, ok
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2747316,Town%20of%20Carlton%20Landing
replace state = "OK" if city == "Carlton Landing" & statename == "Oklahoma"
replace place_type = "Incorporated Place" if city == "Carlton Landing" & statename == "Oklahoma"
replace mult_county = 0 if city == "Carlton Landing" & statename == "Oklahoma"
replace county_number = 1 if city == "Carlton Landing" & statename == "Oklahoma"
replace county_name = "Pittsburg County" if city == "Carlton Landing" & statename == "Oklahoma"
replace fips_county_code = 121 if city == "Carlton Landing" & statename == "Oklahoma"
replace flag_no_ansi = 1 if city == "Carlton Landing" & statename == "Oklahoma"

*james island, sc
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2743869,Town%20of%20James%20Island
replace state = "SC" if city == "James Island" & statename == "South Carolina"
replace place_type = "Incorporated Place" if city == "James Island" & statename == "South Carolina"
replace mult_county = 0 if city == "James Island" & statename == "South Carolina"
replace county_number = 1 if city == "James Island" & statename == "South Carolina"
replace county_name = "Charleston County" if city == "James Island" & statename == "South Carolina"
replace fips_county_code = 19 if city == "James Island" & statename == "South Carolina"
replace flag_no_ansi = 1 if city == "James Island" & statename == "South Carolina"

*van wyck, sc
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2791461,Town%20of%20Van%20Wyck
replace state = "SC" if city == "Van Wyck" & statename == "South Carolina"
replace place_type = "Incorporated Place" if city == "Van Wyck" & statename == "South Carolina"
replace mult_county = 0 if city == "Van Wyck" & statename == "South Carolina"
replace county_number = 1 if city == "Van Wyck" & statename == "South Carolina"
replace county_name = "Lancaster County" if city == "Van Wyck" & statename == "South Carolina"
replace fips_county_code = 57 if city == "Van Wyck" & statename == "South Carolina"
replace flag_no_ansi = 1 if city == "Van Wyck" & statename == "South Carolina"

*buffalo chip, sd
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2777649,Town%20of%20Buffalo%20Chip
replace state = "SD" if city == "Buffalo Chip" & statename == "South Dakota"
replace place_type = "Incorporated Place" if city == "Buffalo Chip" & statename == "South Dakota"
replace mult_county = 0 if city == "Buffalo Chip" & statename == "South Dakota"
replace county_number = 1 if city == "Buffalo Chip" & statename == "South Dakota"
replace county_name = "Meade County" if city == "Buffalo Chip" & statename == "South Dakota"
replace fips_county_code = 93 if city == "Buffalo Chip" & statename == "South Dakota"
replace flag_no_ansi = 1 if city == "Buffalo Chip" & statename == "South Dakota"

*coupland, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2761637,City%20of%20Coupland
replace state = "TX" if city == "Coupland" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Coupland" & statename == "Texas"
replace mult_county = 0 if city == "Coupland" & statename == "Texas"
replace county_number = 1 if city == "Coupland" & statename == "Texas"
replace county_name = "Williamson County" if city == "Coupland" & statename == "Texas"
replace fips_county_code = 491 if city == "Coupland" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Coupland" & statename == "Texas"

*plantersville, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2791463,City%20of%20Plantersville
replace state = "TX" if city == "Plantersville" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Plantersville" & statename == "Texas"
replace mult_county = 0 if city == "Plantersville" & statename == "Texas"
replace county_number = 1 if city == "Plantersville" & statename == "Texas"
replace county_name = "Grimes County" if city == "Plantersville" & statename == "Texas"
replace fips_county_code = 185 if city == "Plantersville" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Plantersville" & statename == "Texas"

*providence village, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2703983,Town%20of%20Providence%20Village
replace state = "TX" if city == "Providence Village" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Providence Village" & statename == "Texas"
replace mult_county = 0 if city == "Providence Village" & statename == "Texas"
replace county_number = 1 if city == "Providence Village" & statename == "Texas"
replace county_name = "Denton County" if city == "Providence Village" & statename == "Texas"
replace fips_county_code = 121 if city == "Providence Village" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Providence Village" & statename == "Texas"

*sandy oaks, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2771704,City%20of%20Sandy%20Oaks
replace state = "TX" if city == "Sandy Oaks" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Sandy Oaks" & statename == "Texas"
replace mult_county = 0 if city == "Sandy Oaks" & statename == "Texas"
replace county_number = 1 if city == "Sandy Oaks" & statename == "Texas"
replace county_name = "Bexar County" if city == "Sandy Oaks" & statename == "Texas"
replace fips_county_code = 29 if city == "Sandy Oaks" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Sandy Oaks" & statename == "Texas"

*sandy point, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2711396,City%20of%20Sandy%20Point
replace state = "TX" if city == "Sandy Point" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Sandy Point" & statename == "Texas"
replace mult_county = 0 if city == "Sandy Point" & statename == "Texas"
replace county_number = 1 if city == "Sandy Point" & statename == "Texas"
replace county_name = "Brazoria County" if city == "Sandy Point" & statename == "Texas"
replace fips_county_code = 39 if city == "Sandy Point" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Sandy Point" & statename == "Texas"

*spring branch, tx
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2786576,City%20of%20Spring%20Branch
replace state = "TX" if city == "Spring Branch" & statename == "Texas"
replace place_type = "Incorporated Place" if city == "Spring Branch" & statename == "Texas"
replace mult_county = 0 if city == "Spring Branch" & statename == "Texas"
replace county_number = 1 if city == "Spring Branch" & statename == "Texas"
replace county_name = "Comal County" if city == "Spring Branch" & statename == "Texas"
replace fips_county_code = 91 if city == "Spring Branch" & statename == "Texas"
replace flag_no_ansi = 1 if city == "Spring Branch" & statename == "Texas"

*cedar highlands, ut
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2791541,Town%20of%20Cedar%20Highlands
replace state = "UT" if city == "Cedar Highlands" & statename == "Utah"
replace place_type = "Incorporated Place" if city == "Cedar Highlands" & statename == "Utah"
replace mult_county = 0 if city == "Cedar Highlands" & statename == "Utah"
replace county_number = 1 if city == "Cedar Highlands" & statename == "Utah"
replace county_name = "Iron County" if city == "Cedar Highlands" & statename == "Utah"
replace fips_county_code = 21 if city == "Cedar Highlands" & statename == "Utah"
replace flag_no_ansi = 1 if city == "Cedar Highlands" & statename == "Utah"

*interlaken, ut
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2783907,Town%20of%20Interlaken
replace state = "UT" if city == "Interlaken" & statename == "Utah"
replace place_type = "Incorporated Place" if city == "Interlaken" & statename == "Utah"
replace mult_county = 0 if city == "Interlaken" & statename == "Utah"
replace county_number = 1 if city == "Interlaken" & statename == "Utah"
replace county_name = "Wasatch County" if city == "Interlaken" & statename == "Utah"
replace fips_county_code = 51 if city == "Interlaken" & statename == "Utah"
replace flag_no_ansi = 1 if city == "Interlaken" & statename == "Utah"

*bloomfield, wi
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2711667,Village%20of%20Bloomfield
replace state = "WI" if city == "Bloomfield" & statename == "Wisconsin"
replace place_type = "Incorporated Place" if city == "Bloomfield" & statename == "Wisconsin"
replace mult_county = 0 if city == "Bloomfield" & statename == "Wisconsin"
replace county_number = 1 if city == "Bloomfield" & statename == "Wisconsin"
replace county_name = "Walworth County" if city == "Bloomfield" & statename == "Wisconsin"
replace fips_county_code = 127 if city == "Bloomfield" & statename == "Wisconsin"
replace flag_no_ansi = 1 if city == "Bloomfield" & statename == "Wisconsin"

*fox crossing, wi
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2783853,Village%20of%20Fox%20Crossing
replace state = "WI" if city == "Fox Crossing" & statename == "Wisconsin"
replace place_type = "Incorporated Place" if city == "Fox Crossing" & statename == "Wisconsin"
replace mult_county = 0 if city == "Fox Crossing" & statename == "Wisconsin"
replace county_number = 1 if city == "Fox Crossing" & statename == "Wisconsin"
replace county_name = "Winnebago County" if city == "Fox Crossing" & statename == "Wisconsin"
replace fips_county_code = 139 if city == "Fox Crossing" & statename == "Wisconsin"
replace flag_no_ansi = 1 if city == "Fox Crossing" & statename == "Wisconsin"

*harrison, wi
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2746307,Village%20of%20Harrison
replace state = "WI" if city == "Harrison" & statename == "Wisconsin"
replace place_type = "Incorporated Place" if city == "Harrison" & statename == "Wisconsin"
replace mult_county = 1 if city == "Harrison" & statename == "Wisconsin"
replace county_number = 1 if city == "Harrison" & statename == "Wisconsin"
replace county_name = "Calumet County" if city == "Harrison" & statename == "Wisconsin"
replace fips_county_code = 15 if city == "Harrison" & statename == "Wisconsin"
replace flag_no_ansi = 1 if city == "Harrison" & statename == "Wisconsin"
expand 2 if city == "Harrison" & statename == "Wisconsin"
bysort fips_state_code fips_place_code city: gen temp_number = _n 
replace county_number = 2 if city == "Harrison" & statename == "Wisconsin" & temp_number == 2
replace county_name = "Outagamie County" if city == "Harrison" & statename == "Wisconsin" & temp_number == 2
replace fips_county_code = 87 if city == "Harrison" & statename == "Wisconsin" & temp_number == 2
drop temp_number

*salem lakes, wi
*https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2787905,Village%20of%20Salem%20Lakes
replace state = "WI" if city == "Salem Lakes" & statename == "Wisconsin"
replace place_type = "Incorporated Place" if city == "Salem Lakes" & statename == "Wisconsin"
replace mult_county = 0 if city == "Salem Lakes" & statename == "Wisconsin"
replace county_number = 1 if city == "Salem Lakes" & statename == "Wisconsin"
replace county_name = "Kenosha County" if city == "Salem Lakes" & statename == "Wisconsin"
replace fips_county_code = 59 if city == "Salem Lakes" & statename == "Wisconsin"
replace flag_no_ansi = 1 if city == "Salem Lakes" & statename == "Wisconsin"

*somers, wi
*https://geonames.usgs.gov/apex/f?p=138:3:16492564311707::NO:3:P3_FID,P3_TITLE:2772244,Village%20of%20Somers
replace state = "WI" if city == "Somers" & statename == "Wisconsin"
replace place_type = "Incorporated Place" if city == "Somers" & statename == "Wisconsin"
replace mult_county = 0 if city == "Somers" & statename == "Wisconsin"
replace county_number = 1 if city == "Somers" & statename == "Wisconsin"
replace county_name = "Kenosha County" if city == "Somers" & statename == "Wisconsin"
replace fips_county_code = 59 if city == "Somers" & statename == "Wisconsin"
replace flag_no_ansi = 1 if city == "Somers" & statename == "Wisconsin"

/* places incorporated after the 2010 census that are not in the using data
semmes, al
jurupa valley, ca
westlake, fl
brookhaven, ga
macon-bibb county, ga
mcrae-helena, ga
peachtree corners, ga
south fulton, ga
fontana dam, nc (https://www.smokymountainnews.com/news/item/4225-new-town-of-fontana-dam-springs-up-in-the-middle-of-nowhere)
carlton landing, ok (http://townofcarltonlanding.org/)
james island, sc (http://www.jamesislandsc.us/history)
van wyck, sc (https://www.townofvanwyck.net/community/page/about-van-wyck)
buffalo chip, sd (https://rapidcityjournal.com/news/local/crime-and-courts/sd-supreme-court-rules-in-favor-of-buffalo-chip-city/article_ba214fba-ed17-5a1b-ba16-1c08b233ddd1.html)
coupland, tx (https://www.cityofcouplandtx.us/a-brief-history-of-coupland/)
plantersville, tx (https://en.wikipedia.org/wiki/Plantersville,_Texas, https://geonames.usgs.gov/apex/f?p=gnispq:3:0::NO::P3_FID:1344169)
providence village, tx (http://townofprovidencevillage.com/online-services/information/about-the-town/)
sandy oaks, tx (https://cityofsandyoaks.com/about/)
spring branch, tx (http://cityofspringbranch.org/)
cedar highlands, ut (https://www.stgeorgeutah.com/news/archive/2017/12/20/jmr-a-town-is-born-cedar-highlands-poised-to-become-utahs-newest-municipality/#.XoTDNdNKh0s)
interlaken, ut (https://municert.utah.gov/Media/Default/Municipal%20Certifications/2015/Interlaken%20Town%20Incorporation%205.20.15.PDF)
bloomfield, wi (http://www.bloomfield-wi.us/aboutus.html)
fox crossing, wi annexed town of menasha and also incorporated some other parts(?) (http://www.foxcrossingwi.gov/, https://en.wikipedia.org/wiki/Fox_Crossing,_Wisconsin, https://geonames.usgs.gov/apex/f?p=gnispq:3:::NO::P3_FID:2783853, https://geonames.usgs.gov/apex/f?p=gnispq:3:::NO::P3_FID:2783854)
harrison, wi (https://www.harrison-wi.org/community/history.php)
salem lakes, wi merged several towns including salem and silver lake!!! (https://www.villageofsalemlakes.org/)
somers, wi (https://www.somers.org/our-community/history/somers-municipal-history/)


places disincorporated before the 2010 census that are not in the using data
mountainboro, al
birds, il
lone oak, ky
bradleyville, mo
avard, ok


places i'm not sure about
southside, ar
raymer, co
echols county consolidated government, ga
stonecrest, ga
st. rose, il
bellerive acres, mo (might've been bellerive before)
charmwood, mo
jane, mo
sandy point, tx incorporated 2002? (https://directory.tml.org/profile/city/188, https://www.chron.com/neighborhood/pearland-news/article/Sandy-Point-community-adjusts-to-incorporation-2104029.php, but wikipedia page says 2012...)


greeley county consolidated government idt that's a city...

*/

/*incorporated places in the using but not the master data

every incorporated place in using but not master is functional status I for inactive!! except for ivanhoe north, tx (which merged with ivanhoe, tx)

lol this would've been good to know earlier... functional status codes!

Functional Status Codes
A:  identifies an active government providing primary general-purpose functions
B:  identifies an active government that is partially consolidated with another government but with separate officials providing primary general-purpose functions
C:  identifies an active government consolidated with another government with a single set of officials
F:  identifies a fictitious entity created to fill the Census Bureau's geographic hierarchy
G:  identifies an active government that is subordinate to another unit of government
I:  identifies an inactive governmental unit that has the power to provide primary special-purpose functions
N:  identifies a nonfunctioning legal entity
S:  identifies a statistical entity

Islandia, FL disincorporated in 2012
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html

Lost River, ID inactive ip according to gnis
https://geonames.usgs.gov/apex/f?p=138:3:10148539361779::NO:3:P3_FID,P3_TITLE:2410881,City%20of%20Lost%20River


Allensville, KY disincorporated in 2017 and defined as CDP
http://apps.sos.ky.gov/land/cities/citydetail.asp?id=5&city=Allensville
https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2403084,City%20of%20Allensville
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html

Blandville, KY
still active ip according to gnis

Dycusburg, KY allegedly never incorporated so can't be dissolved per KY Sec of State
https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2403522,City%20of%20Dycusburg%20(historical)
https://en.wikipedia.org/wiki/Dycusburg,_Kentucky
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html

Foster, KY disincorporated in 2012
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html
https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2465546,City%20of%20Foster%20%2528historical%2529

Tillatoba, MS inactive ip according to gnis
https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2406735,Town%20of%20Tillatoba

Ashburn, MO inactive ip according to gnis
https://geonames.usgs.gov/apex/f?p=138:3:0::NO:3:P3_FID,P3_TITLE:2397440,Town%20of%20Ashburn

Baker, MO


Florida, MO


La Due, MO


Lambert, MO


Lithium, MO disincorporated and defined as CDP
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html


Tarrants, MO


Dellview, NC


Erin Springs, OK


New Woodville, OK


Oak Grove, OK


Smithville, OK


Greenhorn, OR


Ivanhoe North, TX merged into Ivanhoe City
https://www.census.gov/geographies/reference-files/time-series/geo/bas/new-annex.html


Nesbitt, TX


Rangerville, TX


Jericho, VT

							  
*/


*make a variable to denote an inactive incorporated place
gen flag_ip_inactive = 0
replace flag_ip_inactive = 1 if funcstat == "I"

*make a variable to denote a non-incorporated place
gen flag_not_ip = 0
replace flag_not_ip = 1 if place_type == "County Subdivision" & _merge == 2
replace flag_not_ip = 1 if place_type == "Census Designated Place" &  _merge == 2

*make a variable to denote not a city
gen flag_not_city = 0
replace flag_not_city = 1 if city == ""


drop _merge

*** need to drop duplicates bc I really only want 1. otherwise it'll mess up converting city ban to fraction of county ban ***
*first step: identify which places (same city, fips place code, fips county code, and fips state code) have duplicate observations
*these duplicates are county subdivisions, which in this case are fictitious census entities, so sort by place_type to get them all (will want number = 1 b/c that's incorporated place and/or the only one)

*rename Pewaukee and Superior because there are cities/towns/villages that are different...
replace city = "City of Pewaukee" if city == "Pewaukee" & fips_place_code == 62240 & statename == "Wisconsin"
replace city = "Village of Pewaukee" if city == "Pewaukee" & fips_place_code == 62250 & statename == "Wisconsin"

replace city = "City of Superior" if city == "Superior" & fips_place_code == 78650 & statename == "Wisconsin"
replace city = "Village of Superior" if city == "Superior" & fips_place_code == 78660 & statename == "Wisconsin"

gen r_place_type = 1 if place_type == "Incorporated Place"
replace r_place_type = 2 if place_type == "County Subdivision"
replace r_place_type = 3 if place_type == "Census Designated Place"

sort fips_state_code city fips_county_code r_place_type fips_place_code
by fips_state_code city fips_county_code: gen temp_number_1 = _n
sort fips_state_code city fips_county_code fips_place_code r_place_type
by fips_state_code city fips_county_code fips_place_code: gen temp_number_2 = _n
by fips_state_code city fips_county_code: egen max_temp_number_1 = max(temp_number_1)
by fips_state_code city fips_county_code fips_place_code: egen max_temp_number_2 = max(temp_number_2)

sort fips_state_code city fips_county_code r_place_type fips_place_code

tab temp_number_1 temp_number_2

tab temp_number_1 place_type

tab temp_number_2 place_type

*now confirm that the population estimates are the same for each duplicate pair
	forvalues i = 2000(1)2018{
	bysort fips_state_code fips_county_code fips_place_code city: egen temp_max_pop_`i' = max(pop_`i')
	gen temp_flag_max_pop_`i' = 1 if temp_max_pop_`i' != pop_`i'
	replace temp_flag_max_pop_`i' = 0 if temp_max_pop_`i' == pop_`i'
	tab temp_flag_max_pop_`i', missing
	}

*temp_flag_max_pop_`i' = 0 for all observations, which means the population estimates are the same, so we are good to go with respect to deleting the duplicates
drop if temp_number_1 != 1
drop temp_*

*now make use of those flags from earlier (not an incorporated place & not a city)
*don't delete the unincorporated places because some of them passed smoking bans
drop if flag_not_city == 1

* now merge updated pop estimates for the cities spanning multiple counties
merge 1:1 fips_state_code fips_county_code fips_place_code city using "$build_data/census_subcounty_pop_est_mult_counties_2000_2018_clean.dta", update replace

drop _merge

save "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v2.dta", replace


***************

/*
make 3 datasets: 1 for cities, 1 for counties, and 1 for states
then merge them together
that way, can figure out when the city pop should stop being counted because the whole state has a ban, for example
*/


**************
*** states ***
**************
use "$build_data/smoke_free_laws_1jul2018.dta", clear

keep if locality_type == 1
ren r_entry_moyr r_state_entry_moyr
ren b_entry_moyr b_state_entry_moyr
ren flag_most_recent_law flag_state_most_recent_law

keep state r_state_entry_moyr b_state_entry_moyr flag_state_most_recent_law
drop if r_state_entry_moyr == . & b_state_entry_moyr == .
save "$build_data/smoke_free_laws_1jul2018_states.dta", replace


**************
*** cities ***
**************
use "$build_data/smoke_free_laws_1jul2018.dta", clear

keep if locality_type == 3
ren flag_nobars flag_city_nobars
ren flag_nodate flag_city_nodate
ren r_entry_moyr r_city_entry_moyr
ren b_entry_moyr b_city_entry_moyr
ren flag_inc_plus_un flag_city_inc_plus_un
ren flag_uninc_only flag_city_uninc_only
ren flag_most_recent_law flag_city_most_recent_law
*ren bar_ban city_bar_ban

replace locality = subinstr(locality, "~","",.)
replace locality = subinstr(locality, "+","",.)

keep locality state flag_city_nobars flag_city_nodate r_city_entry_moyr b_city_entry_moyr flag_city_inc_plus_un flag_city_uninc_only flag_city_most_recent_law

*change some city names to be consistent/spelled correctly
replace locality = "Cañon City" if locality == "Canon City" & state == "CO"
replace locality = "Lake St. Louis" if locality == "Lake Saint Louis" & state == "MO"
replace locality = "Española" if locality == "Espanola" & state == "NM"
replace locality = "DeSoto" if locality == "Desoto" & state == "TX"
replace locality = "Spring Valley Village" if locality == "Spring Valley" & state == "TX"

ren locality city

save "$build_data/smoke_free_laws_1jul2018_cities.dta", replace

*merge in the county codes and city population data

*** first find the places that didn't merge properly ***

/*you'll have problems merging for any states where there are multiple places with the same name
cottonwood, az is an incorporated place in yavapai county and a cdp in apache county, so when you 1:m merge it merges with both of those (but you only want yavapai county one)
el cerrito, ca is an incorporated place in contra costa county and a cdp in riverside county (you only want contra costa county one)
mountain view, ca is an incorporated place in santa clara county and a cdp in contra costa county (you only want santa clara county one)
paradise, ca is an incorporated place in butte county and a cdp in mono county (you only want the butte county one)
marquette, mi is an incorporated place in marquette county and a county subdivision in mackinac county (you only want the marquette county one)
golden valley, mn is an incorporated place in hennepin county and a county subdivision in roseau county (you only want the hennepin county one)
white bear lake, mn is an incorporated place in both ramsey and washington counties and a county subdivision in pope county (you only want the ramsey and washington county ones)
springdale, sc is an incorporated place in lexington county and a cdp in lancaster county (you only want the lexington county one)
el cenizo, tx is an incorporated place in webb county and a cdp in starr county (you only want the webb county one)
mesquite, tx is an incorporated place in dallas and kaufman counties and a cdp in starr county (you only want the dallas and kaufman county ones)
san juan, tx is an incorporated place in hildago county and a cdp in starr county (you only want the hildago county one)
big bend, wi is an incorporated place in waukesha county and a county subdivision in rusk county (you only want the waukesha county one)
glendale, wi is an incorporated place in milwaukee county and a county subdivision in monroe county (you only want the monroe county one)
greenfield, wi is an incorporated place in milwaukee county and a county subdivision in la crosse, monroe, and sauk counties (you only want the milwaukee county one)
marshfield, wi is an incorporated place in marathon and wood counties and a county subdivision in fond du lac county (you only want the marathon and wood county ones)
weston, wi is an incorporated place in marathon county and a county subdivision in clark and dunn counties (you only want the marathon county one)
mountain view, wi is an incorporated place in uinta county and a cdp in natrona county (you only want the uinta county one)

*/

merge 1:m city state using "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v2.dta"

drop if city == "Cottonwood" & fips_state_code == 4 & county_name == "Apache County"
drop if city == "El Cerrito" & fips_state_code == 6 & county_name == "Riverside County"
drop if city == "Mountain View" & fips_state_code == 6 & county_name == "Contra Costa County"
drop if city == "Paradise" & fips_state_code == 6 & county_name == "Mono County"
drop if city == "Marquette" & fips_state_code == 26 & county_name == "Mackinac County"
drop if city == "Golden Valley" & fips_state_code == 27 & county_name == "Roseau County"
drop if city == "White Bear Lake" & fips_state_code == 27 & county_name == "Pope County"
drop if city == "Springdale" & fips_state_code == 45 & county_name == "Lancaster County"
drop if city == "El Cenizo" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "Mesquite" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "San Juan" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "Big Bend" & fips_state_code == 55 & county_name == "Rusk County"
drop if city == "Glendale" & fips_state_code == 55 & county_name == "Monroe County"
drop if city == "Greenfield" & fips_state_code == 55 & county_name != "Milwaukee County"
drop if city == "Marshfield" & fips_state_code == 55 & county_name == "Fond du Lac County"
drop if city == "Weston" & fips_state_code == 55 & county_name != "Marathon County"
drop if city == "Mountain View" & fips_state_code == 56 & county_name == "Natrona County"

gen city_ban_not_matched_to_codes = 0
replace city_ban_not_matched_to_codes = 1 if _merge == 1

*note that _merge = 2 corresponds to cities as well as census-designated places and county subdivisions, so not all entities are cities
gen city_codes_not_matched_to_bans = 0
replace city_codes_not_matched_to_bans = 1 if _merge == 2
label variable city_codes_not_matched_to_bans "=1 if no city ban"


/*note: 5 cities have bar bans but no restaurant bans
another 8 cities have bar bans effective before restaurant bans
these are accounted for in a robustness check where you drop them

Moscow, ID--in Latah County, which has no ban but STATE of Idaho implemented a restaurant ban in July 2004 and Moscow's bar ban was implemented in August 2009 so it's fine
La Grange Park, IL--in Cook County, which implemented a w/r/b ban in March 2007 and the city had a w/b ban implemented April 2007 so it's fine
Columbus, IN--in Bartholemew County, which has no ban, but STATE of Indiana implemented a restaurant ban in July 2012 and Columbus's bar ban was implemented in June 2013 so it's doubly fine (b/c bar ban is outside my sample period)
Alpine, TX--in Brewster County, which has no ban--search for actual law (July 2010)
Kerrville, TX--in Kerr County, which has no ban--search for actual law (June 2008)

city					restaurant ban effective			bar ban effective			county				county r ban eff			county b ban eff		state r ban eff

Moscow, ID													August 2009					Latah County															July 2004
La Grange Park, IL											April 2007					Cook County			March 2007					March 2007
Columbus, IN												June 2013					Bartholemew County														July 2012
Alpine, TX													July 2010					Brewster County
Kerrville, TX												June 2008					Kerr County
Belvedere, CA			November 2016						February 1993				Marin County		February 2007				February 2007			January 1998
Tiburon, CA				August 2011							December 1992				Marin County		February 2007				February 2007			January 1998		
Oak Park, IL			March 2007							July 2006					Cook County			March 2007					March 2007				January 2008
Haverhill, MA			March 2013							September 2002				Essex County															July 2004
Hopkinton, MA			January 2004						January 2002				Middlesex County														July 2004
Belton, MO				January 2016						January 2012				Cass County	
Burlington, VT			April 2005							May 2004					Chittenden County														September 2005
Madison, WI				January 2006						July 2005					Dane County			August 2009					August 2009				July 2010

*/


*only keep the cities with smoking bans that merged; will add in the places that didn't merge below
keep if _merge == 3
drop _merge

*now find the localities that aren't incorporated places--need to merge in the subcounty data for them
keep if pop_2010 == . & pop_2009 == .

keep city state fips_state_code fips_place_code fips_county_code place_type mult_county county_name

save "$build_data/non_incorporated_places_w_smoking_bans.dta", replace



*** now get population info for non-incorporated places that passed smoking bans ***
use "$build_data/census_subcounty_pop_est_2000_2018_clean.dta", clear


*lots of places in massachusetts need a fips place code in place of a county subdivision code in order to properly merge with the smoking bans treated non-ip data
replace fips_place_code = cousub if fips_state_code == 25 & fips_place_code == 0 & cousub != .

/*holmdel township, nj livingston township, nj montville township, nj need the pop data
*lee, ny need the pop data but lee implemented its ban in 2010 while ny state implemented a ban (w/r/b) in 2003
*williston, vt need the pop data*/

replace fips_place_code = cousub if fips_state_code == 34 & (city == "Holmdel" | city == "Livingston" | city == "Montville")
replace city = "Holmdel Township" if city == "Holmdel" & fips_state_code == 34
replace city = "Livingston Township" if city == "Livingston" & fips_state_code == 34
replace city = "Montville Township" if city == "Montville" & fips_state_code == 34

replace fips_place_code = cousub if fips_state_code == 36 & city == "Lee"
replace fips_place_code = cousub if fips_state_code == 50 & city == "Williston"

/*massachusetts places that need fips_place_code to merge properly...
Abington
Acton
Acushnet
Adams
Amherst
Andover
Aquinnah
Arlington
Ashland
Auburn
Barre
Belchertown
Bellingham
Belmont
Billerica
Bolton
Bourne
Brewster
Bridgewater
Brimfield
Brookline
Buckland
Canton
Carver
Charlemont
Chatham
Chelmsford
Chilmark
Cohasset
Concord
Danvers
Dartmouth
Dedham
Deerfield
Dover
Dracut
Duxbury
Eastham
Easton
Edgartown
Egremont
Essex
Fairhaven
Falmouth
Foxborough
Framingham
Freetown
Georgetown
Gill
Grafton
Granby
Great Barrington
Hadley
Halifax
Hamilton
Hancock
Hanover
Hatfield
Hingham
Holbrook
Holden
Holliston
Hopedale
Hopkinton
Hubbardston
Hudson
Hull
Lancaster
Lee
Leicester
Lenox
Leverett
Lexington
Lincoln
Littleton
Ludlow
Lynnfield
Marblehead
Marion
Marshfield
Mashpee
Maynard
Medfield
Medway
Middleton
Millville
Milton
Montague
Monterey
Nantucket
Natick
Needham
New Braintree
Norfolk
North Andover
North Reading
Northborough
Norton
Norwood
Oak Bluffs
Orange
Orleans
Oxford
Plymouth
Provincetown
Randolph
Reading
Richmond
Rockport
Sandwich
Saugus
Scituate
Sharon
Shelburne
Sherborn
Somerset
South Hadley
Southampton
Southborough
Sterling
Stockbridge
Stoneham
Stoughton
Sudbury
Sunderland
Sutton
Swansea
Tewksbury
Tisbury
Truro
Tyngsborough
Tyringham
Wakefield
Walpole
Wareham
Wayland
Webster
Wellesley
Wellfleet
Wendell
West Tisbury
Westford
Westport
Westwood
Whately
Williamstown
Winchendon
Winchester
Wrentham
Yarmouth
*/

merge m:1 fips_state_code fips_place_code fips_county_code city using "$build_data/non_incorporated_places_w_smoking_bans.dta"

*they're not all merging--the "master-only" ones are fine and there are no _merge == 2

*only keep the matched values (in order to "update" the pop estimates)
keep if _merge == 3
drop _merge

*only keep the variables you need
keep sumlev fips_state_code fips_county_code fips_place_code statename city pop_* flag_* funcstat

save "$build_data/census_subcounty_pop_est_non_ip_bans_2000_2018_clean.dta", replace


* now merge in the population estimates for the non-incorporated places that have smoking bans
use "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v2.dta", clear

merge 1:1 fips_state_code fips_county_code fips_place_code city using "$build_data/census_subcounty_pop_est_non_ip_bans_2000_2018_clean.dta", update


*change some city names by hand to be consistent with other datasets
replace city = "Paso Robles" if city == "El Paso de Robles (Paso Robles)" & state == "CA"
replace city = "Ventura" if city == "San Buenaventura (Ventura)" & state == "CA"

replace city = "Boise" if city == "Boise City" & state == "ID"

replace city = "Barnstable" if city == "Barnstable Town" & state == "MA"
replace city = "Braintree" if city == "Braintree Town" & state == "MA"
replace city = "Easthampton" if city == "Easthampton Town" & state == "MA"
replace city = "Franklin" if city == "Franklin Town" & state == "MA"
replace city = "Greenfield" if city == "Greenfield Town" & state == "MA"
replace city = "Methuen" if city == "Methuen Town" & state == "MA"
replace city = "Southbridge" if city == "Southbridge Town" & state == "MA"
replace city = "Watertown" if city == "Watertown Town" & state == "MA"
replace city = "West Springfield" if city == "West Springfield Town" & state == "MA"
replace city = "Weymouth" if city == "Weymouth Town" & state == "MA"
replace city = "Winthrop" if city == "Winthrop Town" & state == "MA"

replace city = "Highland Park Borough" if city == "Highland Park" & state == "NJ"
replace city = "Manville Borough" if city == "Manville" & state == "NJ"

replace city = "New York City" if city == "New York" & state == "NY"

replace city = "Lake Delton Village" if city == "Lake Delton" & state == "WI"

drop _merge

save "$build_data/census_incorporated_place_pop_est_2000_2018_clean_v3.dta", replace

* now merge using in the population estimates (for the non-incorporated places as well) with the treatment data

merge m:1 city state using "$build_data/smoke_free_laws_1jul2018_cities.dta"

tab city if _merge == 2
*honolulu, hi is in the county ban dataset so it's ok that it's not merging here

drop if city == "Cottonwood" & fips_state_code == 4 & county_name == "Apache County"
drop if city == "El Cerrito" & fips_state_code == 6 & county_name == "Riverside County"
drop if city == "Mountain View" & fips_state_code == 6 & county_name == "Contra Costa County"
drop if city == "Paradise" & fips_state_code == 6 & county_name == "Mono County"
drop if city == "Marquette" & fips_state_code == 26 & county_name == "Mackinac County"
drop if city == "Golden Valley" & fips_state_code == 27 & county_name == "Roseau County"
drop if city == "White Bear Lake" & fips_state_code == 27 & county_name == "Pope County"
drop if city == "Springdale" & fips_state_code == 45 & county_name == "Lancaster County"
drop if city == "El Cenizo" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "Mesquite" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "San Juan" & fips_state_code == 48 & county_name == "Starr County"
drop if city == "Big Bend" & fips_state_code == 55 & county_name == "Rusk County"
drop if city == "Glendale" & fips_state_code == 55 & county_name == "Monroe County"
drop if city == "Greenfield" & fips_state_code == 55 & county_name != "Milwaukee County"
drop if city == "Marshfield" & fips_state_code == 55 & county_name == "Fond du Lac County"
drop if city == "Weston" & fips_state_code == 55 & county_name != "Marathon County"
drop if city == "Mountain View" & fips_state_code == 56 & county_name == "Natrona County"

gen city_ban_not_matched_to_codes = 0
replace city_ban_not_matched_to_codes = 1 if _merge == 1

*note that _merge = 2 corresponds to cities as well as census-designated places and county subdivisions, so not all entities are cities
gen city_codes_not_matched_to_bans = 0
replace city_codes_not_matched_to_bans = 1 if _merge == 2
label variable city_codes_not_matched_to_bans "=1 if no city ban"

*every city with a smoking ban successfully merged so only keep the treated cities PLUS the cities that you have to adjust the county bans for (because they weren't covered under a particular county ban)
gen keeper = (_merge == 3)
replace keeper = 1 if fips_state_code == 18 & (city == "Beech Grove" | city == "Evansville" | city == "Lawrence" | city == "Southport" | city == "Speedway")

tab keeper _merge

keep if keeper == 1
drop _merge keeper

*** now merge in the county pop data in order to make the treatment variable that's a fraction! ***

* first reshape the data to be long instead of wide (also only keep the variables you need)
keep city state flag_* r_city_entry_moyr b_city_entry_moyr fips_state_code fips_place_code statename pop_* place_type mult_county county_name fips_county_code city_*
drop pop_base* pop_census*

reshape long pop_, i(city state b_city_entry_moyr fips_state_code fips_county_code fips_place_code) j(year)

ren pop_ city_pop

* make the dataset a time series with the appropriate time periods
keep if year >= 2004 & year <= 2012

gen data_start = ym(2004, 01)
format data_start %tm 

*expand to be 9 years x 12 months/year = 156 months and make it be monthly
expand 12
sort fips_state_code city fips_county_code year
bysort fips_state_code city fips_county_code year: gen month = _n
bysort fips_state_code city fips_county_code: gen time_moyr = data_start + _n - 1
format time_moyr %tm

save "$build_data/smoking_bans_cities.dta", replace


*** make census 2004-2012 county pop data to use to calculate the fraction of the county that's treated ***

* 2000-2010
import delimited "$build_data/co-est00int-tot.csv", varnames(1) clear

* rename variables
ren ctyname county_name
ren stname state_name
ren state fips_state_code
ren county fips_county_code

ren census2010pop county_pop_census_2010
ren estimatesbase2000 county_pop_base_2000

forvalues i = 2000(1)2010 {
	ren popestimate`i' pop_est_`i'
	}
	
* don't need the state population estimates (sumlev = 40)
drop if sumlev == 40

* reshape to make the unit of observation be a county-year
reshape long pop_est_, i(county_name state_name fips_state_code fips_county_code) j(year)

ren pop_est_ county_pop

save "$build_data/census_county_pop_estimates_2000_2010.dta", replace

* 2010-2017
import delimited "$build_data/co-est2017-alldata.csv", varnames(1) clear

* rename variables
ren ctyname county_name
ren stname state_name
ren state fips_state_code
ren county fips_county_code

ren census2010pop county_pop_census_2010
ren estimatesbase2010 county_pop_base_2010

forvalues i = 2010(1)2017 {
	ren popestimate`i' pop_est_`i'
	}
	
* don't need the state population estimates (sumlev = 40)
drop if sumlev == 40

* only keep the variables you need
keep sumlev region division fips* state_name county_name *pop_*

* reshape to make the unit of observation be a county-year
reshape long pop_est_, i(county_name state_name fips_state_code fips_county_code) j(year)

ren pop_est_ county_pop

save "$build_data/census_county_pop_estimates_2010_2017.dta", replace

* append all years and only keep 2004-2012 (sample period)
use "$build_data/census_county_pop_estimates_2000_2010.dta", clear
drop if year == 2010
append using "$build_data/census_county_pop_estimates_2010_2017.dta"
sort fips_state_code fips_county_code year

* change oglala lakota county, sd to shannon county, sd and kusilvak census area, ak to wade hampton census area, ak (names changed in 2015 and using the names that were in use at the end of my sample period)
replace fips_county_code = 113 if county_name == "Oglala Lakota County" & fips_state_code == 46
replace county_name = "Shannon County" if county_name == "Oglala Lakota County" & fips_state_code == 46

replace fips_county_code = 270 if county_name == "Kusilvak Census Area" & fips_state_code == 2
replace county_name = "Wade Hampton Census Area" if county_name == "Kusilvak Census Area" & fips_state_code == 2

keep if year >= 2004 & year <= 2012
keep state_name county_name year fips_state_code fips_county_code county_pop

*now expand the dataset to be a time series
gen data_start = ym(2004, 01)
format data_start %tm 

*expand to be 9 years x 12 months/year = 108 months and make it be monthly
expand 12
sort fips_state_code fips_county_code year
bysort fips_state_code fips_county_code year: gen month = _n
bysort fips_state_code fips_county_code: gen time_moyr = data_start + _n - 1
format time_moyr %tm

save "$build_data/census_county_pop_2004_2012.dta", replace

*** now merge city smoking ban data/pop estimates with county pop estimates ***
merge 1:m fips_state_code fips_county_code time_moyr using "$build_data/smoking_bans_cities.dta"

*unmatched from master data will be the counties that don't have any cities that implemented smoking bans
keep if _merge == 3
drop _merge

*now make a county fraction variable
gen county_fraction = city_pop/county_pop

/*places missing population data

missing city pop data:
Diamondhead, MS				fine: not treated @ city level in sample period
Dunwoody, GA				fine: not treated @ city level in sample period
Framingham, MA				fine: city bar/restaurant ban effective same date as state-level ban
Greenfield, MA				fine: not treated @ city level in sample period
Petersburg, AK				fine: not in BRFSS sample
South Fulton, GA			fine: not treated @ city level in sample period
Southbridge, MA				fine: not treated @ city level in sample period
Winthrop, MA				fine: not treated @ city level in sample period
*/


*make indicators for bar/restaurant bans effective
gen city_bar_ban = .
replace city_bar_ban = 1 if b_city_entry_moyr <= time_moyr
replace city_bar_ban = 0 if b_city_entry_moyr > time_moyr
label variable city_bar_ban "=1 if bar ban effective in city"
gen city_restaurant_ban = .
replace city_restaurant_ban = 1 if r_city_entry_moyr <= time_moyr
replace city_restaurant_ban = 0 if r_city_entry_moyr > time_moyr
label variable city_restaurant_ban "=1 if restaurant ban effective in city"
gen city_restaurant_ban_v1 = .
replace city_restaurant_ban_v1 = 1 if city_restaurant_ban == 1 & city_bar_ban == 0
replace city_restaurant_ban_v1 = 0 if city_restaurant_ban == 0 | city_bar_ban == 1
label variable city_restaurant_ban_v1 "=1 if ONLY restaurant ban effective in `locality'"

* make variable for fraction of the county population subject to bar/restaurant bans
local types = "bar restaurant"

foreach type of local types {
	gen sub_co_fraction_`type'_ban = city_`type'_ban*county_fraction
	label variable sub_co_fraction_`type'_ban "=fraction of county subject to a `type' ban"
	}

gen sub_co_fraction_rest_ban_v1 = city_restaurant_ban_v1*county_fraction
label variable sub_co_fraction_rest_ban_v1 "=fraction of county subject to ONLY a restaurant ban"

tab sub_co_fraction_bar_ban if fips_state_code == 18 & city == "Beech Grove", missing
tab sub_co_fraction_bar_ban if fips_state_code == 18 & city == "Evansville"
tab sub_co_fraction_bar_ban if fips_state_code == 18 & city == "Lawrence"
tab sub_co_fraction_bar_ban if fips_state_code == 18 & city == "Southport"
tab sub_co_fraction_bar_ban if fips_state_code == 18 & city == "Speedway"

tab sub_co_fraction_rest_ban_v1 if fips_state_code == 18 & city == "Beech Grove"
tab sub_co_fraction_rest_ban_v1 if fips_state_code == 18 & city == "Evansville"
tab sub_co_fraction_rest_ban_v1 if fips_state_code == 18 & city == "Lawrence"
tab sub_co_fraction_rest_ban_v1 if fips_state_code == 18 & city == "Southport"
tab sub_co_fraction_rest_ban_v1 if fips_state_code == 18 & city == "Speedway"

* make a special variable for the indiana cities that you need to exclude from the county ban
gen flag_indiana_special = 0
replace flag_indiana_special = 1 if fips_state_code == 18 & (city == "Beech Grove" | city == "Evansville" | city == "Lawrence" | city == "Southport" | city == "Speedway")

gen sub_co_fraction_bar_ban_insp = sub_co_fraction_bar_ban
gen sub_co_fraction_rest_ban_insp = sub_co_fraction_restaurant_ban
gen sub_co_fraction_rest_ban_v1_insp = sub_co_fraction_rest_ban_v1

replace sub_co_fraction_bar_ban_insp = (city_bar_ban-1)*county_fraction if flag_indiana_special == 1
replace sub_co_fraction_rest_ban_insp = (city_restaurant_ban-1)*county_fraction if flag_indiana_special == 1
replace sub_co_fraction_rest_ban_v1_insp = (city_restaurant_ban_v1-1)*county_fraction if flag_indiana_special == 1

tab sub_co_fraction_bar_ban_insp if flag_indiana_special == 1, missing
tab sub_co_fraction_rest_ban_insp if flag_indiana_special == 1, missing
tab sub_co_fraction_rest_ban_v1_insp if flag_indiana_special == 1, missing

*there are some minor differences in population for a few cities/counties (ones where the city and county are coterminous/consolidated, or the city is an independent city). forcing them to top out at 1 for the fraction of the population treated

/*
Anchorage, AK: city-level bar/restaurant ban effective 7/1/2007. no state-level law. consolidated city-borough government
Baltimore, MD: city bar/restaurant ban effective same date as state-level law
Nantucket, MA: treated @ city level. b/r effective date 9/1/2001, before state-level law, b/r eff date 7/5/2004. consolidated city-county
New Orleans, LA: not treated @ city level in sample period
New York City, NY: city-level restaurant ban effective 3/30/2003. city-level bar ban effective 1/2/2006. state-level b/r ban eff 7/24/2003. no 
					county-level laws (new york county, kings county, bronx county, richmond county, queens county)
Philadelphia, PA: city restaurant ban effective 1/8/2007. city coterminous w/county (philadelphia county)
San Francisco, CA: city restaurant ban effective 4/24/2010. state-level bar/restaurant ban effective 1/1/1998. city coterminous with the county 
					(san francisco county)
St. Louis, MO: city restaurant ban effective 1/1/2011. city bar ban eff 1/1/2016 after sample period. no state-level ban. city separate from county

missing city pop data:
Diamondhead, MS
Dunwoody, GA
Framingham, MA
Greenfield, MA
Petersburg, AK
South Fulton, GA
Southbridge, MA
Winthrop, MA
*/



/*
here are the places that had >= 50% of the county pop covered by a bar smoking ban in 2004m1
fips_state_code	fips_county_code	county	time_moyr	state_name
6	55	Napa County	2004m1	California
6	85	Santa Clara County	2004m1	California
8	101	Pueblo County	2004m1	Colorado
25	1	Barnstable County	2004m1	Massachusetts
25	7	Dukes County	2004m1	Massachusetts
25	19	Nantucket County	2004m1	Massachusetts
25	25	Suffolk County	2004m1	Massachusetts
41	3	Benton County	2004m1	Oregon
48	141	El Paso County	2004m1	Texas

here are the places that had >= 50% of the county pop covered by a restaurant smoking ban in 2004m1
fips_state_code	fips_county_code	county	time_moyr	state_name
2	70	Dillingham Census Area	2004m01	Alaska
2	185	North Slope Borough	2004m01	Alaska
6	55	Napa County	2004m1	California
6	85	Santa Clara County	2004m1	California
8	3	Alamosa County	2004m01	Colorado
8	101	Pueblo County	2004m1	Colorado
25	1	Barnstable County	2004m1	Massachusetts
25	7	Dukes County	2004m1	Massachusetts
25	19	Nantucket County	2004m1	Massachusetts
25	21	Norfolk County	2004m01	Massachusetts
25	25	Suffolk County	2004m1	Massachusetts
36	5	Bronx County	2004m01	New York
36	47	Kings County	2004m01	New York
36	61	New York County	2004m01	New York
36	81	Queens County	2004m01	New York
36	85	Richmond County	2004m01	New York
41	3	Benton County	2004m1	Oregon
48	113	Dallas County	2004m01	Texas
48	141	El Paso County	2004m1	Texas

*/

replace sub_co_fraction_bar_ban = 1 if sub_co_fraction_bar_ban > 1 & sub_co_fraction_bar_ban != .
replace sub_co_fraction_restaurant_ban = 1 if sub_co_fraction_restaurant_ban > 1 & sub_co_fraction_restaurant_ban != .
replace sub_co_fraction_rest_ban_v1 = 1 if sub_co_fraction_rest_ban_v1 > 1 & sub_co_fraction_rest_ban_v1 != .

* need to hand code the coterminous city-counties as bar/rest ban fraction = 1. all the nyc boroughs bc there are slightly different city/county pop estimates per year that make the county_fraction != 1
replace sub_co_fraction_bar_ban = 1 if sub_co_fraction_bar_ban > 0 & fips_state_code == 36 & (fips_county_code == 5 | fips_county_code == 47 | fips_county_code == 61 | fips_county_code == 81 | fips_county_code == 85)
replace sub_co_fraction_restaurant_ban = 1 if sub_co_fraction_restaurant_ban > 0 & fips_state_code == 36 & (fips_county_code == 5 | fips_county_code == 47 | fips_county_code == 61 | fips_county_code == 81 | fips_county_code == 85)
replace sub_co_fraction_rest_ban_v1 = 1 if sub_co_fraction_rest_ban_v1 > 0 & fips_state_code == 36 & (fips_county_code == 5 | fips_county_code == 47 | fips_county_code == 61 | fips_county_code == 81 | fips_county_code == 85)

* hand code cumberland, in (marion county portion) as rest ban = 0 because it's in marion county, which had the special law excluding some cities (but cumberland = included in marion county ban) and cumberland implemented restaurant ban AFTER county ban
replace sub_co_fraction_restaurant_ban = 0 if fips_state_code == 18 & city == "Cumberland" & county_name == "Marion County"

preserve

bys fips_state_code fips_county_code: egen min_bar_date = min(b_city_entry_moyr)
bys fips_state_code fips_county_code: egen min_rest_date = min(r_city_entry_moyr)

format min_bar_date %tm
format min_rest_date %tm

keep if min_bar_date < ym(2004, 01) | min_rest_date < ym(2004, 01)

collapse (sum) sub_co_fraction_bar_ban sub_co_fraction_restaurant_ban, by(fips_state_code fips_county_code time_moyr county_name state_name year month state min_bar_date min_rest_date)

gen sub_co_fraction_rest_ban_v1 = sub_co_fraction_restaurant_ban - sub_co_fraction_bar_ban
replace sub_co_fraction_rest_ban_v1 = 0 if sub_co_fraction_rest_ban_v1 < 0

keep if time_moyr == ym(2004, 01)
keep if sub_co_fraction_bar_ban > 0.5 | sub_co_fraction_restaurant_ban > 0.5

gen flag_pre_treated = 1

export excel using "$build_data/smoking_ban_pre-treated_counties", sheetreplace firstrow(variables)
save "$build_data/smoking_ban_pre-treated_counties.dta", replace

restore

* merge on the pre-treated counties (to get that 50%+ covered variable)
merge m:1 fips_state_code fips_county_code time_moyr using "$build_data/smoking_ban_pre-treated_counties.dta"

bys fips_state_code fips_county_code: egen flag_pre_treated_1 = max(flag_pre_treated)

replace flag_pre_treated_1 = 0 if flag_pre_treated_1 == .
tab flag_pre_treated_1 flag_pre_treated, missing
drop flag_pre_treated
ren flag_pre_treated_1 flag_pre_treated
tab flag_pre_treated _merge
drop _merge

preserve

*keep the cities that are in counties with > 50% of the pop covered by a bar or restaurant smoking ban in 2004m01
keep if flag_pre_treated == 1

*make variables that equal the effective date of a bar/restaurant smoking ban for at least 50% of the county population. coding by hand
sort fips_state_code fips_county_code time_moyr city
order fips_state_code fips_county_code time_moyr city b_city_entry_moyr r_city_entry_moyr county_fraction

gen b_city_entry_moyr_avg = .
replace b_city_entry_moyr_avg = ym(1998, 11) if fips_state_code == 6 & fips_county_code == 55
replace b_city_entry_moyr_avg = ym(1998, 10) if fips_state_code == 6 & fips_county_code == 85
replace b_city_entry_moyr_avg = ym(2003, 05) if fips_state_code == 8 & fips_county_code == 101
replace b_city_entry_moyr_avg = ym(2001, 07) if fips_state_code == 25 & fips_county_code == 1
replace b_city_entry_moyr_avg = ym(2001, 07) if fips_state_code == 25 & fips_county_code == 7
replace b_city_entry_moyr_avg = ym(2001, 09) if fips_state_code == 25 & fips_county_code == 19
replace b_city_entry_moyr_avg = ym(2003, 05) if fips_state_code == 25 & fips_county_code == 25
replace b_city_entry_moyr_avg = ym(1998, 07) if fips_state_code == 41 & fips_county_code == 3
replace b_city_entry_moyr_avg = ym(2002, 01) if fips_state_code == 48 & fips_county_code == 141
format b_city_entry_moyr_avg %tm

gen r_city_entry_moyr_avg = .
replace r_city_entry_moyr_avg = ym(2003, 12) if fips_state_code == 2 & fips_county_code == 70
replace r_city_entry_moyr_avg = ym(2002, 02) if fips_state_code == 2 & fips_county_code == 185
replace r_city_entry_moyr_avg = ym(1998, 11) if fips_state_code == 6 & fips_county_code == 55
replace r_city_entry_moyr_avg = ym(1998, 10) if fips_state_code == 6 & fips_county_code == 85
replace r_city_entry_moyr_avg = ym(2002, 01) if fips_state_code == 8 & fips_county_code == 3
replace r_city_entry_moyr_avg = ym(2003, 05) if fips_state_code == 8 & fips_county_code == 101
replace r_city_entry_moyr_avg = ym(2001, 07) if fips_state_code == 25 & fips_county_code == 1
replace r_city_entry_moyr_avg = ym(2001, 07) if fips_state_code == 25 & fips_county_code == 7
replace r_city_entry_moyr_avg = ym(2001, 09) if fips_state_code == 25 & fips_county_code == 19
replace r_city_entry_moyr_avg = ym(2004, 01) if fips_state_code == 25 & fips_county_code == 21
replace r_city_entry_moyr_avg = ym(2003, 05) if fips_state_code == 25 & fips_county_code == 25
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 36 & fips_county_code == 5
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 36 & fips_county_code == 47
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 36 & fips_county_code == 61
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 36 & fips_county_code == 81
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 36 & fips_county_code == 85
replace r_city_entry_moyr_avg = ym(1998, 07) if fips_state_code == 41 & fips_county_code == 3
replace r_city_entry_moyr_avg = ym(2003, 03) if fips_state_code == 48 & fips_county_code == 113
replace r_city_entry_moyr_avg = ym(2002, 01) if fips_state_code == 48 & fips_county_code == 141
format r_city_entry_moyr_avg %tm
 

label variable b_city_entry_moyr_avg "Effective date of bar smoking ban for >= 50% county pop"
label variable r_city_entry_moyr_avg "Effective date of restaurant smoking ban for >= 50% county pop"

/*
barnstable county is making me add! I added in excel and copied the numbers here
1998m1 = .01287322
1999m1 = .01287322 + .03050423 + .02874291
1999m11 = .0433774 + .04591909
2000m1 = .0721203 + .00962705
2000m4 = .1180394 + .21439019 + .11049031
2001m7 = .4525469 + .0867683 + .0923331 = .6316483

so... 2001m7 is the effective date for 50%!

norfolk county also making me add for the restaurant variable

city	b_city_entry_moyr	r_city_entry_moyr	county_fraction	csum
Sharon	1995m6	1995m6	0.0265725	0.0265725
Brookline		1995m7	0.086585	0.1131575
Cohasset	1998m3	1998m3	0.0112284	0.1243859
Wellesley		1999m1	0.0405099	0.1648958
Bellingham		2001m10	0.0240611	0.1889569
Dover	2001m11	2001m11	0.0086695	0.1976264
Needham	2001m8	2001m8	0.0444433	0.2420697
Braintree	2002m1	2002m1	0.0517874	0.2938571
Weymouth	2002m1	2002m1	0.082877	0.3767341
Westwood	2002m3	2002m3	0.0214256	0.3981597
Walpole	2002m6	2002m6	0.0353554	0.4335151
Norfolk	2003m1	2003m1	0.016432	0.4499471
Wrentham	2003m7	2003m7	0.0169192	0.4668663
Dedham	2004m1	2004m1	0.0357063	0.5025726
Medfield	2004m6	2004m6	0.0187503	0.5213229
Canton	2004m8	2004m8	0.0328578	0.5541807
Quincy	2004m8	2004m8	0.1380445	0.6922252
Norwood	2006m11	2006m11	0.0439575	0.7361827
Milton	2012m3	2012m3	0.0401606	0.7763433
Foxborough	2013m8	2013m8	0.024982	0.8013253
Franklin	2014m4	2014m4	0.0471967	0.848522
Medway	2014m9	2014m9	0.0197064	0.8682284
Stoughton	2016m3	2016m3	0.0410661	0.9092945
Holbrook	2016m8	2016m8	0.0165346	0.9258291
Randolph	2017m1	2017m1	0.0469761	0.9728052

50% = dedham, with eff date 2004m01
*/

* now collapse the data to the county-month-year level, where the treatment variable is the sum of all the city fractions
collapse b_city_entry_moyr_avg r_city_entry_moyr_avg (min) b_city_entry_moyr_min = b_city_entry_moyr  r_city_entry_moyr_min = r_city_entry_moyr (max) b_city_entry_moyr_max = b_city_entry_moyr r_city_entry_moyr_max = r_city_entry_moyr (sum) sub_co_fraction_bar_ban sub_co_fraction_restaurant_ban sub_co_fraction_rest_ban_v1, by(fips_state_code fips_county_code state_name county_name time_moyr)

gen b_city_entry_moyr_all = time_moyr if sub_co_fraction_bar_ban >= 1 & sub_co_fraction_bar_ban != .
bysort fips_state_code fips_county_code: egen b_city_entry_moyr_all_min = min(b_city_entry_moyr_all)
replace b_city_entry_moyr_all = b_city_entry_moyr_all_min
format b_city_entry_moyr_all %tm

gen r_city_entry_moyr_all = time_moyr if sub_co_fraction_restaurant_ban >= 1 & sub_co_fraction_bar_ban != .
bysort fips_state_code fips_county_code: egen r_city_entry_moyr_all_min = min(r_city_entry_moyr_all)
replace r_city_entry_moyr_all = r_city_entry_moyr_all_min
format r_city_entry_moyr_all %tm

save "$build_data/smoking_bans_cities_early.dta", replace

restore

* now collapse the data to the county-month-year level, where the treatment variable is the sum of all the city fractions
collapse flag_pre_treated (min) b_city_entry_moyr_min = b_city_entry_moyr r_city_entry_moyr_min = r_city_entry_moyr (max) flag_indiana_special b_city_entry_moyr_max = b_city_entry_moyr r_city_entry_moyr_max = r_city_entry_moyr (sum) sub_co_fraction_bar_ban sub_co_fraction_restaurant_ban sub_co_fraction_rest_ban_v1 sub_co_fraction_bar_ban_insp sub_co_fraction_rest_ban_insp sub_co_fraction_rest_ban_v1_insp, by(fips_state_code fips_county_code state_name county_name time_moyr)

merge 1:1 fips_state_code fips_county_code time_moyr using "$build_data/smoking_bans_cities_early.dta"

replace b_city_entry_moyr_avg = time_moyr if sub_co_fraction_bar_ban >= 0.5 & sub_co_fraction_bar_ban != . & _merge == 1
replace r_city_entry_moyr_avg = time_moyr if sub_co_fraction_restaurant_ban >= 0.5 & sub_co_fraction_restaurant_ban != . & _merge == 1

bysort fips_state_code fips_county_code: egen b_city_entry_moyr_avg_min = min(b_city_entry_moyr_avg)
replace b_city_entry_moyr_avg = b_city_entry_moyr_avg_min if _merge == 1

bysort fips_state_code fips_county_code: egen r_city_entry_moyr_avg_min = min(r_city_entry_moyr_avg)
replace r_city_entry_moyr_avg = r_city_entry_moyr_avg_min if _merge == 1

label variable b_city_entry_moyr_avg "Effective date of bar smoking ban for >= 50% county pop"
label variable b_city_entry_moyr_min "Effective date of first bar smoking ban in county"
label variable b_city_entry_moyr_max "Effective date of most recent bar smoking ban in county"

label variable r_city_entry_moyr_avg "Effective date of restaurant smoking ban for >= 50% county pop"
label variable r_city_entry_moyr_min "Effective date of first restaurant smoking ban in county"
label variable r_city_entry_moyr_max "Effective date of most recent restaurant smoking ban in county"

gen b_city_entry_moyr_all_1 = time_moyr if sub_co_fraction_bar_ban >= 1 & sub_co_fraction_bar_ban != . & _merge == 1
bysort fips_state_code fips_county_code: egen b_city_entry_moyr_all_min_1 = min(b_city_entry_moyr_all_1)
replace b_city_entry_moyr_all = b_city_entry_moyr_all_min_1 if _merge == 1
format b_city_entry_moyr_all %tm

gen r_city_entry_moyr_all_1 = time_moyr if sub_co_fraction_restaurant_ban >= 1 & sub_co_fraction_restaurant_ban != . & _merge == 1
bysort fips_state_code fips_county_code: egen r_city_entry_moyr_all_min_1 = min(r_city_entry_moyr_all_1)
replace r_city_entry_moyr_all = r_city_entry_moyr_all_min_1 if _merge == 1
format r_city_entry_moyr_all %tm

label variable b_city_entry_moyr_all "Effective date of bar smoking ban for 100% county pop"
label variable r_city_entry_moyr_all "Effective date of restaurant smoking ban for 100% county pop"

drop _merge b_city_entry_moyr_avg_min b_city_entry_moyr_all_min b_city_entry_moyr_all_1 b_city_entry_moyr_all_min_1 r_city_entry_moyr_avg_min r_city_entry_moyr_all_min r_city_entry_moyr_all_1 r_city_entry_moyr_all_min_1

save "$build_data/smoking_bans_cities_collapsed.dta", replace

****************
*** counties ***
****************
use "$build_data/smoke_free_laws_1jul2018.dta", clear

* putting honolulu and other coterminous city-counties/independent cities in county bans dataset b/c, e.g., government = city & county of honolulu
replace locality_type = 2 if locality_type == 3 & (flag_coterminous == 1 | flag_independent == 1)

keep if locality_type == 2
ren locality county
ren flag_nobars flag_county_nobars
ren flag_nodate flag_county_nodate
ren r_entry_moyr r_county_entry_moyr
ren b_entry_moyr b_county_entry_moyr
ren flag_inc_plus_un flag_county_inc_plus_un
ren flag_uninc_only flag_county_uninc_only
ren flag_most_recent_law flag_county_most_recent_law

replace county = subinstr(county, "+","",.)
replace county = subinstr(county, "~","",.)

replace flag_county_inc_plus_un = 1 if flag_county_inc_plus_un == . & (flag_coterminous == 1 | flag_independent == 1)
replace flag_county_uninc_only = 0 if flag_county_uninc_only == . & (flag_coterminous == 1 | flag_independent == 1)

tab flag_county_inc_plus_un flag_county_uninc_only, missing

keep county state flag_county_nobars flag_county_nodate r_county_entry_moyr b_county_entry_moyr flag_county_inc_plus_un flag_county_uninc_only flag_county_most_recent_law flag_coterminous flag_independent

ren county county_name

gen county_name_notes = county_name

*some counties in the smoking bans data have notes in the county name and/or county names combined with city names
*need to rename these counties and keep notes separately
replace county_name = "Tuolumne County" if county_name == "Tuolumne County (except the city of Sonora)"
	/*tuolumne county only had a workplace ban so don't need to do anything*/
replace county_name = "Clarke County" if county_name == "Athens/Clarke County"
	/*county ban covers incorporated and unincorporated areas so don't need to do anything*/
replace county_name = "Cook County" if county_name == "Cook County (except areas governed by an ordinance of another governmental entity)"
replace county_name = "McLean County" if county_name == "Mclean County"
	/*just a spelling change so don't need to do anything*/
replace county_name = "Allen County" if county_name == "Allen County (except those cities that choose to opt out)"
	/*no cities chose to opt out, per a google search of each city, so don't need to do anything*/
replace county_name = "Marion County" if county_name == "Indianapolis/Marion County (except the cities of Beech Grove, Lawrence, Southport, and Speedway)"
	/*need to remove county effective from beech grove, lawrence, southport, speedway. lawrence + speedway passed their own bans a few months later so need to remove their city fractions from the county fraction for the months before they implemented their laws. you do this further down in the code*/
replace county_name = "Vanderburgh County" if county_name == "Vanderburgh County (except the city of Evansville)"
	/* need to remove county effective from evansville (also note that indiana has workplace and restaurant bans but no bar ban). you do this further down in the code*/
replace county_name = "Wyandotte County" if county_name == "Kansas City/Wyandotte County"
	/*county ban covers incorporated and unincorporated areas so don't need to do anything*/
replace county_name = "Fayette County" if county_name == "Lexington/Fayette County"
	/*county ban covers incorporated and unincorporated areas so don't need to do anything*/
replace county_name = "Jefferson County" if county_name == "Louisville/Jefferson County"
	/*county ban covers incorporated and unincorporated areas so don't need to do anything*/
replace county_name = "Yalobusha County" if county_name == "Yalobusha County (except municipalities with ordinances prohibiting smoking in all workplaces and public places)"
	/*sounds like the only places not covered are ones with more comprehensive preexisting bans so don't need to do anything...*/
replace county_name = "Aiken County" if county_name == "Aiken County (except cities of Aiken and North Augusta)"
	/*Aiken's (the city) bar smoking ban was effective 2 months before the county's, and North Augusta's was effective 1 month before the county's so don't need to do anything...*/
replace county_name = "East Baton Rouge Parish" if county_name == "Baton Rouge/East Baton Rouge Parish (except cities of Baker, Zachary, and Central)"
	/*county ban effective date is 2018m06 so not in sample period so don't need to do anything*/

gen flag_county_notes = .
replace flag_county_notes = 1 if county_name != county_name_notes



*change different county spellings/names by hand to merge with the ansi county codes dataset
replace county_name = "Doña Ana County" if county_name == "Dona Ana County" & state == "NM"	
replace county_name = "Anchorage Municipality" if county_name == "Anchorage" & state == "AK"
replace county_name = "Juneau City and Borough" if county_name == "Juneau" & state == "AK"
replace county_name = "Sitka City and Borough" if county_name == "Sitka" & state == "AK"
replace county_name = "Skagway Municipality" if county_name == "Skagway Borough" & state == "AK"
replace county_name = "San Francisco County" if county_name == "San Francisco" & state == "CA"
replace county_name = "Honolulu County" if county_name == "Honolulu" & state == "HI"
replace county_name = "Nantucket County" if county_name == "Nantucket" & state == "MA"
replace county_name = "Baltimore city" if county_name == "Baltimore" & state == "MD"
replace county_name = "St. Louis city" if county_name == "St. Louis" & state == "MO"

expand 5 if county_name == "New York City"
bys county_name state: gen temp_num = _n
tab temp_num

replace county_name = "New York County" if county_name == "New York City" & state == "NY" & temp_num == 1
replace county_name = "Kings County" if county_name == "New York City" & state == "NY" & temp_num == 2
replace county_name = "Bronx County" if county_name == "New York City" & state == "NY" & temp_num == 3
replace county_name = "Richmond County" if county_name == "New York City" & state == "NY" & temp_num == 4
replace county_name = "Queens County" if county_name == "New York City" & state == "NY" & temp_num == 5

drop temp_num

* merge in county codes so you also have counties without smoking bans (aka all the counties in the u.s.)
merge m:1 county_name state using "$build_data/ansi_county_codes_2010_clean.dta"
drop _merge

save "$build_data/smoke_free_laws_1jul2018_counties.dta", replace

********************************************************************
**** merge city, county, and state-level ban data for treatment ****
********************************************************************
merge m:1 state using "$build_data/smoke_free_laws_1jul2018_states.dta"

* you need county/state codes to make sure you're including places that don't have smoking bans!

* places that didn't match with the using data are in states that haven't passed a smoking ban in a bar/restaurant
tab state if _merge == 1

drop _merge

* expand the dataset to be a time series
gen data_start = ym(2004, 01)
format data_start %tm 

* expand to be 9 years x 12 months/year = 108 months and make it be monthly
expand 108
bysort fips_state_code fips_county_code: gen time_moyr = data_start + _n - 1
format time_moyr %tm


*make indicators for bar/restaurant bans effective
local localities = "county state"
foreach locality of local localities {
	gen `locality'_bar_ban = .
	replace `locality'_bar_ban = 1 if b_`locality'_entry_moyr <= time_moyr
	replace `locality'_bar_ban = 0 if b_`locality'_entry_moyr > time_moyr
	label variable `locality'_bar_ban "=1 if bar ban effective in `locality'"
	gen `locality'_restaurant_ban = .
	replace `locality'_restaurant_ban = 1 if r_`locality'_entry_moyr <= time_moyr
	replace `locality'_restaurant_ban = 0 if r_`locality'_entry_moyr > time_moyr
	label variable `locality'_restaurant_ban "=1 if restaurant ban effective in `locality'"
	gen `locality'_restaurant_ban_v1 = .
	replace `locality'_restaurant_ban_v1 = 1 if `locality'_restaurant_ban == 1 & `locality'_bar_ban == 0
	replace `locality'_restaurant_ban_v1 = 0 if `locality'_restaurant_ban == 0 | `locality'_bar_ban == 1
	label variable `locality'_restaurant_ban_v1 "=1 if ONLY restaurant ban effective in `locality'"
	}

local types = "bar restaurant"

* instead of changing values of county_bar_ban, just going to make a new variable that represents the county being subject to a bar ban
foreach type of local types {
	gen subject_county_`type'_ban = county_`type'_ban
	label variable subject_county_`type'_ban "=1 if locality subject to a `type' ban"
	
	* make subject_county_`type'_ban = 1 if the state has a `type' ban
	replace subject_county_`type'_ban = 1 if state_`type'_ban == 1
	}
	
gen subject_county_restaurant_ban_v1 = county_restaurant_ban_v1
label variable subject_county_restaurant_ban_v1 "=1 if locality ONLY subject to a restaurant ban"

replace subject_county_restaurant_ban_v1 = 1 if state_restaurant_ban_v1 == 1
replace subject_county_restaurant_ban_v1 = 0 if subject_county_bar_ban == 1

tab subject_county_bar_ban subject_county_restaurant_ban_v1

* merge in the collapsed city data
merge 1:1 fips_state_code fips_county_code time_moyr using "$build_data/smoking_bans_cities_collapsed.dta"

* all the using observations merged and that was the goal
drop _merge

sort fips_state_code fips_county_code time_moyr

*** now replace the treatment variables (keep the variable names everything will just be saved as a different dataset) with the fractions as appropriate ***
* first replace the fraction variable with 0s for all the counties that had no cities implementing smoking bans
replace sub_co_fraction_bar_ban = 0 if sub_co_fraction_bar_ban == .
replace sub_co_fraction_restaurant_ban = 0 if sub_co_fraction_restaurant_ban == .
replace sub_co_fraction_rest_ban_v1 = 0 if sub_co_fraction_rest_ban_v1 == .

replace subject_county_bar_ban = sub_co_fraction_bar_ban if subject_county_bar_ban == 0 & sub_co_fraction_bar_ban > 0
replace subject_county_restaurant_ban = sub_co_fraction_restaurant_ban if subject_county_restaurant_ban == 0 & sub_co_fraction_restaurant_ban > 0
replace subject_county_restaurant_ban_v1 = sub_co_fraction_rest_ban_v1 if subject_county_restaurant_ban_v1 == 0 & sub_co_fraction_rest_ban_v1 > 0
* need to subtract the fraction subject to a bar and restaurant ban from the restaurant-only variable for counties that had bar/restaurant bans or restaurant-only bans
replace subject_county_restaurant_ban_v1 = 1 - subject_county_bar_ban if subject_county_restaurant_ban_v1 == 1
tab subject_county_restaurant_ban_v1 if subject_county_bar_ban == 1
replace subject_county_restaurant_ban_v1 = 0 if subject_county_bar_ban == 1
tab subject_county_bar_ban if subject_county_restaurant_ban_v1 == 1
gen add_test = subject_county_bar_ban + subject_county_restaurant_ban_v1
sum add_test, detail

* hand code the values for the special indiana counties
replace subject_county_bar_ban = max(0, subject_county_bar_ban + sub_co_fraction_bar_ban_insp) if flag_indiana_special == 1 & county_bar_ban == 1
replace subject_county_restaurant_ban = max(0, subject_county_restaurant_ban + sub_co_fraction_rest_ban_insp) if flag_indiana_special == 1 & county_restaurant_ban == 1
replace subject_county_restaurant_ban_v1 = subject_county_restaurant_ban - subject_county_bar_ban if flag_indiana_special == 1

* only keep the essential variables
keep fips_state_code fips_county_code time_moyr subject_county_bar_ban subject_county_restaurant_ban subject_county_restaurant_ban_v1 b_county_entry_moyr b_state_entry_moyr b_city_entry_moyr_min b_city_entry_moyr_avg b_city_entry_moyr_all r_county_entry_moyr r_state_entry_moyr r_city_entry_moyr_min r_city_entry_moyr_avg r_city_entry_moyr_all

* make effective date variables (50% of county, any part of county, and all of county)
gen bar_ban_first_eff_min = min(b_county_entry_moyr, b_state_entry_moyr, b_city_entry_moyr_min)

gen bar_ban_first_eff_avg = min(b_county_entry_moyr, b_state_entry_moyr, b_city_entry_moyr_avg)

gen bar_ban_first_eff_max = min(b_county_entry_moyr, b_state_entry_moyr, b_city_entry_moyr_all)

gen rest_ban_first_eff_min = min(r_county_entry_moyr, r_state_entry_moyr, r_city_entry_moyr_min)

gen rest_ban_first_eff_avg = min(r_county_entry_moyr, r_state_entry_moyr, r_city_entry_moyr_avg)

gen rest_ban_first_eff_max = min(r_county_entry_moyr, r_state_entry_moyr, r_city_entry_moyr_all)

format bar_ban_first_eff_min %tm
format bar_ban_first_eff_avg %tm
format bar_ban_first_eff_max %tm

format rest_ban_first_eff_min %tm
format rest_ban_first_eff_avg %tm
format rest_ban_first_eff_max %tm

* make always-treated variable
gen flag_first_period_moyr = 1 if time_moyr == tm(2004m1)
replace flag_first_period_moyr = 0 if time_moyr != tm(2004m1)
label variable flag_first_period_moyr "=1 if start of sample period (monthly)"

gen flag_first_period_qyr = 1 if time_moyr == tm(2004m3)
replace flag_first_period_qyr = 0 if time_moyr != tm(2004m3)
label variable flag_first_period_qyr "=1 if start of sample period (quarterly)"

gen flag_first_period_year = 1 if time_moyr == tm(2004m12)
replace flag_first_period_year = 0 if time_moyr != tm(2004m12)
label variable flag_first_period_year "=1 if start of sample period (annual)"

bysort fips_state_code fips_county_code: egen always_treated_moyr = max(flag_first_period_moyr*subject_county_bar_ban)
label variable always_treated_moyr "=1 if county is 100% covered for entire sample period (monthly)"

bysort fips_state_code fips_county_code: egen always_treated_year = max(flag_first_period_year*subject_county_bar_ban)
label variable always_treated_year "=1 if county is 100% covered for entire sample period (annual)"

bysort fips_state_code fips_county_code: egen never_treated_temp = max(subject_county_bar_ban)
gen never_treated = 0
replace never_treated = 1 if never_treated_temp == 0
drop never_treated_temp
label variable never_treated "=1 if county is never covered during entire sample period"

bysort fips_state_code fips_county_code: egen never_treated_temp = max(subject_county_restaurant_ban_v1)
gen never_treated_r = 0
replace never_treated_r = 1 if never_treated_temp == 0
drop never_treated_temp
label variable never_treated_r "=1 if county never covered restaurant ban"


sort fips_state_code fips_county_code time_moyr


* make bar and restaurant ban indicator variables
gen subject_county_bar_ban_d = 0
replace subject_county_bar_ban_d = 1 if subject_county_bar_ban > 0
label variable subject_county_bar_ban_d "=1 if any bar ban in county"

gen subject_county_rest_ban_d = 0
replace subject_county_rest_ban_d = 1 if subject_county_restaurant_ban_v1 > 0 & subject_county_bar_ban == 0
label variable subject_county_rest_ban_d "=1 if any restaurant ban in county (and none in bars)"


* make a flag for the places with bar bans before restaurant bans
gen flag_bar_first = 0
replace flag_bar_first = 1 if fips_state_code == 17 & fips_county_code == 31
replace flag_bar_first = 1 if fips_state_code == 25 & fips_county_code == 9
replace flag_bar_first = 1 if fips_state_code == 29 & fips_county_code == 37
replace flag_bar_first = 1 if fips_state_code == 48 & fips_county_code == 43
replace flag_bar_first = 1 if fips_state_code == 48 & fips_county_code == 265
replace flag_bar_first = 1 if fips_state_code == 50 & fips_county_code == 7
replace flag_bar_first = 1 if fips_state_code == 55 & fips_county_code == 25

* make bar/restaurant ban variables for state-level-only bans
gen subject_state_bar_ban = .
replace subject_state_bar_ban = 1 if b_state_entry_moyr <= time_moyr
replace subject_state_bar_ban = 0 if b_state_entry_moyr > time_moyr
label variable subject_state_bar_ban "State-Level Bar and Restaurant Ban"
gen subject_state_restaurant_ban = .
replace subject_state_restaurant_ban = 1 if r_state_entry_moyr <= time_moyr
replace subject_state_restaurant_ban = 0 if r_state_entry_moyr > time_moyr
label variable subject_state_restaurant_ban "State-Level Restaurant Ban"
gen subject_state_restaurant_ban_v1 = .
replace subject_state_restaurant_ban_v1 = 1 if subject_state_restaurant_ban == 1 & subject_state_bar_ban == 0
replace subject_state_restaurant_ban_v1 = 0 if subject_state_restaurant_ban == 0 | subject_state_bar_ban == 1
label variable subject_state_restaurant_ban_v1 "State-Level Restaurant Only Ban"

tab subject_state_bar_ban subject_state_restaurant_ban_v1

* make an ever-treated state bar ban variable
bysort fips_state_code fips_county_code: egen ever_state_bar_ban = max(subject_state_bar_ban)
tab ever_state_bar_ban, missing
tab fips_state_code ever_state_bar_ban, missing
label variable ever_state_bar_ban "=1 if ever state bar ban"

save "$build_data/smoking_bans.dta", replace


*** create annual versions of smoking bans ***
use "$build_data/smoking_bans.dta", clear

sort fips_state_code fips_county_code time_moyr

*make annual time variables from the monthly time variables
gen year = yofd(dofm(time_moyr))

gen b_county_entry_yr = yofd(dofm(b_county_entry_moyr))

gen b_state_entry_yr = yofd(dofm(b_state_entry_moyr))

gen b_city_entry_yr_min = yofd(dofm(b_city_entry_moyr_min))

gen b_city_entry_yr_avg = yofd(dofm(b_city_entry_moyr_avg))

gen b_city_entry_yr_all = yofd(dofm(b_city_entry_moyr_all))

replace bar_ban_first_eff_min = yofd(dofm(bar_ban_first_eff_min))
format bar_ban_first_eff_min %ty

replace bar_ban_first_eff_avg = yofd(dofm(bar_ban_first_eff_avg))
format bar_ban_first_eff_avg %ty

replace bar_ban_first_eff_max = yofd(dofm(bar_ban_first_eff_max))
format bar_ban_first_eff_max %ty

/*
collapse smoking ban data to annual level
smoking ban counts as effective for the number of months of the year it was effective (e.g. if effective in july 2008, = 0 for 2000-2007, = .5 for 2008, = 1 for 2009-2012)
*/
collapse b_county_entry_yr b_state_entry_yr b_city_entry_yr_min b_city_entry_yr_avg b_city_entry_yr_all bar_ban_first_eff_min bar_ban_first_eff_avg bar_ban_first_eff_max always_treated_year never_treated never_treated_r subject_county_bar_ban subject_county_restaurant_ban subject_county_restaurant_ban_v1 subject_state_bar_ban subject_state_restaurant_ban subject_state_restaurant_ban_v1, by(fips_state_code fips_county_code year)


/*a few places will have mismatches on the bar/restaurant bans


17-31: oak park, il implemented a bar ban july 1, 2006 and a restaurant ban march 1, 2007 (cook county, il implemented both on march 15, 2007), so for 2006q3 to 2006q4, bar ban should be greater than restaurant ban

25-9: haverhill, ma implemented a bar ban september 1, 2002 and a restaurant ban march 31, 2013 (ma statewide ban effective in 2004q3), so for 2004q1 to 2004q2, bar ban should be greater than restaurant ban check other places they probly did restaurants no bars
  andover, ma restaurants august 12, 1994 bars not until 2015
  marblehead, ma restaurants april 15, 2000 bars not until 2013
  these changes were all made before 2004 so no need to change the variable, because the differences aren't due to timing in the middle of the quarter
  
  beverly, ma bars and restaurants august 1, 2003 
  gloucester, ma bars and restaurants january 18, 2001
  peabody, ma bars and restaurants august 19, 2003
  salem, ma bars and restaurants april 1, 2001
  saugus, ma bars and restaurants may 5, 2003
  danvers, ma bars and restaurants january 2, 2004
  essex, ma bars and restaurants november 3, 2003
  middleton, ma bars and restaurants february 1, 2004
  
29-37: belton, mo implemented a bar ban january 20, 2012 and a restaurant ban january 20, 2016 so for 2012q1 to 2012q4, bar ban should be greater than restaurant ban
48-43: alpine, tx implemented a bar ban july 12, 2010 but never implemented a restaurant ban bar ban should be greater than restaurant ban
48-265: kerrville, tx implemented a bar ban june 20, 2008 but never implemented a restaurant ban bar ban should be greater than restaurant ban
50-7: burlington, vt implemented a bar ban may 1, 2004 and a restaurant ban april 6, 2005, so for 2004q2 to 2005q1, bar ban should be greater than restaurant ban
55-25: madison, wi implemented a bar ban july 1, 2005 and a restaurant ban january 2, 2006, so for 2005q3 to 2005q4, bar ban should be greater than restaurant ban

*** checked these by hand 12/06/21
*/

* make a flag for the places with bar bans before restaurant bans
gen flag_bar_first = 0
replace flag_bar_first = 1 if fips_state_code == 17 & fips_county_code == 31
replace flag_bar_first = 1 if fips_state_code == 25 & fips_county_code == 9
replace flag_bar_first = 1 if fips_state_code == 29 & fips_county_code == 37
replace flag_bar_first = 1 if fips_state_code == 48 & fips_county_code == 43
replace flag_bar_first = 1 if fips_state_code == 48 & fips_county_code == 265
replace flag_bar_first = 1 if fips_state_code == 50 & fips_county_code == 7
replace flag_bar_first = 1 if fips_state_code == 55 & fips_county_code == 25



* label variables
label variable subject_county_bar_ban "Fraction bar ban"
label variable subject_county_restaurant_ban_v1 "Fraction restaurant-only ban"

save "$build_data/smoking_bans_annual.dta", replace


log close
exit
