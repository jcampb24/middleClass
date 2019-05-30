STATA=stata-mp
.PHONY: scfdata scftables tidy clean

all: scfdata scftables

scfdata: scf1995.dta scf1998.dta scf2001.dta scf2004.dta scf2007.dta

scfpreprocessing: makeVariables1995.do makeVariables1998.do makeVariables2001.do makeVariables2004.do makeVariables2007.do selectSample1995.do selectSample1998.do selectSample2001.do selectSample2004.do selectSample2007.do

scftables: scfSample.tex scfRecords.tex wealthRatioTable.tex whySave.tex termSavingRates.tex expenditureFrequency.tex

#Targets for downloading the scf data sets we used from our shared Dropbox folder.
scf1995.dta:
	curl -o scf1995.dta -L https://www.dropbox.com/s/gvtdipulzz7affq/scf1995.dta?dl=0

scf1998.dta:
	curl -o scf1998.dta -L https://www.dropbox.com/s/srowf9gekdkjkuj/scf1998.dta?dl=0

scf2001.dta:
	curl -o scf2001.dta -L https://www.dropbox.com/s/lsydq3wi56oh31i/scf2001.dta?dl=0

scf2004.dta: 
	curl -o scf2004.dta -L https://www.dropbox.com/s/smx0v5yj9f7796y/scf2004.dta?dl=0

scf2007.dta:
	curl -o scf2007.dta -L https://www.dropbox.com/s/y2ty5rit2b6z38a/scf2007.dta?dl=0

#Targets for creating tables from the scf.
scfSample.tex: sampleSizeTable.do scfdata scfpreprocessing
	$(STATA) -b sampleSizeTable.do

scfRecords.tex: recordCountTable.do scfdata scfpreprocessing
	$(STATA) -b recordCountTable.do

wealthRatioTable.tex: wealthRatioTable.do scfdata scfpreprocessing
	$(STATA) -b wealthRatioTable.do

whySave.tex: whySave.do scfdata scfpreprocessing
	$(STATA) -b whySave.do

termSavingRates.tex: termSavingRates.do scfdata scfpreprocessing
	$(STATA) -b termSavingRates.do

expenditureFrequency.tex: ageTables.do scfdata scfpreprocessing
	$(STATA) -b ageTables.do

#Phony targets for cleaning.
tidy:
	-rm scf1995.dta scf1998.dta scf2001.dta scf2004.dta scf2007.dta

clean: tidy
