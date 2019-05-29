//makeVariables.do
//This program loads the 2001 Survey of Consumer Finance data and generates variables of interest for later analysis.

//\section{Overhead}

version 12.1

//Load the data
use scf2001, clear

//To save memory, we drop variables' original codings (which we do not use). These all start with ``|j|''.
drop j* 

//Rename the household identification variable for clarity.
rename yy1 householdIdentifier

//Measure age and information on anticipated major expenditures. 
rename x8022 age 
gen expense=x3010==1
gen savingNow=x7186==1

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

//Measure the use of educational spending accounts (used to respond to a referee.)
gen esa = (x6445==1) | (x6449==1) | (x6453==1)

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

//\section{Labor and Business Income Measurement}

//\subsection{Respondent's Pre-Tax Labor and Business Income}
// The variables we use to measure the respondent's pre-tax labor income are
//\begin{itemize}
//\item |x4112| is amount earned per pay period;
//\item |x4113| indicates how often respondent is paid; [1: daily; 2: weekly; 3: Monthly; 4:Monthly; 5: Quarterly; 6: Yearly; 18: Hourly; 31:Bi-monthly]
//\item |x4111| is how many weeks per year respondent works;
//\item |x4110| is how many hours per week respondent works.
//\end{itemize}
// We use weeks-per-year to measure total labor income when the given payment frequency is weekly or less, and we use hours per week to measure it when it is hourly.
gen resp = 0
replace resp = x4112 * 5 * x4111 		if x4113 == 1
replace resp = x4112 * x4111 			if x4113 == 2
replace resp = x4112 * 26 			 	if x4113 == 3
replace resp = x4112 * 12 				if x4113 == 4
replace resp = x4112 * 4 				if x4113 == 5
replace resp = x4112 					if x4113 == 6 | x4112==8
replace resp = x4112 * x4110 * x4111 	if x4113 == 18
replace resp = x4112 * 24 				if x4113 == 31
replace resp = . 						if x4113 == 14 | x4113 == 22 | x4113 == -7


//If the respondent is self-employed, (|x4106| equals 2 or 3), the respondent's other pre-tax business income is in |x4131| This has the embedded code |-1| for ``Nothing''.
gen respBusiness=x4131
replace respBusiness=0 if respBusiness==-1

//\subsection{Spouse's Pre-Tax Labor and Business Income}
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
replace spouse = x4712 					if x4713 == 6 | x4713==8
replace spouse = x4712 * x4710 * x4711 	if x4713 == 18
replace spouse = x4712 * 24 			if x4713 == 31
replace spouse = .						if x4713 == 14 | x4713 == 22 | x4713 == -7

//If the spouse is self-employed, (|x4706| equals 2 or 3), the spouse's other pre-tax business income is in |x4731|. This has the same embedded code as |x4131|.
gen spouseBusiness=x4731
replace spouseBusiness=0 if spouseBusiness==-1


//\section{Contributions to Employer-Sponsored Retirement Plans}
// At most three plans are coded, and each one is either a thrift/retirement plan or a tax-deferred savings plans.
// The variables used to calculate the household's year 2000 contributions to employer-sponsored plans are
/* \begin{itemize}
\item x4206, x4306, x4406; the percentages of wages and salaries contributed by R to the first three employer-sponsored thrift or retirement plans.
\item x4207, x4307, x4407; the dollar amounts contributed by R to the first three employer sponsored thrift or retirement plans.
\item x4208, x4208, x4308; frequency codes for contribuions in x4207, x4307, and x4407. (4, month; 5, quarter; 6, year)
\item x4223, x4323, x4423; the percentages of wages and salaries contributed by R to the first three employer-sponsored tax-deferred savings plans.
\item x4224, x4324, x4424; the dollar aounts contrbued by R to the first three employer-sponsored tax-deferred savings plans.
\item x4225, x4325, x4425; frequency codes for contributions in x4224, x4324, and x4424.

\item x4806, x4906, x5006; the percentages of wages and salaries contributed by S to the first three employer-sponsored thrift or retirement plans.
\item x4807, x4907, x5007; the dollar amounts contributed by S to the first three employer sponsored thrift or retirement plans.
\item x4808, x4908, x5008; frequency codes for contributions in x4807, x4907, and x5007.
\item x4823, x4923, x5023; the percentages of wages and salaries contributed by S to the first three employer-sponsored tax-deferred savings plans.
\item x4824, x4924, x5024; the dollar amounts contributed by S to the first three employer-sponsored tax-deferred savings plans.
\item x4825, x4925, x5025; frequency codes for contributions in x4824, x4924, and x5024.
\end{itemize}
*/

// Replace embedded codes with missing values.
mvdecode x4206 x4207 x4208, mv(-7/0)
mvdecode x4306 x4307 x4308, mv(-7/0)
mvdecode x4406 x4407 x4408, mv(-7/0)

mvdecode x4223 x4224 x4225, mv(-7/0)
mvdecode x4323 x4324 x4325, mv(-7/0)
mvdecode x4423 x4424 x4425, mv(-7/0)

mvdecode x4806 x4807 x4808, mv(-7/0)
mvdecode x4906 x4907 x4908, mv(-7/0)
mvdecode x5006 x5007 x5008, mv(-7/0)

mvdecode x4823 x4824 x4825, mv(-7/0)
mvdecode x4923 x4924 x4925, mv(-7/0)
mvdecode x5023 x5024 x5025, mv(-7/0)


//Calculate total retirement plan contributions for both R and S.
//The codebook to the SCF states,
/*
\begin{quote}  
NOTE: where possible, X4112/X4712 was used to compute the
            percent when the amount was given (and vice versa).  Where
            X4112/X4712 was negative or zero, and X4112+X4131/X4712+X4731
            was positive, the latter figure was used to make the conversion.
\end{quote}
*/
//This implies that adding the given contributions (appropriately adjusted for their frequency) gives the right contribution unless someone reported a percentage contribution with zero income. 
//This does not appear to be a large problem in the 2001 SCF. (This can be formalized later.) Accordingly, we simply sum the appropriate contributions.

//The codebook allows for some fairly odd contribution schedules (e.g. ``By the job/piece''). The next code sets these to missing. 

mvdecode x4208 x4308 x4408 x4225 x4325 x4425 x4808 x4908 x5008 x4825 x4925 x5025, mv(14 22)

//Calculate R's annual contributions to each of the six possible accounts listed. (Note, at most three of these will have positive amounts.)
gen employersponsoredR1=(x4205==1)*((x4208==1)*x4111*5+(x4208==2)*52+(x4208==3)*26+(x4208==4)*12+(x4208==5)*4+(x4208==6 | x4208==8)+(x4208==11)*2+(x4208==12)*6+(x4208==18)*x4110*x4111+(x4208==31)*24)*x4207
gen employersponsoredR2=(x4305==1)*((x4308==1)*x4111*5+(x4308==2)*52+(x4308==3)*26+(x4308==4)*12+(x4308==5)*4+(x4308==6 | x4308==8)+(x4308==11)*2+(x4308==12)*6+(x4308==18)*x4110*x4111+(x4308==31)*24)*x4307
gen employersponsoredR3=(x4405==1)*((x4408==1)*x4111*5+(x4408==2)*52+(x4408==3)*26+(x4408==4)*12+(x4408==5)*4+(x4408==6 | x4408==8)+(x4408==11)*2+(x4408==12)*6+(x4408==18)*x4110*x4111+(x4408==31)*24)*x4407
gen employersponsoredR4=(x4222==1)*((x4225==1)*x4111*5+(x4225==2)*52+(x4225==3)*26+(x4225==4)*12+(x4225==5)*4+(x4225==6 | x4225==8)+(x4225==11)*2+(x4225==12)*6+(x4225==18)*x4110*x4111+(x4225==31)*24)*x4224
gen employersponsoredR5=(x4322==1)*((x4325==1)*x4111*5+(x4325==2)*52+(x4325==3)*26+(x4325==4)*12+(x4325==5)*4+(x4325==6 | x4325==8)+(x4325==11)*2+(x4325==12)*6+(x4325==18)*x4110*x4111+(x4325==31)*24)*x4324
gen employersponsoredR6=(x4422==1)*((x4425==1)*x4111*5+(x4425==2)*52+(x4425==3)*26+(x4425==4)*12+(x4425==5)*4+(x4425==6 | x4425==8)+(x4425==11)*2+(x4425==12)*6+(x4425==18)*x4110*x4111+(x4425==31)*24)*x4424

egen employersponsoredR=rowtotal(employersponsoredR1 employersponsoredR2 employersponsoredR3 employersponsoredR4 employersponsoredR5 employersponsoredR6)

//Many of the total contributions by R exceed the IRS Section 402(g) limit of 10500 for tax year 2000. We replace these obvious overestimations with this statuatory limit.
replace employersponsoredR=10500 if employersponsoredR>10500 

//Calculate S's annual contributions to each of the six possible accounts listed.
gen employersponsoredS1=(x4805==1)*((x4808==1)*x4711*5+(x4808==2)*52+(x4808==3)*26+(x4808==4)*12+(x4808==5)*4+(x4808==6 | x4808==8)+(x4808==11)*2+(x4808==12)*6+(x4808==18)*x4710*x4711+(x4808==31)*24)*x4807
gen employersponsoredS2=(x4905==1)*((x4908==1)*x4711*5+(x4908==2)*52+(x4908==3)*26+(x4908==4)*12+(x4908==5)*4+(x4908==6 | x4908==8)+(x4908==11)*2+(x4908==12)*6+(x4908==18)*x4710*x4711+(x4908==31)*24)*x4907
gen employersponsoredS3=(x5005==1)*((x5008==1)*x4711*5+(x5008==2)*52+(x5008==3)*26+(x5008==4)*12+(x5008==5)*4+(x5008==6 | x5008==8)+(x5008==11)*2+(x5008==12)*6+(x5008==18)*x4710*x4711+(x5008==31)*24)*x5007
gen employersponsoredS4=(x4822==1)*((x4825==1)*x4711*5+(x4825==2)*52+(x4825==3)*26+(x4825==4)*12+(x4825==5)*4+(x4825==6 | x4825==8)+(x4825==11)*2+(x4825==12)*6+(x4825==18)*x4710*x4711+(x4825==31)*24)*x4824
gen employersponsoredS5=(x4922==1)*((x4925==1)*x4711*5+(x4925==2)*52+(x4925==3)*26+(x4925==4)*12+(x4925==5)*4+(x4925==6 | x4925==8)+(x4925==11)*2+(x4925==12)*6+(x4925==18)*x4710*x4711+(x4925==31)*24)*x4924
gen employersponsoredS6=(x5022==1)*((x5025==1)*x4711*5+(x5025==2)*52+(x5025==3)*26+(x5025==4)*12+(x5025==5)*4+(x5025==6 | x5025==8)+(x5025==11)*2+(x5025==12)*6+(x5025==18)*x4710*x4711+(x5025==31)*24)*x5024

egen employersponsoredS=rowtotal(employersponsoredS1 employersponsoredS2 employersponsoredS3 employersponsoredS4 employersponsoredS5 employersponsoredS6)
replace employersponsoredS=10500 if employersponsoredS>10500 

//Sum the two partners' contributions to get the household's total contribution to employer-sponsored retirement plans.
gen employersponsored=employersponsoredR+employersponsoredS

//\section{AGI and Tax Measurement}
// We wish to examine the ratio of wealth to \emph{after tax} labor income, so we must arrive at a measure of taxes paid on labor income for each respondent household. 
// For this, we first measure the household's AGI and then apply the relevant tax table from 2000.
/* The variables used for this measurement are
\begin{itemize}
\item x101, number of people living in the household/primary economic unit.
\item x5744, indicator for whether the respondent's household has or expects to file a year 2000 Federal Income Tax Return (1=YES - FILED; 5=NO - DO NOT EXPECT TO FILE; 6=YES - NOT YET FILED)
\item x5746, categorical variable indicating whether the household members file jointly, file separately, or only one files (1=FILED JOINTLY; 2=FILED SEPARATELY; 3=ONLY R FILED; 4=ONLY SPOUSE FILED)
\item x5751, Adjusted Gross Income for households filing jointly.
\item x7651, Adjusted Gross Income for the respondent if single or filing separately.
\item x7652, Adjusted Gross Income for the Spouse if filing separately.
\end{itemize}
*/

gen tax=.

replace tax=0 if x5744==5 //Set tax to zero for households not filing.

//\subsection{Married Filing Jointly}
// These calculations assume that respondents with a spouse that said only R filed |x5746==3 \& x7020==2| or respondents indicating that only S filed |x5746==4| actually are married filing jointly.
gen mfj = (x5744==1 | x5744==6) & (x5746==1 | (x5746==3 & x7020==2) | x5746==4) // Indicator for married filing jointly.
gen agi=x5751 if mfj==1 //AGI for households filing jointly.
replace agi=x7651 if x5744==3 //Only R filed.
replace agi=x7652 if x5744==4 //Only S filed.
replace agi=0 if agi<0 & mfj==1 //Set tax to zero for households reporting negative AGI.

// Read the tax paid off of the 2000 tax rate schedules on page 71 on Form i1040.
replace tax = agi*0.15 if agi<=43850 & mfj==1
replace tax = 6577.50+0.28*(agi-43850) if agi>43850 & agi<=105950 & mfj==1 
replace tax = 23965.50+0.31*(agi-105950) if agi>105950 & agi<=161450 & mfj==1
replace tax = 41170.50+0.36*(agi-161450) if agi>161450 & agi<=288350 & mfj==1
replace tax = 86854.50+0.396*(agi-288350) if agi>288350 & mfj==1

drop agi

//\subsection{Married Filing Separately}
gen mfs = (x5744==1 | x5744==6) & x5746==2
gen agiR=x7651 if mfs==1 //respondent's AGI
gen agiS=x7652 if mfs==1 //Spouse's AGI
replace agiR=0 if agiR<0 //Set tax to zero for negative respondent AGI
replace agiS=0 if agiS<0 //Set tax to zero for negative spouse AGI

gen taxR=.
gen taxS=.

//Read the respondent's taxes off of the 2000 tax table.
replace taxR=agiR*0.15 if agiR<= 21925 & mfs==1
replace taxR=3288.75+0.28*(agiR-21925) if agiR>21925 & agiR<=52975 & mfs==1
replace taxR=11982.75+0.31*(agiR-52975) if agiR>52975 & agiR<=80725 & mfs==1
replace taxR=20585.25+0.36*(agiR-80725) if agiR>80725 & agiR<=144175 & mfs==1
replace taxR=43427.25+0.396*(agiR-144175) if agiR>144175 & mfs==1

// Read the spouse's taxes off of the 2000 tax table.
replace taxS=agiR*0.15 if agiS<= 21925 & mfs==1
replace taxS=3288.75+0.28*(agiS-21925) if agiS>21925 & agiS<=52975 & mfs==1
replace taxS=11982.75+0.31*(agiS-52975) if agiS>52975 & agiS<=80725 & mfs==1
replace taxS=20585.25+0.36*(agiS-80725) if agiS>80725 & agiS<=144175 & mfs==1
replace taxS=43427.25+0.396*(agiS-144175) if agiS>144175 & mfs==1

replace tax=taxR+taxS if mfs==1
drop agiR agiS

//\subsection{Singles}
//All other respondents are either filing as Singles or as Heads of Household. We use |x101| (number of people in the household) for this classification.
gen single=(x5744==1 | x5744==6) & x5746==3 & x7020==1 & x101==1

gen agi=x7651 if single==1 //respondent's AGI
replace agi=0 if agi<0

replace tax = agi*0.15 if agi<=26250 & single==1
replace tax = 3937.5+0.28*(agi-26250) if agi>26250 & agi<=63550 & single==1
replace tax = 14381.5+0.31*(agi-63550) if agi>63550 & agi<132600 & single==1
replace tax = 35787+0.36*(agi-132600) if agi>132600 & agi<288350 & single==1
replace tax = 91857+0.396*(agi-288350) if agi>288350 & single==1

drop agi

//\subsection{Heads of Household}
gen hh=(x5744==1 | x5744==6) & x5746==3 & x7020==1 & x101>1
gen agi=x7651 if hh==1 //respondent's AGI
replace agi=0 if agi<0

replace tax=agi*0.15 if agi<=35150 & hh==1
replace tax=5272.50+0.28*(agi-35150) if agi>35150 & agi<=90800 & hh==1
replace tax=20854.50+0.31*(agi-90800) if agi>90800 & agi<=147050 & hh==1
replace tax=38292.00+0.36*(agi-147050) if agi>147050 & agi<=288350 & hh==1
replace tax=89160.00+0.396*(agi-288350) if agi>288350 & hh==1

drop agi


//\section{Measurement of Total Income}
//We measure total income and labor income using the sequence of ``roundup'' income questions beginning with X5701. This allows us to measure the fraction of total income from wages and salaries.
// The variables used for this task are
/* \begin{itemize}
\item X5702, wage and salary income
\item X5704, non-wage income from professional practice, business, or farm
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
//\item FICA taxes ($6.2$ pecent on all wages and salaries at or under \$76,200 in 2000, see page 3 of Publication 15),
//\item Self-employment tax (15.3 percent on all business income, see page 2 of Publication 533),
//\item Medicare taxes ($1.45$ percent on all wages and salaries, see page 3 of Publication 15), 
//\item Federal income taxes on wages and salaries.
//\item Federal income taxes on business profits and losses.
//\end{itemize}

//The limits on FICA taxes and the Social Security portion of the Self-employment tax apply at the \emph{individual} level, so we need to allocate income in |x5702| to R and S. We do this with 
//|resp| and |spouse|.
gen respShare=resp/(resp+spouse)
gen spouseShare=1-respShare
 
//First, calculate withholding amounts for fica taxes as if there were no self-employment.
// Fica tax, 6.2% on amounts at or under \$76,200
gen ficaResp=0.062*respShare*x5702 
gen ficaSpouse=0.062*spouseShare*x5702 

//If either partner's calculated tax would exceed $0.062\times 76200=4724.4$ dollars, truncate it at this amount.
replace ficaResp=4724.40 if ficaResp>4724.40
replace ficaSpouse=4724.40 if ficaSpouse>4724.40

//Replace these with the relevant self-employment rates for those who are self-employed.
replace ficaResp=2*ficaResp 	if x4106==2|x4106==3
replace ficaSpouse=2*ficaSpouse if x4706==2|x4706==3

//Sum the two partners' fica taxes together.
gen fica=ficaResp+ficaSpouse

//Since |respShare| is only defined for households with non-zero labor income as reported in the variables underlying |resp| and |spouse|, it is missing for many observations with positive values of |x5702|.
//For these households, we calcuale fica under the assumption that only one household member works and apply self-employment taxes if either partner reports being self-employed.
replace fica=0.062*x5702 if respShare==.
replace fica=4724.40 if respShare==. & fica>4724.40
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

//We estimated federal income taxes on wages and salaries by applying the household's average federal tax rate to total labor income and truncating the result at the lowest and highest statuatory marginal tax rates in 2000, 15 and 39.6 percent.
gen taxrate=tax/totalincome
replace taxrate=0.396 if taxrate>0.396
replace taxrate=0.15 if taxrate<0.15

gen labortax=fica+medicare+taxrate*x5702

//\section{IRA contributions}
// We estimate IRA contributions by assuming that each partner makes the maximum (possible) deductable contribution (\$2,000 in year 2000, see Publication 590) if 
//\begin{itemize}
//\item he or she has an IRA acount,
//\item the respondent says that neither partner is elibigle to participate in an employer-sponsored retirement plan at their main job, 
//\item neither partner made contributions to employer sponsored plans, and
//\item the total contributions leave the household with positive labor income. 
//\end{itemize}
//The third item \emph{seems} redundant given the second, but in practice many respondents report positive contributions to employer sponsored plans after saying that neither partner is eligible to participate in such plans.
//Indicators for R's and S's ownership of IRA accounts are in |x3602| and |x3612|. Eligibility to participate in an employer-sponsored plan is given by |x4137| and |x4737|. 

gen ira=(x4137~=1 & x4737~=1)*(2000*(x3602==1)+2000*(x3612==1))
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
gen year = 2001 //|bulletin.do| requires this variable.
quietly: do bulletin
gen wealth = checking + saving + mmda + mmmf + call + cds + nmmf + stocks + bond + savbnd
gen wealthRatio=wealth/aftertax

//Target precautionary wealth.
//For this, we use the answer to the standard precautionary wealth question.
gen targetWealth=x7187
replace targetWealth=0 if targetWealth<0
gen targetWealthRatio=targetWealth/aftertax


//\section{Weight}
//We use the ``suggested'' weight, |x42001|
rename x42001 weight
replace weight=floor(weight)


