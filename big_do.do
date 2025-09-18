/*
Big do file for Smoking and Drinking project

Anne Burton
12/01/21
*/

clear all 
capture log close

* This file calls all the scripts
local anne_base				"/Users/anneburton/Library/CloudStorage/Dropbox/smoking_bans/jle_final"
local nielsen_base			"/Users/anneburton/Documents/nielsen"

cd `anne_base'
global base `anne_base' // Change the base global to the correct base path
global nielsen_base `nielsen_base'

include "config.do"

*** Build BRFSS data (monthly)
include "$build/build_brfss_individual_data.do"

*** Build smoking bans laws
include "$build/build_smoking_bans.do"

*** Build control variables
include "$build/build_controls.do"

*** Build Nielsen data
include "$build/build_nielsen_data.do"

*** Run BRFSS analysis
include "$analyze/analysis_sd_brfss.do"

*** Run Nielsen analysis
include "$analyze/analysis_sd_nielsen.do"

*** Run BRFSS twfe new methods analysis
include "$analyze/analysis_sd_brfss_individual_newdid.do"

*** Run Nielsen twfe new methods analysis
include "$analyze/analysis_sd_nielsen_household_newdid.do"
