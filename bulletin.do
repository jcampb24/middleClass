//\title{bulletin.do}
// This file is adapted from bulletin.macro.txt, a SAS program on the Board's web site used to create the variables required for the various Federal Reserve Bulletin articles.
// Its ambition is much more modest than that of bulletin.macro.txt.
//
***************************************************************************
*   assets, debts, networth, and related varaibles

***************************************************************************
*   financial assets and related variables;

*   checking accounts other than money market
gen checking = max(0,x3506)*(x3507==5)+max(0,x3510)*(x3511==5)+max(0,x3514)*(x3515==5)+max(0,x3518)*(x3519==5)+max(0,x3522)*(x3523==5)+max(0,x3526)*(x3527==5)+max(0,x3529)*(x3527==5)

*   have any checking account: 1=yes, 0=no
gen hcheck = (((x3507==5)+(x3511==5)+(x3515==5)+(x3519==5)+(x3523==5)+(x3527==5)+(x3527==5))>0)

*   have no checking account: 1=no checking, 0=have checking 
gen nochk = (x3501 == 5)

*   people w/o checking accounts: ever had an account?: 1=yes, 5=no
gen ehchkg = x3502

*   savings accounts
if year <= 2001 {
gen saving = max(0,x3804)+max(0,x3807)+max(0,x3810)+max(0,x3813)+max(0,x3816)+max(0,x3818) 
}
if year >= 2004 {
gen saving = max(0,x3730*(x3732!=4&x3732!=30))+max(0,x3736*(x3738!=4&x3738!=30))+max(0,x3742*(x3744!=4&x3744!=30))+max(0,x3748*(x3750!=4&x3750!=30))+max(0,x3754*(x3756!=4&x3756!=30))+max(0,x3760*(x3762!=4&x3762!=30))+max(0,x3765)
}

*   have savings account: 1=yes, 0=no
gen hsaving = (saving > 0)

*   money market deposit accounts
**Code For Years 1989-2001
if year <= 2001 {
gen mmda = max(0,x3506)*((x3507==1)*(11<=x9113 & x9113<=13))+max(0,x3510)*((x3511==1)*(11<=x9114 & x9114<=13))+max(0,x3514)*((x3515==1)*(11<=x9115 & x9115<=13))+max(0,x3518)*((x3519==1)*(11<=x9116 & x9116<=13))+max(0,x3522)*((x3523==1)*(11<=x9117 & x9117<=13))+max(0,x3526)*((x3527==1)*(11<=x9118 & x9118<=13))+max(0,x3529)*((x3527==1)*(11<=x9118 & x9118<=13))+max(0,x3706)*(11<=x9131 & x9131<=13)+max(0,x3711)*(11<=x9132 & x9132<=13)+max(0,x3716)*(11<=x9133 & x9133<=13)+max(0,x3718)*(11<=x9133 & x9133<=13) if (year >= 1989 & year <= 2001)
}
**Code for Years 2004+
if year >= 2004 {
gen mmda = max(0,x3506)*((x3507==1)*(11<=x9113&x9113<=13))+max(0,x3510)*((x3511==1)*(11<=x9114&x9114<=13))+max(0,x3514)*((x3515==1)*(11<=x9115&x9115<=13))+max(0,x3518)*((x3519==1)*(11<=x9116&x9116<=13))+max(0,x3522)*((x3523==1)*(11<=x9117&x9117<=13))+max(0,x3526)*((x3527==1)*(11<=x9118&x9118<=13))+max(0,x3529)*((x3527==1)*(11<=x9118&x9118<=13))+max(0,x3730*(x3732==4 | x3732==30)*(x9259>=11 & x9259<=13))+max(0,x3736*(x3738==4 | x3738==30)*(x9260>=11 & x9260<=13))+max(0,x3742*(x3744==4 | x3744==30)*(x9261>=11 & x9261<=13))+max(0,x3748*(x3750==4 | x3750==30)*(x9262>=11 & x9262<=13))+max(0,x3754*(x3756==4 | x3756==30)*(x9263>=11 & x9263<=13))+max(0,x3760*(x3762==4 | x3762==30)*(x9264>=11 & x9264<=13)) if (year >= 2004)
}

*   money market mutual funds
**Code For Years 1989-2001
if year <= 2001 {
gen mmmf = max(0,x3506)*(x3507==1)*(x9113<11|x9113>13)+max(0,x3510)*(x3511==1)*(x9114<11|x9114>13)+max(0,x3514)*(x3515==1)*(x9115<11|x9115>13)+max(0,x3518)*(x3519==1)*(x9116<11|x9116>13)+max(0,x3522)*(x3523==1)*(x9117<11|x9117>13)+max(0,x3526)*(x3527==1)*(x9118<11|x9118>13)+max(0,x3529)*(x3527==1)*(x9118<11|x9118>13)+max(0,x3706)*(x9131<11|x9131>13)+max(0,x3711)*(x9132<11|x9132>13)+max(0,x3716)*(x9133<11|x9133>13)+max(0,x3718)*(x9133<11|x9133>13) if (year >= 1989 & year <= 2001)
}
**Code for Years 2004+
if year >= 2004 {
gen mmmf=max(0,x3506)*(x3507==1)*(x9113<11|x9113>13)+max(0,x3510)*(x3511==1)*(x9114<11|x9114>13)+max(0,x3514)*(x3515==1)*(x9115<11|x9115>13)+max(0,x3518)*(x3519==1)*(x9116<11|x9116>13)+max(0,x3522)*(x3523==1)*(x9117<11|x9117>13)+max(0,x3526)*(x3527==1)*(x9118<11|x9118>13)+max(0,x3529)*(x3527==1)*(x9118<11|x9118>13)+max(0,x3730*(x3732==4 | x3732==30)*(x9259<11|x9259>13))+max(0,x3736*(x3738==4 | x3738==30)*(x9260<11|x9260>13))+max(0,x3742*(x3744==4 | x3744==30)*(x9261<11|x9261>13))+max(0,x3748*(x3750==4 | x3750==30)*(x9262<11|x9262>13))+max(0,x3754*(x3756==4 | x3756==30)*(x9263<11|x9263>13))+max(0,x3760*(x3762==4 | x3762==30)*(x9264<11|x9264>13)) if (year >= 2004)
}

*   all types of money market accounts
gen mma = mmda + mmmf

*   have any type of money market account: 1=yes, 0=no
gen hmma = (mma > 0)

*   call accounts at brokerages
gen call=max(0,x3930)

*   have call account: 1=yes, 0=no
gen hcall = (call > 0)

*   all types of transactions accounts (liquid assets)
gen liq = checking + saving + mma + call

*   have any types of transactions accounts: 1=yes, 0=no
gen hliq = (liq > 0 | x3501 == 1 | x3929 == 1)

*   certificates of deposit
gen cds = max(0,x3721)

*   have CDs: 1=yes, 0=no
gen hcds = (cds>0)

*   mutual funds
*   stock mutual funds
gen stmutf = (x3821==1)*max(0,x3822)

*   tax-free bond mutual funds
gen tfbmutf = (x3823==1)*max(0,x3824)

*   government bond mutual funds
gen gbmutf = (x3825==1)*max(0,x3826)

*   other bond mutual funds
gen obmutf = (x3827==1)*max(0,x3828)

*   combination and other mutual funds
gen comutf = (x3829==1)*max(0,x3830)
gen omutf = 0
if year >= 2004 {
replace omutf = (x7785==1) * max(0,x7787)
}

*   total directly-held mutual funds, excluding MMMFs
gen nmmf = stmutf + tfbmutf + gbmutf + obmutf + comutf + omutf

*   have any mutual funds excluding MMMFs: 1=yes, 0=no
gen hnmmf = (nmmf > 0)

*   stocks
gen stocks = max(0,x3915)

*   have stocks: 1=yes, 0=no
gen hstocks = (stocks>0)

*   bonds, not including bond funds or savings bonds
*   tax-exempt bonds (state and local bonds)
gen notxbnd = x3910

*   mortgage-backed bonds
gen mortbnd = x3906

*   US government and government agency bonds and bills
gen govtbnd = x3908

*   corporate and foreign bonds
if year >= 1992 {
gen obnd = x7634 + x7633
}
if year < 1992 {
gen obnd = x3912
}

*   total bonds, not including bond funds or savings bonds
gen bond = notxbnd + mortbnd + govtbnd + obnd

*   have bonds: 1=yes, 0=no
gen hbond = (bond > 0)

*   savings bonds 
gen savbnd = x3902 
*   have savings bonds: 1=yes, 0=no 
gen hsavbnd = (savbnd > 0) 
    
*   cash value of whole life insurance 
gen cashli = max(0,x4006) 
*   have cash value LI: 1=yes, 0=no 
gen hcashli = (cashli > 0) 
    
*   other managed assets (trusts, annuities and managed investment accounts in which HH has equity interest) 
if year >= 2004 {
gen annuit = max(0,x6577) 
gen trusts = max(0,x6587) 
gen othma = annuit + trusts
}
if (year == 1998 | year == 2001) {
gen annuit = max(0,x6820) 
gen trusts = max(0,x6835) 
gen othma = annuit + trusts
}
if year <= 1995 {
gen othma = max(0,x3942) 
}
*   have other managed assets: 1=yes, 0=no 
gen hothma = othma > 0

*   other financial assets: includes loans from the household to someone else, future proceeds, royalties, futures, non-public stock, deferred compensation, oil/gas/mineral invest., cash n.e.c.
*   NOTE: because of the collapsing of categories in the public version of the dataset, both codes 71 (oil/gas/mineral leases or investments) and 72 (futures contracts, stock options) are combined in code 71: thus, the sum will be treated as a nonfinancial asset. Additionally, codes 77 (future lottery/prize receipts) and 79 (other obligations to R, tax credits) are combined in code 77
gen x4022in = ((x4020>60&x4020<67)|(x4020>70&x4020<75)|x4020==77|x4020==80|x4020==81|x4020==-7)
gen x4026in = ((x4024>60&x4024<67)|(x4024>70&x4024<75)|x4024==77|x4024==80|x4024==81|x4024==-7)
gen x4030in = ((x4028>60&x4028<67)|(x4028>70&x4028<75)|x4028==77|x4028==80|x4028==81|x4028==-7)
gen othfin = x4018 + (x4022 * x4022in) + (x4026 * x4026in) + (x4030 * x4030in)

*   have other financial assets: 1=yes, 0=no 
gen hothfin = (othfin > 0)
    
