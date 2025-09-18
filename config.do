log using "$base/config.txt", text replace

/*
config.do
This file sets the working directory and installs packages required for running the code.
Anne Burton
12/01/21
*/


* Define paths

global build "$base/build"  		// This directory contains everything needed to build the analysis dataset
global analysis_data "$base/build/analysis_data"
global build_data "$base/build/build_data"
global build_data_brfss "$base/build/build_data/brfss"
global build_log "$base/build/log"
global analyze "$base/analyze"    	// This directory contains everything needed to run all analyses
global out  "$base/analyze/out"
global analyze_log "$base/analyze/log"
global adobase "$base/ado"			// All required packages will be installed locally (this script will automatically create this directory)
global nielsen_data "$nielsen_base/data/consumer_panel" // Nielsen data have to be stored on an institution-owned machine which is why they are in a different directory (directly on my institution-owned laptop instead of on my personal hard drive)


set more off
set maxvar 120000

* Install packages locally
capture mkdir "$adobase"
sysdir set PERSONAL "$adobase/ado/personal"
sysdir set PLUS     "$adobase/ado/plus"
sysdir set SITE     "$adobase/ado/site"


* Required packages
ssc install reghdfe, replace
ssc install ftools, replace
ssc install outreg
ssc install outreg2
ssc install estout, replace
ssc install erepost
ssc install bacondecomp, replace
ssc install csdid, replace
ssc install drdid, replace
ssc install bacondecomp, replace
ssc install gtools, replace
ssc install coefplot, replace
ssc install did_imputation, replace
ssc install event_plot, replace
ssc install ppml, replace
ssc install ppmlhdfe, replace
ssc install ivreg2, replace
ssc install ivreghdfe, replace
ssc install ranktest, replace
ssc install spmap, replace 
ssc install maptile, replace
maptile_install using "http://files.michaelstepner.com/geo_county2014.zip"
maptile_install using "http://files.michaelstepner.com/geo_state.zip"



* Store information about the system running the code
local variant = cond(c(MP),"MP",cond(c(SE),"SE",c(flavor)) )   

di "=== SYSTEM DIAGNOSTICS ==="
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `variant'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "=========================="

capture log close
