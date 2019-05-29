//termSavingRatesRates.do
// This file compiles the frequency of term saving.

//set maxvar 10000
pause on
local years 1995 1998 2001 2004 2007 
local numberOfYears : word count `years'

//Set up a matrix for storing the results.
matrix termSavingRates=J(3,`numberOfYears',.)
matrix rownames termSavingRates = expense savingNow savingDone
matrix colnames termSavingRates = `years'

//Set up an associative array to hold the table's row labels.
mata:
	rowlabels=asarray_create()
	asarray(rowlabels,"expense","Foresees Expense")
	asarray(rowlabels,"savingNow","Saving Now")
	asarray(rowlabels,"savingDone","Saving Complete")
end

foreach year in `years' {
	//Preliminaries. Use |makeVariables.do| and |selectSample.do| to get things started.
	do makeVariables`year'
	do selectSample`year'
	
	local vars expense savingNow

	if year==2007 | year == 2010 | year == 2013 {
		local vars `vars' savingDone
	}

	foreach x in `vars' {
		quietly sum `x'
		matrix termSavingRates[rownumb(termSavingRates,"`x'"),colnumb(termSavingRates,"`year'")]=r(mean)
	}
		
}

//Report the results.

mata:

//Retrieve required information from the data workspace
	termSavingRates=st_matrix("termSavingRates")
	
	termSavingRatesRowNames=st_matrixrowstripe("termSavingRates")
	yearList=st_local("years")
	
	//Create the |tabular| environment's opening delimiter and its header lines.
	years=tokens(yearList);
	line0=sprintf("\\begin{tabular}{l*{%2.0f}{c}}",cols(termSavingRates))
	line1=" "
	for(j=1;j<=cols(years);j++){
		line1=line1+" & "+years[j]
	}
	line1=line1+"\\ \hline"
		
	//Delete the output files if they already exist, open them, and write the header lines.		
	unlink("termSavingRates.tex")
	f1=fopen("termSavingRates.tex","w")
	
	fput(f1,line0)
	fput(f1,line1)
	
	//Write the actual results to the output files.
	for(i=1;i<=rows(termSavingRates);i++) {
		fwrite(f1,asarray(rowlabels,termSavingRatesRowNames[i,2]))
		for(j=1;j<=cols(termSavingRates);j++) {
			fwrite(f1,"&")
			thisString=sprintf("%3.1f",100*termSavingRates[i,j])
			fwrite(f1,thisString)	
		}
		fput(f1,"\\")
	}
	//Write the tabular environment's closing delimiter and close the output files.
	fput(f1,"\end{tabular}")
	fclose(f1)





end
