//makeVariables2007.do
//This program loads the 2007 Survey of Consumer Finance data and generates variables of interest for later analysis.

//\section{Overhead}
//This section sets runtime options, loads the memory, and calls |bulletin.do| from the scf project to create useful aggregates.
version 12

//Load the data
use scf2007, clear

//Shift all variable names to lower case.
rename J#, lower
rename X#, lower
rename YY#, lower

//To save memory, we drop variables' original codings (which we do not use). These all start with ``|j|''.
drop j* 

//Rename the household identification variable for clarity.
rename yy1 householdIdentifier

//Measure ageand information on anticipated major expenditures. 
rename x8022 age 
gen expense=x3010==1
gen savingNow=x7186==1
gen savingDone=x7186==6

gen education=(x3011==1|x3011==2) ///
	+(x3012==1|x3012==2) ///
	+(x3013==1|x3013==2) ///
	+(x7512==1|x7512==2) ///
	+(x7511==1|x7511==2) ///
	+(x6667==1|x6667==2)
replace education=education>=1	

gen medical=(x3011==3|x3011==4|x3011==5) ///
	+(x3012==3|x3012==4|x3012==5) ///
	+(x3013==3|x3013==4|x3013==5) ///
	+(x7512==3|x7512==4|x7512==5) ///
	+(x7511==3|x7511==4|x7511==5) ///
	+(x6667==3|x6667==4|x6667==5)
replace medical=medical>=1
	
gen home=(x3011==21) ///
	+(x3012==21) ///
	+(x3013==21) ///
	+(x7512==21) ///
	+(x7511==21) ///
	+(x6667==21)
replace home=home>=1

gen burial=(x3011==23) ///
	+(x3012==23) ///
	+(x3013==23) ///
	+(x7512==23) ///
	+(x7511==23) ///
	+(x6667==23)
replace burial=burial>=1

gen travel=(x3011==26) ///
	+(x3012==26) ///
	+(x3013==26) ///
	+(x7512==26) ///
	+(x7511==26) ///
	+(x6667==26)
replace travel=travel>=1

//Measure the use of educational spending accounts (used to respond to a referee.)
gen esa = (x3732==2 | x3732==3) ///
	+ (x3738==2 | x3738==3) ///
	+ (x3744==2 | x3744==3) ///
	+ (x3750==2 | x3750==3) ///
	+ (x3756==2 | x3756==3) ///
	+ (x3762==2 | x3762==3) 
replace esa = esa>=1
	
//Measure the planning period and generate dummies based on it.
rename x3008 planningPeriod
label define planningPeriodValues 1 "Next Few Months" 2 "Next Year" 3 "Next Few Years" 4 "Next 5-10 Years" 5 "Longer than 10 Years"
label values planningPeriod planningPeriodValues
gen months=planningPeriod==1
gen nextYear=planningPeriod==2
gen fewYears=planningPeriod==3
gen fiveToTenYears=planningPeriod==4
gen overTenYears=planningPeriod==5

//\section{Labor Income Measurement}
// We use these measures to divide total income between the respondent and spouse when calculating total contributions to employer-sponsored retirement accounts.

//\subsection{respondent's Pre-Tax Labor Income}
// The variables we use to measure the respondent's pre-tax labor income are
//\begin{itemize}
//\item |x4112| is amount earned per pay period;
//\item |x4113| indicates how often respondent is paid; [1: daily; 2: weekly; 3: Monthly; 4:Monthly; 5: Quarterly; 6: Yearly; 18: Hourly; 31:Bi-monthly]
//\item |x4111| is how many weeks per year respondant works;
//\item |x4110| is how many hours per week respondant works.
//\end{itemize}

gen resp = 0
replace resp = x4112 * 5 * x4111 		if x4113 == 1
replace resp = x4112 * x4111 			if x4113 == 2
replace resp = x4112 * 26 				if x4113 == 3
replace resp = x4112 * 12 				if x4113 == 4
replace resp = x4112 * 4  				if x4113 == 5
replace resp = x4112 					if x4113 == 6 | x4113==8
replace resp = x4112 * x4110 * x4111 	if x4113 == 18
replace resp = x4112 * 24  				if x4113 == 31
replace resp = . 						if x4113 == 14 | x4113 == 22 | x4113 == -7

//If the respondent is self-employed, (|x4106| equals 2 or 3), the respondent's other pre-tax business income is in |x4131| This has the embedded code |-1| for ``Nothing''.
gen respBusiness=x4131
replace respBusiness=0 if respBusiness==-1

//\subsection{Spouse's Pre-Tax Labor Income}
// The variables we use to measure the Spouse's pre-tax labor income are
//\begin{itemize}
//\item |x4712| is amount earned per pay period;
//\item |x4713| indicates how often spouse is paid; [1: daily; 2: weekly; 3: Monthly; 4:Monthly; 5: Quarterly; 6: Yearly; 18: Hourly; 31:Bi-monthly]
//\item|x4711| is how many weeks per year spouse works;
//\item |x4710| is how many hours per week spouse works.
//\end{itemize}

gen spouse = 0
replace spouse = x4712 * 5 * x4711 		if x4713 == 1
replace spouse = x4712 * x4711 			if x4713 == 2
replace spouse = x4712 * 26 			if x4713 == 3
replace spouse = x4712 * 12 			if x4713 == 4
replace spouse = x4712 * 4 				if x4713 == 5
replace spouse = x4712 				    if x4713 == 6 | x4713==8
replace spouse = x4712 * x4710 * x4711 	if x4713 == 18
replace spouse = x4712 * 24 			if x4713 == 31
replace spouse = .						if x4713 == 14 | x4713 == 22 | x4713 == -7

//If the spouse is self-employed, (|x4706| equals 2 or 3), the spouse's other pre-tax business income is in |x4731|. This has the same embedded code as |x4131|.
gen spouseBusiness=x4731
replace spouseBusiness=0 if spouseBusiness==-1

//\section{Contributions to Employer-Sponsored Retirement Plans}
// The variables used to calculate the household's year 2006 contributions to employer-sponsored plans are
/* \begin{itemize}
\item x11041, x11141, x11241; the percentages of wages and salaries contributed by R to the first three employer-sponsored thrift or retirement plans.
\item x11042, x11142, x11242; the dollar amounts contributed by R to the first three employer sponsored thrift or retirement plans.
\item x11043, x11143, x11243; frequency codes for contribuions in x4207, x4307, and x4407. (4, month; 5, quarter; 6, year,...)
\item x11341, x11441, x11541; the percentages of wages and salaries contributed by S to the first three employer-sponsored thrift or retirement plans.
\item x11342, x11442, x11542; the dollar amounts contributed by S to the first three employer sponsored thrift or retirement plans.
\item x11343, x11443, x11543; frequency codes for contribuions in x4207, x4307, and x4407. (4, month; 5, quarter; 6, year,...)
*/
// Replace embedded codes with missing values.
mvdecode x11041 x11141 x11241 x11341 x11441 x11541, mv(-5/0)
mvdecode x11042 x11142 x11242 x11342 x11442 x11542, mv(-5/0)
mvdecode x11043 x11143 x11243 x11343 x11443 x11543, mv(-7/0)

//Calculate total retirement plan contributions for both R and S.
//The codebook allows for some fairly odd contribution schedules (e.g. ``By the job/piece''). The next code sets these to missing. 

mvdecode x11043 x11143 x11243 x11343 x11443 x11543, mv(14 22)
gen employersponsoredR1=(x11040==1)*((x11043==1)*x4111*5+(x11043==2)*52+(x11043==3)*26+(x11043==4)*12+(x11043==5)*4+(x11043==6 | x11043==8)+(x11043==11)*2+(x11043==12)*6+(x11043==18)*x4110*x4111+(x11043==31)*24)*x11042
gen employersponsoredR2=(x11140==1)*((x11143==1)*x4111*5+(x11143==2)*52+(x11143==3)*26+(x11143==4)*12+(x11143==5)*4+(x11143==6 | x11143==8)+(x11143==11)*2+(x11143==12)*6+(x11143==18)*x4110*x4111+(x11143==31)*24)*x11142
gen employersponsoredR3=(x11240==1)*((x11243==1)*x4111*5+(x11243==2)*52+(x11243==3)*26+(x11243==4)*12+(x11243==5)*4+(x11243==6 | x11243==8)+(x11243==11)*2+(x11243==12)*6+(x11243==18)*x4110*x4111+(x11243==31)*24)*x11242

egen employersponsoredR=rowtotal(employersponsoredR1 employersponsoredR2 employersponsoredR3)
//Many of the total contributions by R exceed the IRS Section 402(g) limit of \$15,000 for tax year 2006. We replace these obvious overestimations with this statuatory limit.
replace employersponsoredR=15000 if employersponsoredR>15000

//Procede to the calculations for S.
gen employersponsoredS1=(x11340==1)*((x11343==1)*x4711*5+(x11343==2)*52+(x11343==3)*26+(x11343==4)*12+(x11343==5)*4+(x11343==6 | x11343==8)+(x11343==11)*2+(x11343==12)*6+(x11343==18)*x4710*x4711+(x11343==31)*24)*x11342
gen employersponsoredS2=(x11440==1)*((x11443==1)*x4711*5+(x11443==2)*52+(x11443==3)*26+(x11443==4)*12+(x11443==5)*4+(x11443==6 | x11443==8)+(x11443==11)*2+(x11443==12)*6+(x11443==18)*x4710*x4711+(x11443==31)*24)*x11442
gen employersponsoredS3=(x11540==1)*((x11543==1)*x4711*5+(x11543==2)*52+(x11543==3)*26+(x11543==4)*12+(x11543==5)*4+(x11543==6 | x11543==8)+(x11543==11)*2+(x11543==12)*6+(x11543==18)*x4710*x4711+(x11543==31)*24)*x11542

egen employersponsoredS=rowtotal(employersponsoredS1 employersponsoredS2 employersponsoredS3)

replace employersponsoredS=15000 if employersponsoredS>15000 

//Sum the two partners' contributions to get the household's total contribution to employer-sponsored retirement plans.
gen employersponsored=employersponsoredR+employersponsoredS

//\section{AGI and Tax Measurement}
// We wish to examine the ratio of wealth to \emph{after tax} labor income, so we must arrive at a measure of taxes paid on labor income for each respondent household. 
// For this, we first measure the household's AGI and then apply the relevant tax table from 2000.
/* The variables used for this measurement are
\begin{itemize}
\item x101, number of people living in the household/primary economic unit.
\item x5744, indicator for whether the respondent's household has or expects to file a year 2000 Federal Income Tax Return
\item x5746, categorical variable indicating whether the household members file jointly, file separately, or only one files.
\item x5751, Adjusted Gross Income for households filing jointly.
\item x7651, Adjusted Gross Income for the respondent if single or filing separately.
\item x7652, Adjusted Gross Income for the Spouse if filing separately.
\end{itemize}
*/

gen tax=.

replace tax=0 if x5744==5 //Set tax to zero for households not filing.

//\subsection{Married Filing Jointly}
//Some respondents claim that ``only I file a tax return'' or ``only my spouse files a tax return.'' These calculations assume that these respondents actually are married filing jointly.
gen mfj = (x5744==1 | x5744==6) & (x5746==1 | (x5746==3 & x7020==2) | x5746==4)  // Indicator for married filing jointly.
gen agi=x5751 if mfj==1 //AGI for households filing jointly.
replace agi=x7651 if x5744==3
replace agi=x7652 if x5744==4
replace agi=0 if agi<0 & mfj==1 //Set tax to zero for households reporting negative AGI.

// Read the tax paid off of the 2006 tax table.
replace tax = agi*0.10 						if agi<=15100 				& mfj==1
replace tax = 1510.00+0.15*(agi-15100)		if agi>15100 & agi<=61300 	& mfj==1
replace tax = 8440.00+0.25*(agi-61300) 		if agi>61300 & agi<=123700 	& mfj==1
replace tax = 24040.00+0.28*(agi-123700) 	if agi>123700 & agi<=188450 & mfj==1
replace tax = 42170.00+0.33*(agi-188450)	if agi>188450 & agi<=336550 & mfj==1
replace tax = 91043.00+0.35*(agi-336550)	if agi>336550				& mfj==1
	
drop agi

//\subsection{Married Filing Separately}
gen mfs = (x5744==1 | x5744==6) & x5746==2
gen agiR=x7651 if mfs==1 //respondent's AGI
gen agiS=x7652 if mfs==1 //Spouse's AGI
replace agiR=0 if agiR<0 //Set tax to zero for negative respondent AGI
replace agiS=0 if agiS<0 //Set tax to zero for negative spouse AGI

gen taxR=.
gen taxS=.

//Read the respondent's taxes off of the 2006 tax table.
replace taxR=agiR*0.10 						if agiR<=7550					& mfs==1
replace taxR=755.00+0.15*(agiR-7550)		if agiR>7550 & agiR<=30650		& mfs==1
replace taxR=4220.00+0.25*(agiR-30650)		if agiR>30650 & agiR<=61850 	& mfs==1
replace taxR=12020.00+0.28*(agiR-61850)		if agiR>61850 & agiR<=94225		& mfs==1
replace taxR=21085.00+0.33*(agiR-94225)		if agiR>94225 & agiR<=168275	& mfs==1
replace taxR=45521.50+0.35*(agiR-168275)	if agiR>168275					& mfs==1

//Read the spouse's taxes off of the 2006 tax table.
replace taxS=agiS*0.10 						if agiS<=7550					& mfs==1
replace taxS=755.00+0.15*(agiS-7550)		if agiS>7550 & agiS<=30650		& mfs==1
replace taxS=4220.00+0.25*(agiS-30650)		if agiS>30650 & agiS<=61850 	& mfs==1
replace taxS=12020.00+0.28*(agiS-61850)		if agiS>61850 & agiS<=94225		& mfs==1
replace taxS=21085.00+0.33*(agiS-94225)		if agiS>94225 & agiS<=168275	& mfs==1
replace taxS=45521.50+0.35*(agiS-168275)	if agiS>168275					& mfs==1
 
replace tax=taxR+taxS if mfs==1
drop agiR agiS

//\subsection{Singles}
gen single=(x5744==1 | x5744==6) & x5746==0 & x101==1

gen agi=x7651 if single==1 //respondent's AGI
replace agi=0 if agi<0

replace tax = agi*0.10 						if agi<=7550					& single==1
replace tax = 755.00+0.15*(agi-7550)		if agi>7000 & agi<=30650		& single==1
replace tax = 4220.00+0.25*(agi-30650)		if agi>30650 & agi<=74200		& single==1
replace tax = 15107.50+0.28*(agi-74200)		if agi>74200 & agi<=154800		& single==1
replace tax = 37675.50+0.33*(agi-154800)	if agi>154800 & agi<=336550		& single==1
replace tax = 97653.00+0.35*(agi-336550)	if agi>336550					& single==1

drop agi

//\subsection{Heads of Household}
gen hh=(x5744==1 | x5744==6) & x5746==0 & x101>1
gen agi=x7651 if hh==1 //respondent's AGI
replace agi=0 if agi<0

replace tax = 0.10*agi						if agi<=10750					& hh==1
replace tax = 1075.00+0.15*(agi-10750)		if agi>10750 & agi<=41050		& hh==1
replace tax = 5620.00+0.25*(agi-41050)  	if agi>41050 & agi<=106000		& hh==1
replace tax = 21857.50+0.28*(agi-106000)	if agi>106000 & agi<=171650		& hh==1
replace tax = 40239.50+0.33*(agi-171650)	if agi>171650 & agi<=336550		& hh==1
replace tax = 94656.50+0.35*(agi-336550)	if agi>336550					& hh==1

drop agi

//\section{Measurement of Total Income}
//We measure total income and labor income using the sequence of roundup income questions beginning with X5701. This allows us to measure the fraction of total income from wages and salaries.
// The variables used for this task are
/* \begin{itemize}
\item X5702, wage and salary income
\item X5704, income from professional practice, business, or farm
\item X5706, income from non-taxable investments (e.g. munis)
\item X5708, other interest income
\item X5710, dividend income
\item X5712, capital gains and losses
\item X5714, income from net rent, trusts, royalties, and other investments
\item X5716, unemployment insurance and wokers compensation
\item X5718, child support and alimony received.
\item X5720, TANF, food stamps, and other welfare
\item X5722, Social Security, pensions, annuities, or other disability/retirement programs.
\item X5724, other income
\end{itemize}
*/

//\subsection{Data Cleaning}
// Two concerns arise. First, several of these variables have embedded codes.
// Second, the wage and salary variable contains some negative values. In this section, we clean the variables used before adding them up.

// We compare x5702 with the sum of |resp| and |spouse| 
//If this exceeds zero while |x5702|$\leq 0$, then replace |x5702| with this sum.
replace x5702=resp+spouse if resp+spouse>0 & x5702<=0

// Remove embedded code of -1 for ``nothing'' in x5704. Although the codebook says that the code of |-2| represents an inferred loss, the data itself has no instances of this code. We leave the reported losses in place.
replace x5704=0 if x5704==-1
//Conceptually, |x5704| should equal the sum of |respBusiness| with |spouseBusiness|. In practice they can be quite different. If both measures are non-positive, then we replace |x5704| with zero 
//, which corresponds to the assumption that business losses do not reduce the current year's tax bill. If one is zero and the other is positive, then we use the positive measure. If both are positive, then
// we use their geometric mean.
replace x5704=0 if x5704<0 & respBusiness+spouseBusiness<0
replace x5704=respBusiness+spouseBusiness if respBusiness+spouseBusiness>0 & x5704==0
replace x5704=sqrt(x5704*(respBusiness+spouseBusiness)) if x5704>0 & respBusiness+spouseBusiness>0

// Remove embedded code of -1 for ``nothing'' in x5712. Leave all other negative values in place to represent capital losses on stocks, bonds, and real estate
replace x5712=0 if x5712==-1

// Remove embedded code of -1 for ``nothing'' in x5714. Zero out other recorded losses.
replace x5714=0 if x5714==-1
replace x5714=0 if x5714<0

// Clean negative values of X5724, other income.
// Assume that any negative values not associated with Sale of asset (|x5725|$=30$) or Net operating loss carryforward, n.e.c. |x5725$=36$| are errors. Set them to zero.
replace x5724=0 if x5724<0 & ~(x5725==30| x5725==36) //Assume that negative values coded under ``Gift or support n.e.c.'' are errors.

//\subsection{Income}
// We measure total income by summing the above variables, and we measure labor income as wage and salary income, income from professional practice, business, or farm, and alimony and child support.
gen totalincome=x5702+x5704+x5706+x5708+x5710+x5712+x5714+x5716+x5718+x5720+x5722+x5724
gen laborincome=x5702

//\section{Labor Income Tax}
// Our measure of labor income tax paid sums
//\begin{itemize}
//\item FICA taxes ($6.2$ pecent on all wages and salaries at or under \$94,200 in 2006, see page 16 of Publication 15),
//\item Self-employment tax (15.3 percent on all business income, see lines 10 and 11 of Part V of Form 1040-SS),
//\item Medicare taxes ($1.45$ percent on all wages and salaries, see page 16 of Publication 15), 
//\item Federal income taxes on wages and salaries.
//\item Federal income taxes on business profits and losses.
//\end{itemize}

//The limits on FICA taxes and the Social Securiy portion of the Self-employment tax apply at the \emph{individual} level, so we need to allocate income in |x5702| to R and S. We do this with 
//|resp| and |spouse|.
gen respShare=resp/(resp+spouse)
gen spouseShare=1-respShare
 
//First, calculate withholding amounts for fica taxes as if there were no self-employment.
// Fica tax, 6.2% on amounts at or under \$87,000
gen ficaResp=0.062*respShare*x5702 
gen ficaSpouse=0.062*spouseShare*x5702 

//If either partner's calculated tax would exceed $0.062\times 94200=5840.40$ dollars, truncate it at this amount.
replace ficaResp=5840.40 if ficaResp>5840.40
replace ficaSpouse=5840.40 if ficaSpouse>5840.40

//Replace these with the relevant self-employment rates for those who are self-employed.
replace ficaResp=2*ficaResp 	if x4106==2|x4106==3
replace ficaSpouse=2*ficaSpouse if x4706==2|x4706==3


//Sum the two partners' fica taxes together.
gen fica=ficaResp+ficaSpouse

//Since |respShare| is only defined for households with non-zero labor income as reported in the variables underlying |resp| and |spouse|, it is missing for many observations with positive values of |x5702|.
//For these households, we calcuale fica under the assumption that only one household member works and apply self-employment taxes if either partner reports being self-employed.
replace fica=0.062*x5702 if respShare==.
replace fica=5840.40 if respShare==. & fica>5840.40
replace fica=2*fica if x4106==2 | x4106==3 | x4706==2 | x4706==3

// Medicare tax, 1.45% on all wage and salary income
gen medicareResp=0.0145*respShare*x5702
gen medicareSpouse=0.0145*spouseShare*x5702

replace medicareResp=2*medicareResp 	if x4106==2 | x4106==3
replace medicareSpouse=2*medicareSpouse if x4706==2 | x4706==3

//Sum the two partners' medicare taxes together
gen medicare=medicareResp+medicareSpouse

//For these cases, we calculate medicare taxes as 1.45 percent of |x5702| unless either partner is self-employed, in which case we double the tax to 2.9 percent.
replace medicare=0.0145*x5702 if respShare==. & ~(x4106 ==2 | x4106 ==3 | x4706==2 | x4706 == 3)
replace medicare=0.0290*x5702 if respShare==. &  (x4106 ==2 | x4106 ==3 | x4706==2 | x4706 == 3)

//We estimated federal income taxes on wages and salaries by applying the household's average federal tax rate to total labor income and truncating the result at the lowest and highest statuatory marginal tax rates in 2000, 10 and 35 percent.
gen taxrate=tax/totalincome
replace taxrate=0.35 if taxrate>0.35
replace taxrate=0.10 if taxrate<0.10

gen labortax=fica+medicare+taxrate*x5702

//\section{IRA contributions}
// We estimate IRA contributions by assuming that each partner makes the maximum (possible) deductable contribution (\$4,000 in year 2003 for individuals under 50, see Page 13 of Publication 590) if 
//\begin{itemize}
//\item he or she has an IRA acount,
//\item the respondent says that neither partner is elibigle to participate in an employer-sponsored retirement plan at their main job, 
//\item neither partner made contributions to employer sponsored plans, and
//\item the total contributions leave the household with positive labor income. 
//\end{itemize}
//The third item \emph{seems} redundant given the second, but in practice many respondents report positive contributions to employer sponsored plans after saying that neither partner is eligible to participate in such plans.
//Indicators for R's and S's ownership of IRA accounts are in |x3602| and |x3612|. Eligibility to participate in an employer-sponsored plan is given by |x4137| and |x4737|. 

gen ira=(x4137~=1 & x4737~=1)*(4000*(x3602==1)+4000*(x3612==1))
replace ira=ira*(laborincome-labortax>ira)
replace ira=0 if employersponsored>0
//\section{Net Labor Income}
//This is the final calculation we have been working towards. We calculate labor income net of labor income tax, contributions to employer sponsored plans, and IRA contributions. If the 
//result is negative, we replace |employersponsored| and |ira| with zero and recalculate.
gen aftertax=laborincome-labortax-employersponsored-ira
replace employersponsored=0 if aftertax<0
replace ira=0 if aftertax<0
replace aftertax=laborincome-labortax if aftertax<0

//\section{Financial Wealth}
// Here, we measure total non-retirement financial wealth, defined as
// Checking accounts + Savings Accounts + Money Market Accounts + Call Accounts + CD's + Mutual Funds + Stock Holdings + Bonds + Savings Bonds
//For this, we use the Federal Reserve Board's |bulletin.do| to measure these balance-sheet variables.
gen year = 2007 //|bulletin.do| requires this variable.

quietly: do bulletin
gen wealth = checking + saving + mmda + mmmf + call + cds + nmmf + stocks + bond + savbnd
gen wealthRatio=wealth/aftertax

//\section{Weight}
//We use the ``suggested'' weight, |x42001|
rename x42001 weight
replace weight=floor(weight)


