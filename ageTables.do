//ageTables.do
//This do file calculates the tables of average ages and expenditure frequencies by age.
//set maxvar 10000
pause off
set maxvar 10000
local years 1995 1998 2001 2004 2007 
local numberOfYears : word count `years'

//\section{Storage Matrix Preparation}
// Before tabulating the results, we create matrices to store them.

//\subsection{Average Age by Expenditure}
//The first table calculates households' average ages by expenditure type. We begin with the creation of a matrix to store the results.
matrix averageAge=J(3,3*`numberOfYears',0)

//We always reference matrix elements by their row and column names instead of their positions. The row names are the expenditures and the column names give the
// saving category concatinated with the SCF year.
matrix rownames averageAge = home edu med
local averageAgeColumnNamesAll
local averageAgeColumnNamesSaving
local averageAgeColumnNamesNotSaving

foreach year in `years'{
	local averageAgeColumnNamesAll 			`averageAgeColumnNamesAll'	 		all`year' 
	local averageAgeColumnNamesSaving 		`averageAgeColumnNamesSaving' 		savingNow`year' 
	local averageAgeColumnNamesNotSaving	`averageAgeColumnNamesNotSaving'	notSavingNow`year'
}

matrix colnames averageAge = `averageAgeColumnNamesAll' `averageAgeColumnNamesSaving' `averageAgeColumnNamesNotSaving'


//While we are at it, we set up an associative array to map the short row names used to identify the three different expenditures into more descriptive lables suitable for
//a LaTeX table.

mata:
	rowlabels=asarray_create()
	asarray(rowlabels,"home","\hspace{12pt}Home Purchase")
	asarray(rowlabels,"edu","\hspace{12pt}Education")
	asarray(rowlabels,"med","\hspace{12pt}Medical Care")
end

//\subsection{Expenditure Frequency by Age Group}
//The second table reports the frequency of the three major expenses within the households reporting some major expense overall and in eight five-year age bins,
// 25-29, 30-34, ..., 60-64.
matrix expenditureFrequency=J(9,3*`numberOfYears',0)
matrix rownames expenditureFrequency = All 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64
local expenditureFrequencyColNamesH
local expenditureFrequencyColNamesE
local expenditureFrequencyColNamesM

foreach year in `years'{
	local expenditureFrequencyColNamesH `expenditureFrequencyColNamesH' home`year' 
	local expenditureFrequencyColNamesE  `expenditureFrequencyColNamesE'  edu`year' 
	local expenditureFrequencyColNamesM   `expenditureFrequencyColNamesM'  med`year'
}
matrix colnames expenditureFrequency = `expenditureFrequencyColNamesH' `expenditureFrequencyColNamesE' `expenditureFrequencyColNamesM'

//\subsection{Saving Frequencies}
//The third table reports the fraction of households with a forecastable expenditure in the three major categories that are saving now overall and in the eight five-year age bins.
matrix savingFrequency=J(9,3*`numberOfYears',0)
matrix rownames savingFrequency = All 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64
matrix colnames savingFrequency = `expenditureFrequencyColNamesH' `expenditureFrequencyColNamesE' `expenditureFrequencyColNamesM'

//\section{Calculation of results}

//To make the tables, we cycle through the years constructing the results and placing them in |averageAge|, |expenditureFrequency|, |savingFrequency|, |averageAgeSE|, |expenditureFrequencySE|, and |savingFrequencySE|.
foreach year in `years' {
	//Preliminaries. Use |makeVariables.do| and |selectSample.do| to get things started.
	do makeVariables`year'
	do selectSample`year'
	
	/*
	replace expense=(home+education+medical==1) & savingNow
	gen home1 = home==1 & education+medical==0 & savingNow
	gen education1 = education==1 & home+medical==0 & savingNow
	gen medical1 = medical==1 & home+education==0 & savingNow
	replace home=home1
	replace education=education1
	replace medical=medical1
	*/
	replace home=home & savingNow
	replace education = education & savingNow
	replace medical = medical & savingNow
	
	//Results for table of average ages by expenditure.
	quietly sum age if home==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"home"),colnumb(averageAge,"all`year'")]=r(mean)
	
	quietly sum age if education==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"edu"),colnumb(averageAge,"all`year'")]=r(mean)
	
	quietly sum age if medical==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"med"),colnumb(averageAge,"all`year'")]=r(mean)
	
	quietly sum age if home==1 & savingNow==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"home"),colnumb(averageAge,"savingNow`year'")]=r(mean)
	
	quietly sum age if education==1 & savingNow==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"edu"),colnumb(averageAge,"savingNow`year'")]=r(mean)
	
	quietly sum age if medical==1 & savingNow==1 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"med"),colnumb(averageAge,"savingNow`year'")]=r(mean)
	
	quietly sum age if home==1 & savingNow==0 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"home"),colnumb(averageAge,"notSavingNow`year'")]=r(mean)
	
	quietly sum age if education==1 & savingNow==0 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"edu"),colnumb(averageAge,"notSavingNow`year'")]=r(mean)
	
	quietly sum age if medical==1 & savingNow==0 [fweight=weight]
	matrix averageAge[rownumb(averageAge,"med"),colnumb(averageAge,"notSavingNow`year'")]=r(mean)

	//Results for table of expenditure frequencies
	quietly sum home [fweight=weight]
	matrix expenditureFrequency[rownumb(expenditureFrequency,"All"),colnumb(expenditureFrequency,"home`year'")]=100*r(mean)
	
	quietly sum education [fweight=weight]
	matrix expenditureFrequency[rownumb(expenditureFrequency,"All"),colnumb(expenditureFrequency,"edu`year'")]=100*r(mean)
	
	quietly sum medical [fweight=weight]
	matrix expenditureFrequency[rownumb(expenditureFrequency,"All"),colnumb(expenditureFrequency,"med`year'")]=100*r(mean)
	
	forvalues lowerAge = 25 30 to 60 {
	
		local upperAge=`lowerAge'+4
		local rowName "`lowerAge'-`upperAge'"
		
		quietly sum home if age>=`lowerAge' & age<=`upperAge' [fweight=weight]
		matrix expenditureFrequency[rownumb(expenditureFrequency,"`rowName'"),colnumb(expenditureFrequency,"home`year'")]=100*r(mean)
		
		quietly sum education if age>=`lowerAge' & age<=`upperAge' [fweight=weight]
		matrix expenditureFrequency[rownumb(expenditureFrequency,"`rowName'"),colnumb(expenditureFrequency,"edu`year'")]=100*r(mean)
		
		quietly sum medical if age>=`lowerAge' & age<=`upperAge' [fweight=weight]
		matrix expenditureFrequency[rownumb(expenditureFrequency,"`rowName'"),colnumb(expenditureFrequency,"med`year'")]=100*r(mean)
	
	}
		
	//This completes the tabulation of results for this wave of the SCF. Clear the data set and proceed to the next wave.
	clear
}

//\section{Reporting}
//For ease of inspection, we write each of these tables to an eponymous |.tex| file.

//Average age by expenditure.
mata:
	//Retrieve required information from the data workspace
	averageAge=st_matrix("averageAge")
	
	averageAgeRowNames=st_matrixrowstripe("averageAge")
	yearList=st_local("years")
	
	//Create the |tabular| environment's opening delimiter and its header lines.
	years=tokens(yearList);
	line0=sprintf("\\begin{tabular}{l|*{%2.0f}{c}|*{%2.0f}{c}|*{%2.0f}{c}}",cols(averageAge)/3,cols(averageAge)/3,cols(averageAge)/3)
	line1=" & \multicolumn{"+strofreal(cols(years))+"}{c}{All Households} & \multicolumn{"+strofreal(cols(years))+"}{c}{Saving Households} & \multicolumn{"+strofreal(cols(years))+"}{c}{Non-Saving Households}" 
	line2="Expense for "
	for (i=1;i<=3;i++){
		for(j=1;j<=cols(years);j++){
			line2=line2+" & "+years[j]
		}
	}
	line1=line1+"\\"
	line2=line2+"\\"
		
	//Delete the output files if they already exist, open them, and write the header lines.		
	unlink("averageAge.tex")
	f1=fopen("averageAge.tex","w")
	
	fput(f1,line0)
	fput(f1,line1)
	fput(f1,line2)
	
	//Write the actual results to the output files.
	for(i=1;i<=rows(averageAge);i++) {
		fwrite(f1,asarray(rowlabels,averageAgeRowNames[i,2]))
		for(j=1;j<=cols(averageAge);j++) {
			fwrite(f1,"&")
			thisString=sprintf("%3.1f",averageAge[i,j])
			fwrite(f1,thisString)	
		}
		
		fput(f1,"\\")
	}
	//Write the tabular environment's closing delimiter and close the output files.
	fput(f1,"\end{tabular}")
	fclose(f1)

end

//Expenditure Frequencies
mata:
	expenditureFrequency=st_matrix("expenditureFrequency")
	
	expenditureFrequencyColNames=st_matrixcolstripe("expenditureFrequency")
	expenditureFrequencyRowNames=st_matrixrowstripe("expenditureFrequency")
	
	line1=" & \multicolumn{"+strofreal(cols(years))+"}{c}{Home Purchase} & \multicolumn{"+strofreal(cols(years))+"}{c}{Education} & \multicolumn{"+strofreal(cols(years))+"}{c}{Medical Care}" 
	line2="Age Category "
	for (i=1;i<=3;i++){
		for(j=1;j<=cols(years);j++){
			line2=line2+" & "+years[j]
		}
	}
	line1=line1+"\\"
	line2=line2+"\\ \hline"
			
	//Delete the output files if they exist, open them, and write the header lines. 
	unlink("expenditureFrequency.tex")
	f1=fopen("expenditureFrequency.tex","w")
	
	fput(f1,line0)
	fput(f1,line1)
	fput(f1,line2)
	
	//Write the actual results to the output files.
	for(i=1;i<=rows(expenditureFrequency);i++){
		
		fwrite(f1,"\hspace{12pt}")
		
		fwrite(f1,expenditureFrequencyRowNames[i,2])
		
		for(j=1;j<=cols(expenditureFrequency);j++){
			fwrite(f1,"&")
			
			thisString=sprintf("%3.1f",expenditureFrequency[i,j]);
			fwrite(f1,thisString)		
		}
		fput(f1,"\\")
		

	}
	//Close the table.
	fput(f1,"\end{tabular}")
	fclose(f1)

end

//Expenditure-specific tables for the slides.

mata:

	//Home purchase	
	line0=sprintf("\\begin{tabular}{l*{%2.0f}{r}}",cols(years))
	line2="Age of Head "
	
	for(j=1;j<=cols(years);j++){
		line2=line2+" & "+years[j]
	}
	line2=line2+"\\"
	
	unlink("homeFrequency.tex")
	f1=fopen("homeFrequency.tex","w")

	fput(f1,line0)
	fput(f1,line2)
	
	for(i=1;i<=rows(expenditureFrequency);i++){
	
		fwrite(f1,"\hspace{12pt}")
		fwrite(f1,expenditureFrequencyRowNames[i,2])
		for(j=1;j<=cols(years);j++){
			fwrite(f1,"&")
			
			thisString=sprintf("%3.1f",expenditureFrequency[i,j]);
			fwrite(f1,thisString)
		}
		fput(f1,"\\")
		
	}
	fput(f1,"\end{tabular}")
	fclose(f1)
	
	//Education
	unlink("educationFrequency.tex")
	f1=fopen("educationFrequency.tex","w")

	fput(f1,line0)
	fput(f1,line2)
	
	for(i=1;i<=rows(expenditureFrequency);i++){
	
		fwrite(f1,"\hspace{12pt}")
		fwrite(f1,expenditureFrequencyRowNames[i,2])
		for(j=cols(years)+1;j<=2*cols(years);j++){
			fwrite(f1,"&")
			
			thisString=sprintf("%3.1f",expenditureFrequency[i,j]);
			fwrite(f1,thisString)
		}
		fput(f1,"\\")
		
	}
	fput(f1,"\end{tabular}")
	fclose(f1)
	
	//Medical Expenses
	unlink("medicalFrequency.tex")
	f1=fopen("medicalFrequency.tex","w")

	fput(f1,line0)
	fput(f1,line2)
	
	for(i=1;i<=rows(expenditureFrequency);i++){
	
		fwrite(f1,"\hspace{12pt}")
		fwrite(f1,expenditureFrequencyRowNames[i,2])
		for(j=2*cols(years)+1;j<=3*cols(years);j++){
			fwrite(f1,"&")
			
			thisString=sprintf("%3.1f",expenditureFrequency[i,j]);
			fwrite(f1,thisString)
		}
		fput(f1,"\\")
		
	}
	fput(f1,"\end{tabular}")
	fclose(f1)
	

end

