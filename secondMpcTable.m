%secondMpcTable.m
% This program calculates the results presented in the table of MPCs for
% for households at each state of the expenditure cycle.

%Load the calibrated model.
load baselineCalibration

%Calculate the wealth distribution
originalWealthDistributionPDF=dp.inducedMarkovChain.ergodicDistribution;
originalWealthDistributionSupport=dp.nodes.support(:,1)./...
    dp.nodes.support(:,4);
%originalWealthDistributionPDF=originalWealthDistributionPDF(originalWealthDistributionPDF>0);

%Consolidate duplicate values of wealth.
wealthDistributionSupport=unique(originalWealthDistributionSupport);
wealthDistributionPDF=zeros(size(wealthDistributionSupport));
for ii=1:length(wealthDistributionSupport)
   wealthDistributionPDF(ii)=sum(originalWealthDistributionPDF(...
       originalWealthDistributionSupport==wealthDistributionSupport(ii)));
end
wealthDistributionCDF=cumsum(wealthDistributionPDF);

%Calculate the frequencies of wealth distribution category, 
%where the categories are defined by by months of income.
categories=0:1:13;
wealthCategoryProbabilities=zeros(length(categories),1);
highIndex=find(wealthDistributionSupport<=categories(1)/12,1,'last');
wealthCategoryProbabilities(1)=wealthDistributionCDF(highIndex);
for ii=2:length(categories)-1
    highIndex=find(wealthDistributionSupport<=categories(ii)/12,1,'last');
    lowIndex=find(wealthDistributionSupport<=categories(ii-1)/12,1,'last');
    wealthCategoryProbabilities(ii)= wealthDistributionCDF(highIndex)-...
        wealthDistributionCDF(lowIndex);    
end
wealthCategoryProbabilities(end)=1-wealthDistributionCDF(highIndex);

%Assign each node in the state space to one of the wealth distribution
%categories.
wealthCategory=zeros(dp.nodes.supportLength,1);

for ii=1:length(categories)-1
    wealthCategory=wealthCategory+(dp.nodes.support(:,1)./dp.nodes.support(:,4)>categories(ii)/12);
end

kappaIndex=find(strcmp(dp.nodes.names,'\kappa_t'),1,'first');
kappa=dp.nodes.support(:,kappaIndex);

%The third column reports the fraction of a one-off wealth gift equal
%to 10 percent of wage that gets spent. For this, we add 0.10 to each
%individual's wage and then run the value function through the Bellman
%operator \emph{once}. Comparing the resulting consumption to the initial
%consumption gives us the fraction spent. 

%The first step is to calculate baseline consumption.
a=dp.nodes.support(:,1);
aPrime=dp.choices.support(dp.optimalChoice);
w=dp.nodes.support(:,4);
R=dp.opportunities.R;
consumption=a+w-aPrime/R;

%Next, we calculate optimal savings and consumption after the one-off
%wealth gift.
oneOffGift=0.10;
opportunitiesOneOff=dp.opportunities;
opportunitiesOneOff.earningsProcess=specifyEarningsProcess(...
    dp.opportunities.earningsProcess,'lumpSumTax',-oneOffGift);

algorithmOneOff=dp.algorithm;
algorithmOneOff.iterationCountCeiling=1;

dpOneOff=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesOneOff,'algorithm',algorithmOneOff);
dpOneOff.value=dp.value;
dpOneOff=distributeStandardDynamicProgram(dpOneOff);
dpOneOff=solveStandardDynamicProgram(dpOneOff);
dpOneOff=gatherStandardDynamicProgram(dpOneOff,'abandon','staticPayoffs');

aOneOff=dpOneOff.nodes.support(:,1);
aPrimeOneOff=dpOneOff.choices.support(dpOneOff.optimalChoice);
wOneOff=dpOneOff.nodes.support(:,4);
consumptionOneOff=aOneOff+wOneOff-aPrimeOneOff/R;

%The marginal propensity to consume can now be calculated.
mpcOneOff=(consumptionOneOff-consumption)/oneOffGift;

%The last step is the calculation of the average MPCs reported for each
%category.
wealthCategoryAverageMpcsOneOff=zeros(length(categories)+1,1);
for i=0:max(categories)
   wealthCategoryAverageMpcsOneOff(i+1)=dp.inducedMarkovChain.ergodicDistribution(wealthCategory==i)'*...
       mpcOneOff(wealthCategory==i)/wealthCategoryProbabilities(i+1);    
end
wealthCategoryAverageMpcsOneOff(end)=dp.inducedMarkovChain.ergodicDistribution'*mpcOneOff;

%Calculate the MPC's for each wealth category and kappa
wealthCategoryAndKappaAverageMpcsOneOff=zeros(length(categories)+1,...
    dp.preferences.tau);
for i=0:max(categories)
    for j=1:dp.preferences.tau
        wealthCategoryAndKappaAverageMpcsOneOff(i+1,j)=...
            originalWealthDistributionPDF(wealthCategory==i & kappa==j)'*...
            mpcOneOff(wealthCategory==i & kappa==j)/...
            sum(originalWealthDistributionPDF(wealthCategory==i & kappa==j));
    end
end
for j=1:dp.preferences.tau
    wealthCategoryAndKappaAverageMpcsOneOff(end,j)=...
            originalWealthDistributionPDF(kappa==j)'*...
            mpcOneOff(kappa==j)/...
            sum(originalWealthDistributionPDF(kappa==j));
end

%Create a LaTeX table of the MPCs by wealth and cycle stage.
mpcs=100*wealthCategoryAndKappaAverageMpcsOneOff;

leftColumn=cell(length(categories)+1,1);
leftColumn{1}='0';
for i=2:length(categories)-1
   leftColumn{i}=['(' num2str(categories(i-1)) ',' num2str(categories(i)) ']']; 
end
leftColumn{length(categories)}=[num2str(categories(end)) ' or more'];
leftColumn{end}='All Households';

MPCTable=makeLaTeXTable('data',mpcs,'leftColumn',leftColumn);

%Write the mpc table to a file.
f1=fopen('mpcsByWealthAndKappa.tex','w');
nRows=length(MPCTable);
for i=1:nRows
   fprintf(f1,'%s\n',MPCTable{i}); 
end
fclose(f1);
