//recordCountTable.do
//This program creates the table that displays the number 
//records in the initial SCF sample and the number remaining after each of the applied sample selection criteria.

set more off
set maxvar 10000

tempfile masterTable
gen linkvariable=_n
sort linkvariable

save `masterTable', replace

foreach year in 1995 1998 2001 2004 2007{
do makeVariables`year'
do selectSample`year'

//Keep the sample count variables and a single observation. Use this to create the table.
keep nrecords* 
keep if _n==1
order nrecordsStart nrecordsNotImputed nrecordsAge nrecordsNoTANF nrecordsNonPoverty nrecordsWealth nrecordsSelfEmployed 
xpose, clear
format v1 %4.0f

gen labels=""
replace labels="Records$^{\textrm{(ii)}}$" if _n==1
replace labels = "\hspace{20pt}  without imputed variables," if _n==2
replace labels = " \hspace{20pt} \& with $25\leq\textrm{age}\leq 64$," if _n==3
replace labels = " \hspace{20pt} \& that received no SNAP," if _n==4
replace labels = " \hspace{20pt} \& with income $>$ poverty line," if _n==5
replace labels = " \hspace{20pt} \& with wealth $<$ 95th percentile, and" if _n==6
replace labels = " \hspace{20pt} \& are not self-employed." if _n==7


rename v1 v`year'
gen linkvariable=_n
order linkvariable labels v`year'
sort linkvariable

merge 1:1 linkvariable using `masterTable'
drop _merge

sort linkvariable
save `masterTable', replace

clear

}

use `masterTable'
drop linkvariable
order labels v1995 v1998 v2001 v2004 v2007

//The table is ready for export.
listtab using scfRecords.tex, delimiter("&") end("\\") replace


