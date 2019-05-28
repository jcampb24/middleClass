//whySave.do
// This file calcualtes reasons for saving from x3006, x3007, etc.
set maxvar 10000
local years 1995 1998 2001 2004 2007
local numberOfYears : word count `years'

//Set up a matrix for storing the results.
matrix whySave=J(17,`numberOfYears',0)
matrix rownames whySave = retirementAndEstate retirement estate ///
	precaution unemployment illness emergencies liquidity ///
	term childEducation adultEducation barmitzvah firsthome secondhome automobile travel funeral
matrix colnames whySave = `years'

//Set up an associative array to hold the table's row labels.
mata:
	rowlabels=asarray_create()
	asarray(rowlabels,"precaution","\\ Precaution")
	asarray(rowlabels,"unemployment","\hspace{20pt} Unemployment")
	asarray(rowlabels,"illness","\hspace{20pt} Illness")
	asarray(rowlabels,"emergencies","\hspace{20pt} Emergencies")
	asarray(rowlabels,"liquidity","\hspace{20pt} Liquidity")
	asarray(rowlabels,"term","\\ Anticipated Expenditure")
	asarray(rowlabels,"childEducation","\hspace{20pt}Childrens' Education")
	asarray(rowlabels,"adultEducation","\hspace{20pt}Own Education")
	asarray(rowlabels,"barmitzvah","\hspace{20pt}Bar Mitzvah and other Ceremonies")
	asarray(rowlabels,"firsthome","\hspace{20pt}First Home")
	asarray(rowlabels,"secondhome","\hspace{20pt}Second Home")
	asarray(rowlabels,"automobile","\hspace{20pt}Automobile")
	asarray(rowlabels,"travel","\hspace{20pt}Travel")
	asarray(rowlabels,"funeral","\hspace{20pt}Funeral Expenses")
	asarray(rowlabels,"retirementAndEstate","Retirement \& Estate")
	asarray(rowlabels,"retirement","\hspace{20pt} Retirement")
	asarray(rowlabels,"estate","\hspace{20pt} Estate")

end

foreach year in `years' {
	//Preliminaries. Use |makeVariablesYEAR.do| and |selectSampleYEAR.do| to get things started.
	do makeVariables`year'
	do selectSample`year'
	
	//Saving for unemployment
	gen unemployment=(x3006==23|x3007==23|x7513==23|x7514==23 | x7515==23)
	if `year'>1995 {
		replace unemployment= (unemployment | x6848==23)
	}
	
	//Saving for illness
	gen illness=(x3006==24 | x3007==24 | x7513==24 | x7514==24)
	if `year'>1995 {
		replace illness= (illness | x6848==24)
	}
	
	//Saving for emergencies
	gen emergencies=(x3006==25 | x3007==25 | x7513==25 | x7514==25)
	if `year'>1995 {
		replace emergencies = (emergencies | x6848==25)
	}
	
	//Saving for liquidity
	gen liquidity=(x3006==92 | x3007==92 | x7513==92 | x7514==92 | x7515==92)
	if `year'>1995 {
		replace liquidity = (liquidity | x6848==92)
	}
	
	//All precautionary savings motives
	gen precaution = (unemployment | illness | emergencies | liquidity)

	//Term saving motives
	// Education of children
	gen childEducation=(x3006==1 | x3007==1 | x7513==1 | x7514==1 | x7515==1)
	if `year'>1995 {
		replace childEducation = (childEducation | x6848==1)
	}
	
	//Education of Adults
	gen adultEducation=(x3006==2 | x3007==2 | x7513==2 | x7514==2 | x7515==2)
	if `year'>1995 {
		replace adultEducation = (adultEducation | x6848==2)
	}
	
	//Bar Mitzvah and other Ceremonies
	gen barmitzvah=(x3006==5 | x3007==5 | x7513==5 | x7514==5 | x7515==5)
	if `year'>1995 {
		replace barmitzvah = (barmitzvah | x6848==5)
	}
	
	//First Home
	gen firsthome = (x3006==11 | x3007==11 | x7513==11 | x7514==11 | x7515==11)
	if `year'>1995 {
		replace firsthome = (firsthome | x6848==11)
	}
	
	//Second Home
	gen secondhome = (x3006==12 | x3007==12 | x7513==12 | x7514==12 | x7515==12)
	if `year'>1995 {
		replace secondhome = (secondhome | x6848==12)
	}
	
	//Automobile
	gen automobile = (x3006==13 | x3007==13 | x7513==13 | x7514==13 | x7515==13)
	if `year'>1995 {
		replace automobile = (automobile | x6848==13)
	}
	
	//Travel
	gen travel = (x3006==15 | x3007==15 | x7513==15 | x7514==15 | x7515==15)
	if `year'>1995 {
		replace travel = (travel | x6848==15)
	}
	
	//Funeral
	gen funeral = (x3006==17 | x3007==17 | x7513==17 | x7514==17 | x7515==17)
	if `year'>1995 {
		replace funeral = (funeral | x6848==17)
	}
	
	//All term saving motives
	gen term = (childEducation | adultEducation | barmitzvah | firsthome | secondhome | automobile | travel | funeral)

	//Retirement and estate saving
	gen retirementAndEstate=(x3006==3 | x3006==22) ///
		+(x3007==3 | x3007==22) ///
		+(x7513==3 | x7513==22) ///
		+(x7514==3 | x7514==22) ///
		+(x7515==3 | x7515==22) 
	if `year'>1995{
		replace retirementAndEstate = retirementAndEstate+(x6848==3 | x6848==22)
	}	
	
	replace retirementAndEstate = retirementAndEstate>=1
	
	//Retirement saving
	gen retirement=(x3006==22 | x3007==22 | x7513==22 | x7514==22 | x7515==22)
	if `year'>1995{
		replace retirement = (retirement==1 | x6848==22 )
	}	
	
	//Estate saving
	gen estate=(x3006==3 | x3007==3 | x7513==3 | x7514==3 | x7515==3)
	if `year'>1995{
		replace estate = (estate==1 | x6848==3)
	}
		
		
	//Summarize the results and store them.
	foreach x in precaution unemployment illness emergencies liquidity ///
		retirementAndEstate retirement estate ///
		term childEducation adultEducation barmitzvah firsthome secondhome automobile travel funeral {
			quietly sum `x' [fweight=weight]
			matrix whySave[rownumb(whySave,"`x'"),colnumb(whySave,"`year'")]=r(mean)
	}
	
	
	drop unemployment illness emergencies liquidity precaution ///
		retirementAndEstate retirement estate ///
		childEducation adultEducation barmitzvah firsthome secondhome automobile travel funeral term
	
}

//Write the output to a LaTeX table.

mata:

	//Retrieve required information from the data workspace
	whySave=st_matrix("whySave")
	
	whySaveRowNames=st_matrixrowstripe("whySave")
	yearList=st_local("years")
	
	//Create the |tabular| environment's opening delimiter and its header lines.
	years=tokens(yearList);
	line0=sprintf("\\begin{tabular}{l*{%2.0f}{c}}",cols(whySave))
	line1=" "
	for(j=1;j<=cols(years);j++){
		line1=line1+" & "+years[j]
	}
	line1=line1+"\\ \hline"
		
	//Delete the output file if it already exist, open it, and write the header lines.		
	unlink("whySave.tex")
	f1=fopen("whySave.tex","w")
	
	fput(f1,line0)
	fput(f1,line1)
	
	//Write the actual results to the output files.
	for(i=1;i<=rows(whySave);i++) {
		fwrite(f1,asarray(rowlabels,whySaveRowNames[i,2]))
		for(j=1;j<=cols(whySave);j++) {
			fwrite(f1,"&")
			if(100*whySave[i,j]<10) {
				thisString=sprintf("%3.1f",100*whySave[i,j])
			} else {
				tensDigit=trunc(100*whySave[i,j]/10);
				remainder=100*whySave[i,j]-10*tensDigit
				thisString=sprintf("\\makebox[0pt][r]{%1.0f}%3.1f",tensDigit,remainder)
			}
			fwrite(f1,thisString)	
		}
		fput(f1,"\\")
	}
	//Write the tabular environment's closing delimiter and close the output files.
	fput(f1,"\end{tabular}")
	fclose(f1)

end

