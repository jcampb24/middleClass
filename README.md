# middleClass
This file contains the replication materials for _Liquidity Constraints of the Middle Class_ by Jeffrey R. Campbell and Zvi Hercowitz.

We used Stata for all of our data analysis, and we used Matlab for model calculations. Any reasonably-sized personal computer should be able to complete our data analysis successfully, but the model calculations require the hardware and software power typically found in a Linux cluster environment. In particular, we solve the model using parallel methods employing the Matlab Parallel toolbox. The code _will not run_ without that toolbox present. Furthermore, the computing environment should have _at least_ one _terabyte_ of memory present. In a cluster environment, this may be distributed across multiple physical computers. More specifics on working in a parallel environment follow below.

