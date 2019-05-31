# middleClass
This file contains the replication materials for _Liquidity Constraints of the Middle Class_ by Jeffrey R. Campbell and Zvi Hercowitz.

We used Stata for all of our data analysis, and we used Matlab for model calculations. Any reasonably-sized personal computer should be able to complete our data analysis successfully, but the model calculations require the hardware and software power typically found in a Linux cluster environment. In particular, we solve the model using parallel methods employing the Matlab Parallel toolbox. The code _will not run_ without that toolbox present. Furthermore, the computing environment should have _at least_ one _terabyte_ of memory present. In a cluster environment, this may be distributed across multiple physical computers. More specifics on working in a parallel environment follow below.

Table 1's sources are listed below it. To create Tables 2-6, run the following Stata programs.

| Table 2 | sampleSizeTable.do (upper panel) and recordCountTable.do (lower panel) |
| Table 3 | wealthRatioTable.do |
| Table 4 | whySave.do |
| Table 5 | termSavingRates.do |
| Table 6 | ageTables.do |

To run the Matlab programs, you must have a preexisting parallel pool. We recommend that the pool have 50 workers spread across 10 physical machines. In general, the number of workers should be divisible by 10 to minimize overhead communications between the workers. With that in place, you can run the following programs to create the paper's only figure and the remaining two tables.

|Figure 1| removeUncertainty.m |
|Table 7 | firstMpcTable.m |
|Table 8 | secondMpcTable.m|

These files all rely on baselineCalibration.mat, which contains the baseline calibration's parameter values and its solution.

If you have any problems replicating the paper's results or if you need to gain access to a Beowulf cluster. please contact Jeff Campbell at jyrc@me.com. We run a public GitHub repository for this file at https://github.com/jyrc/middleClass . You can look to it for updates and improvements.
