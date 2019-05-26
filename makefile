.PHONY: scfdata tidy clean

scfdata: scf1995.dta scf1998.dta scf2001.dta scf2004.dta scf2007.dta

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

tidy:
	-rm scf1995.dta scf1998.dta scf2001.dta scf2004.dta scf2007.dta

clean: tidy
