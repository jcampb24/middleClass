//selectSample2007.do
//This do file selects observations from the 2007 SCF for later analysis.
//This should be run after makeVariables2007.do

// Before proceeding, count the number of households in the sample.

egen nhouseholdsStart=sum(weight)
replace nhouseholdsStart=nhouseholdsStart/5 //Divide by 5 to account for duplicate replications of the same true observation.
gen nrecordsStart=_N/5

//\subsection{Imputed Values}

//Identify which houeholds have imputed values for age, the planning horizon indicator, or any of the forseeable expenditure questions
// by measuring their standard deviations within the household identifier. (Non-imputed values are identical across observations and so have zero variance.)
egen sdAge=sd(age), by(householdIdentifier)
egen sdPlanningPeriod=sd(planningPeriod), by(householdIdentifier)
egen sdExpense=sd(expense), by(householdIdentifier)
egen sdSavingNow=sd(savingNow), by(householdIdentifier)
egen sdEducation=sd(education), by(householdIdentifier)
egen sdMedical=sd(medical), by(householdIdentifier)
egen sdHome=sd(home), by(householdIdentifier)

gen imputedRHS= sdAge>0 | sdPlanningPeriod>0 | sdExpense>0 | sdSavingNow>0 | sdEducation>0 | sdMedical>0 | sdHome>0
drop sdAge sdPlanningPeriod sdExpense sdSavingNow sdEducation sdMedical sdHome

//With the weights created, we can drop observations with any imputed right-hand side variables.
drop if imputedRHS==1
drop imputedRHS

//Count the number of remaining households.
egen nhouseholdsNotImputed=sum(weight)
replace nhouseholdsNotImputed=nhouseholdsNotImputed/5
gen nrecordsNotImputed=_N/5

// We wish to analyze the wealth to income ratios for \emph{working middle class} households. Accordingly, we apply three sample selection criteria to arrive at our core sample.
//\begin{itemize}
// \item The household's head must be between 25 and 64 years old inclusive.
// \item The household should not have received UI, Food Stamps, or TANF in the year prior to the survey.
// \item The household should not be among the wealthiest 5% of remaining households.
//\end{itemize}

// After each screen, we tabulate the number of U.S. households surviving each screen by summing the given sample weights.

// \subsection{Age Screen}
// We keep only households in the working-age population. That is, their heads are between 25 and 64 years old.
gen primeAge= age>=25 & age<=64
egen temp=max(primeAge), by(householdIdentifier)
replace primeAge=temp
drop temp
keep if primeAge

egen nhouseholdsAge=sum(weight)
replace nhouseholdsAge=nhouseholdsAge/5
gen nrecordsAge=_N/5

//\subsection{Poverty Screen}
// Drop those who have received Food Stamps or TANF benefits within the last year.	
gen tanf= x5719==1
egen temp=max(tanf), by(householdIdentifier)
replace tanf=temp
drop if tanf==1
drop temp

egen nhouseholdsNoTANF=sum(weight)
replace nhouseholdsNoTANF=nhouseholdsNoTANF/5
gen nrecordsNoTANF=_N/5

//Drop those who have labor income less than the 2006 Federal poverty line(s) for householders under 65 years old. (Taken from http://www.census.gov/hhes/www/poverty/data/threshld/index.html)
gen poverty=0
replace poverty=1 if x101==1 & laborincome<10488
replace poverty=1 if x101==2 & laborincome<12201
replace poverty=1 if x101==3 & laborincome<16079
replace poverty=1 if x101==4 & laborincome<20614
replace poverty=1 if x101==5 & laborincome<24382
replace poverty=1 if x101==6 & laborincome<27560
replace poverty=1 if x101==7 & laborincome<31205
replace poverty=1 if x101==8 & laborincome<34774
replace poverty=1 if x101>=9 & laborincome<41499

//Drop if any replicate falls below the poverty line.
egen maximumPoverty=max(poverty), by(householdIdentifier)
drop if maximumPoverty==1
drop maximumPoverty

egen nhouseholdsNonPoverty=sum(weight)
replace nhouseholdsNonPoverty=nhouseholdsNonPoverty/5
gen nrecordsNonPoverty=_N/5

//\subsection{Wealth Screen}
//To eliminate the wealthy, we first calculate the 95th percentile of financial wealth \emph{using only non-imputed observations}, and we drop any household with any wealth replicate
//above that ratio.
egen imputedWealth=sd(wealth), by(householdIdentifier)
replace imputedWealth=imputedWealth>0

* Calculate the 95th percentile of wealth for the non-imputed sample.
_pctile wealth [fweight = weight] if imputedWealth==0, p(95)
gen wealthCutoff=r(r1)

gen highWealth=wealth>wealthCutoff
egen maximumHighWealth=max(highWealth), by(householdIdentifier)
drop if maximumHighWealth==1
drop maximumHighWealth

egen nhouseholdsWealth=sum(weight)
replace nhouseholdsWealth=nhouseholdsWealth/5
gen nrecordsWealth=_N/5

//\subsection{Self-employment screen}
//The final selection criterion we use removes households who report that either partner is self-employed. 
gen selfEmployed= x4106 ==2 | x4106 ==3 | x4706==2 | x4706 == 3
egen temp=max(selfEmployed), by(householdIdentifier)
replace selfEmployed=temp
drop if selfEmployed
drop temp

egen nhouseholdsSelfEmployed=sum(weight)
replace nhouseholdsSelfEmployed=nhouseholdsSelfEmployed/5
gen nrecordsSelfEmployed=_N/5
