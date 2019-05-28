//wealthRatioTable.do
//This file creates the table of average wealth ratios by decile of that same variable for each of the SCF waves
set more off
set maxvar 10000
tempfile masterTable
gen year=1
gen ratioWeightedMean=1
forvalues i=0/9 {
	gen mean_`i'=1
}
save `masterTable', replace

foreach year in 1995 1998 2001 2004 2007 {

//Preliminaries
quietly do makeVariables`year'
quietly do selectSample`year'

//Measure the deciles of the wealth wealthRatio for the sample and assign each observation to a bin.
pctile pct = wealthRatio [fweight = weight], nq(10)

forvalues P = 1/9 {
	gen wealthRatioP`P'0=pct[`P']	
}
drop pct
gen rbin = .
quietly replace rbin = 0 if wealthRatio >= 0 & wealthRatio <= wealthRatioP10 
quietly replace rbin = 1 if wealthRatio > wealthRatioP10 & wealthRatio <= wealthRatioP20
quietly replace rbin = 2 if wealthRatio > wealthRatioP20 & wealthRatio <= wealthRatioP30
quietly replace rbin = 3 if wealthRatio > wealthRatioP30 & wealthRatio <= wealthRatioP40
quietly replace rbin = 4 if wealthRatio > wealthRatioP40 & wealthRatio <= wealthRatioP50
quietly replace rbin = 5 if wealthRatio > wealthRatioP50 & wealthRatio <= wealthRatioP60
quietly replace rbin = 6 if wealthRatio > wealthRatioP60 & wealthRatio <= wealthRatioP70
quietly replace rbin = 7 if wealthRatio > wealthRatioP70 & wealthRatio <= wealthRatioP80
quietly replace rbin = 8 if wealthRatio > wealthRatioP80 & wealthRatio <= wealthRatioP90
quietly replace rbin = 9 if wealthRatio > wealthRatioP90 

//For each bin/decile, measure the income-weighted wealth ratio.
forvalues R = 0/9 {
	quietly egen temp=sum(weight*wealth)   	if rbin == `R' 
	quietly egen temp2=sum(weight*aftertax) if rbin == `R' 
	quietly gen temp3 = 100*temp/temp2		if rbin == `R' 
	quietly egen mean_`R' = max(temp3)
	quietly egen temp4=sum(weight*expense) if rbin == `R'
	quietly egen temp5=sum(weight) if rbin == `R'
	quietly gen temp6 = 100*temp4/temp5
	quietly egen expense_`R'=max(temp6)
	quietly egen temp7=sum(weight*savingNow) if rbin == `R'
	quietly gen temp8=100*temp7/temp4
	quietly egen savingNow_`R'=max(temp8)
	
	drop temp temp2 temp3 temp4 temp5 temp6 temp7 temp8
}

//Measure the overall income-weighted wealth ratio.
quietly egen temp=sum(weight*wealth) 
quietly egen temp2=sum(weight*aftertax) 
quietly egen temp3=min(temp)
quietly egen temp4=min(temp2)
quietly gen ratioWeightedMean=100*temp3/temp4
drop temp temp2 temp3 temp4


//Assemble the table and write it to a LaTeX tabular file.
keep ratioWeightedMean mean_*
keep if _n==1
quietly gen year=`year'
order year ratioWeightedMean mean_0 mean_1 mean_2 mean_3 mean_4 mean_5 mean_6 mean_7 mean_8 mean_9 
format ratioWeightedMean mean_* %2.1f

append using `masterTable'
save `masterTable', replace
clear

}

use `masterTable'
sort year

//The table is ready to be exported to a LaTeX file.
listtab using wealthRatioTable.tex, delimiter("&") end("\\") replace

//The table of wealth ratios so constructed shows a clear peak in wealth in 1998/2001. One very natural hypothesis is that this reflects the stock-market boom and its subsequent collapse. To investigate
//this possibility, we recompute the table after omitting equities from the wealth calculations. We discussed these results in footnote 15 of the paper.

clear
tempfile masterTable
gen year=1
gen ratioWeightedMean=1
forvalues i=0/9 {
	gen mean_`i'=1
}
save `masterTable', replace

foreach year in 1995 1998 2001 2004 2007{

//Preliminaries
do makeVariables`year'
do selectSample`year'

//Remove directly held stocks, stock mutual funds, and brokerage call accounts from wealth and recompute the wealth ratio.
replace wealth = wealth-stocks-stmutf
replace wealthRatio=wealth/aftertax

//Measure the deciles of the wealth wealthRatio for the sample and assign each observation to a bin.
pctile pct = wealthRatio [fweight = weight], nq(10)

forvalues P = 1/9 {
	gen wealthRatioP`P'0=pct[`P']	
}
drop pct
gen rbin = .
quietly replace rbin = 0 if wealthRatio >= 0 & wealthRatio <= wealthRatioP10 
quietly replace rbin = 1 if wealthRatio > wealthRatioP10 & wealthRatio <= wealthRatioP20
quietly replace rbin = 2 if wealthRatio > wealthRatioP20 & wealthRatio <= wealthRatioP30
quietly replace rbin = 3 if wealthRatio > wealthRatioP30 & wealthRatio <= wealthRatioP40
quietly replace rbin = 4 if wealthRatio > wealthRatioP40 & wealthRatio <= wealthRatioP50
quietly replace rbin = 5 if wealthRatio > wealthRatioP50 & wealthRatio <= wealthRatioP60
quietly replace rbin = 6 if wealthRatio > wealthRatioP60 & wealthRatio <= wealthRatioP70
quietly replace rbin = 7 if wealthRatio > wealthRatioP70 & wealthRatio <= wealthRatioP80
quietly replace rbin = 8 if wealthRatio > wealthRatioP80 & wealthRatio <= wealthRatioP90
quietly replace rbin = 9 if wealthRatio > wealthRatioP90 

//For each bin/decile, measure the income-weighted wealth ratio.
forvalues R = 0/9 {
	quietly egen temp=sum(weight*wealth)   	if rbin == `R' 
	quietly egen temp2=sum(weight*aftertax) if rbin == `R' 
	quietly gen temp3 = 100*temp/temp2		if rbin == `R' 
	quietly egen mean_`R' = max(temp3)
	drop temp temp2 temp3
}

//Measure the overall income-weighted wealth ratio.
quietly egen temp=sum(weight*wealth) 
quietly egen temp2=sum(weight*aftertax) 
quietly egen temp3=min(temp)
quietly egen temp4=min(temp2)
quietly gen ratioWeightedMean=100*temp3/temp4
drop temp temp2 temp3 temp4

//Assemble the table and write it to a LaTeX tabular file.
keep ratioWeightedMean mean_*
keep if _n==1
quietly gen year=`year'
order year ratioWeightedMean mean_0 mean_1 mean_2 mean_3 mean_4 mean_5 mean_6 mean_7 mean_8 mean_9 
format ratioWeightedMean mean_* %2.1f

append using `masterTable'
save `masterTable', replace
clear

}

use `masterTable'
sort year

//The table is ready to be exported to a LaTeX file. This does _not_ get included in the paper.
listtab using bondRatioTable.tex, delimiter("&") end("\\") replace

