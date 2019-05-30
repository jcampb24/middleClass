%firstMpcTable.m
% This program calculates the results presented in the table of MPCs for
% the model without durable goods. 

%Load the calibrated model.
load baselineCalibration
%load nu0d5Calibration

% preferences=dp.preferences;
% preferences=specifyPreferences(preferences,'vecU',ones(1,10)+[zeros(1,9) .75]);
% opportunities=dp.opportunities;
% algorithm=dp.algorithm;
% dp=specifyDynamicProgram('preferences',preferences,...
%     'opportunities',opportunities,...
%     'algorithm',algorithm);
% dp=solveStandardDynamicProgram(dp);
% dp=gatherStandardDynamicProgram(dp,'abandon','staticPayoffs');
% dp=induceMarkovChainFromStandardDynamicProgram(dp);

%Calculate the wealth distribution
originalWealthDistributionPDF=dp.inducedMarkovChain.ergodicDistribution;
originalWealthDistributionSupport=dp.nodes.support(:,1)./...
    dp.nodes.support(:,4);
%originalWealthDistributionPDF=originalWealthDistributionPDF(originalWealthDistributionPDF>0);

%Consolidate duplicate values of wealth.
wealthDistributionSupport=unique(originalWealthDistributionSupport);
wealthDistributionPDF=zeros(size(wealthDistributionSupport));
parfor ii=1:length(wealthDistributionSupport)
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

% 
% %For each stage of the expenditure cycle, calculate the distribution of
% %households across the (unconditional) quantiles.
% wealthDistributionByKappa=zeros(4,dp.preferences.tau);
kappaIndex=find(strcmp(dp.nodes.names,'\kappa_t'),1,'first');
kappa=dp.nodes.support(:,kappaIndex);
% 
% for i=0:3
%    for j=1:dp.preferences.tau
%       wealthDistributionByKappa(i+1,j)=sum(originalWealthDistributionPDF(...
%           wealthCategory==i & kappa==j))./ ...
%       sum(originalWealthDistributionPDF(kappa==j));
%    end
%     
% end
% 
% %Save the results to a LaTeX table.
% 
% leftColumn=cell(4,1);
% leftColumn{1}='(0,25]';
% leftColumn{2}='(25,50]';
% leftColumn{3}='(50,75]';
% leftColumn{4}='(75,100)';
% 
% wealthDistributionTable=makeLaTeXTable('data',100*wealthDistributionByKappa,...
%     'leftColumn',leftColumn);
% 
% %Write the mpc table to a file.
% f1=fopen('baselineCalibrationWealthDistribution.tex','w');
% nRows=length(wealthDistributionTable);
% for i=1:nRows
%    fprintf(f1,'%s\n',wealthDistributionTable{i}); 
% end
% fclose(f1);
% 
% keyboard;


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
wealthCategoryAndKappaAverageMpcsOneOff=zeros(length(categories),...
    dp.preferences.tau);
for i=0:max(categories)
    for j=1:dp.preferences.tau
        wealthCategoryAndKappaAverageMpcsOneOff(i+1,j)=...
            originalWealthDistributionPDF(wealthCategory==i & kappa==j)'*...
            mpcOneOff(wealthCategory==i & kappa==j)/...
            sum(originalWealthDistributionPDF(wealthCategory==i & kappa==j));
    end
end

%The next experiment balances the budget by taking away $R-1$ times the
%transfer in each future period. For this calculation, we first solve the
%model with this permanently lower level of wages. We call this the
%balanced-budget intervention. Since we will extend the tax cut for
%different number of years, we will label these appropriately.

taxCut1=0.10;
opportunitiesDuringPaybackOfTaxCut1=dp.opportunities;
opportunitiesDuringPaybackOfTaxCut1.earningsProcess=...
    specifyEarningsProcess(opportunitiesDuringPaybackOfTaxCut1.earningsProcess,...
    'lumpSumTax',(R-1)*taxCut1);

dpDuringPaybackOfTaxCut1=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringPaybackOfTaxCut1,...
    'algorithm',dp.algorithm);
dpDuringPaybackOfTaxCut1.value=dp.value;
dpDuringPaybackOfTaxCut1=distributeStandardDynamicProgram(dpDuringPaybackOfTaxCut1);
dpDuringPaybackOfTaxCut1=solveStandardDynamicProgram(dpDuringPaybackOfTaxCut1);
dpDuringPaybackOfTaxCut1=gatherStandardDynamicProgram(dpDuringPaybackOfTaxCut1,'abandon','staticPayoffs');

%With the continuation value calculated, we need to calculate the value
%during the period of the tax cut.
opportunitiesDuringTaxCut1=dp.opportunities;
opportunitiesDuringTaxCut1.earningsProcess=...
    specifyEarningsProcess(opportunitiesDuringTaxCut1.earningsProcess,...
    'lumpSumTax',-taxCut1);

algorithmDuringTaxCut1=dp.algorithm;
algorithmDuringTaxCut1.iterationCountCeiling=1;

dpDuringTaxCut1=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringTaxCut1,...
    'algorithm',algorithmDuringTaxCut1);
dpDuringTaxCut1.value=dpDuringPaybackOfTaxCut1.value;
dpDuringTaxCut1=distributeStandardDynamicProgram(dpDuringTaxCut1);
dpDuringTaxCut1=solveStandardDynamicProgram(dpDuringTaxCut1);

%Calculate consumption during the first period of the tax cut and the
%corresponding MPCs.

aDuringTaxCut1=dpDuringTaxCut1.nodes.support(:,1);
aPrimeDuringTaxCut1=dpDuringTaxCut1.choices.support(dpDuringTaxCut1.optimalChoice);
wDuringTaxCut1=dpDuringTaxCut1.nodes.support(:,4);
consumptionDuringTaxCut1=aDuringTaxCut1+wDuringTaxCut1-aPrimeDuringTaxCut1/R;

mpcDuringTaxCut1=(consumptionDuringTaxCut1-consumption)/taxCut1;

wealthCategoryAverageMpcsAtStartOfTaxCut1=zeros(length(categories)+1,1);
for i=0:max(categories)
   wealthCategoryAverageMpcsAtStartOfTaxCut1(i+1)=...
       dp.inducedMarkovChain.ergodicDistribution(wealthCategory==i)'*...
       mpcDuringTaxCut1(wealthCategory==i)/wealthCategoryProbabilities(i+1);    
end
wealthCategoryAverageMpcsAtStartOfTaxCut1(end)=dp.inducedMarkovChain.ergodicDistribution'*mpcDuringTaxCut1;

%Calculate the MPC's for each wealth category and kappa
wealthCategoryAndKappaAverageMpcsTaxCut1=zeros(length(categories),...
    dp.preferences.tau);
for i=0:max(categories)
    for j=1:dp.preferences.tau
        wealthCategoryAndKappaAverageMpcsTaxCut1(i+1,j)=...
            originalWealthDistributionPDF(wealthCategory==i & kappa==j)'*...
            mpcDuringTaxCut1(wealthCategory==i & kappa==j)/...
            sum(originalWealthDistributionPDF(wealthCategory==i & kappa==j));
    end
end

%Next, perform the same experiment for a tax cut that lasts three periods.

taxCut3=0.10;
opportunitiesDuringPaybackOfTaxCut3=dp.opportunities;
opportunitiesDuringPaybackOfTaxCut3.earningsProcess=specifyEarningsProcess(...
    opportunitiesDuringPaybackOfTaxCut3.earningsProcess,...
    'lumpSumTax',(R-1)*(1+R+R^2)*taxCut3);
dpDuringPaybackOfTaxCut3=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringPaybackOfTaxCut3,...
    'algorithm',dp.algorithm);
dpDuringPaybackOfTaxCut3.value=dp.value;
dpDuringPaybackOfTaxCut3=distributeStandardDynamicProgram(dpDuringPaybackOfTaxCut3);
dpDuringPaybackOfTaxCut3=solveStandardDynamicProgram(dpDuringPaybackOfTaxCut3);
dpDuringPaybackOfTaxCut3=gatherStandardDynamicProgram(dpDuringPaybackOfTaxCut3,'abandon','staticPayoffs');

%With the continuation value calculated, we need to calculate the value
%during the period of the tax cut.
opportunitiesDuringTaxCut3=dp.opportunities;
opportunitiesDuringTaxCut3.earningsProcess=specifyEarningsProcess(...
    opportunitiesDuringTaxCut3.earningsProcess,...
    'lumpSumTax',-taxCut3);
algorithmDuringTaxCut3=dp.algorithm;
algorithmDuringTaxCut3.iterationCountCeiling=3;

dpDuringTaxCut3=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringTaxCut3,...
    'algorithm',algorithmDuringTaxCut3);
dpDuringTaxCut3.value=dpDuringPaybackOfTaxCut3.value;
dpDuringTaxCut3=distributeStandardDynamicProgram(dpDuringTaxCut3);
dpDuringTaxCut3=solveStandardDynamicProgram(dpDuringTaxCut3);

%Calculate consumption during the first period of the tax cut and the
%corresponding MPCs.

aDuringTaxCut3=dpDuringTaxCut3.nodes.support(:,1);
aPrimeDuringTaxCut3=dpDuringTaxCut3.choices.support(dpDuringTaxCut3.optimalChoice);
wDuringTaxCut3=dpDuringTaxCut3.nodes.support(:,4);
consumptionDuringTaxCut3=aDuringTaxCut3+wDuringTaxCut3-aPrimeDuringTaxCut3/R;

mpcDuringTaxCut3=(consumptionDuringTaxCut3-consumption)/taxCut3;

wealthCategoryAverageMpcsAtStartOfTaxCut3=zeros(length(categories)+1,1);
for i=0:max(categories)
   wealthCategoryAverageMpcsAtStartOfTaxCut3(i+1)=...
       dp.inducedMarkovChain.ergodicDistribution(wealthCategory==i)'*...
       mpcDuringTaxCut3(wealthCategory==i)/wealthCategoryProbabilities(i+1);    
end
wealthCategoryAverageMpcsAtStartOfTaxCut3(end)=dp.inducedMarkovChain.ergodicDistribution'*mpcDuringTaxCut3;

%The final experiment runs the tax cut for five years.
taxCut5=0.10;
opportunitiesDuringPaybackOfTaxCut5=dp.opportunities;
opportunitiesDuringPaybackOfTaxCut5.earningsProcess=specifyEarningsProcess(...
    opportunitiesDuringPaybackOfTaxCut5.earningsProcess,...
    'lumpSumTax',(R-1)*(1+R+R^2+R^3+R^4)*taxCut5);

dpDuringPaybackOfTaxCut5=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringPaybackOfTaxCut5,...
    'algorithm',dp.algorithm);
dpDuringPaybackOfTaxCut5.value=dp.value;
dpDuringPaybackOfTaxCut5=distributeStandardDynamicProgram(dpDuringPaybackOfTaxCut5);
dpDuringPaybackOfTaxCut5=solveStandardDynamicProgram(dpDuringPaybackOfTaxCut5);
dpDuringPaybackOfTaxCut5=gatherStandardDynamicProgram(dpDuringPaybackOfTaxCut5,'abandon','staticPayoffs');

%With the continuation value calculated, we need to calculate the value
%during the period of the tax cut.
opportunitiesDuringTaxCut5=dp.opportunities;
opportunitiesDuringTaxCut5.earningsProcess=specifyEarningsProcess(...
    opportunitiesDuringTaxCut5.earningsProcess,...
    'lumpSumTax',-taxCut5);

algorithmDuringTaxCut5=dp.algorithm;
algorithmDuringTaxCut5.iterationCountCeiling=5;

dpDuringTaxCut5=specifyDynamicProgram('preferences',dp.preferences,...
    'opportunities',opportunitiesDuringTaxCut5,...
    'algorithm',algorithmDuringTaxCut5);
dpDuringTaxCut5.value=dpDuringPaybackOfTaxCut5.value;
dpDuringTaxCut5=distributeStandardDynamicProgram(dpDuringTaxCut5);
dpDuringTaxCut5=solveStandardDynamicProgram(dpDuringTaxCut5);

%Calculate consumption during the first period of the tax cut and the
%corresponding MPCs.

aDuringTaxCut5=dpDuringTaxCut5.nodes.support(:,1);
aPrimeDuringTaxCut5=dpDuringTaxCut5.choices.support(dpDuringTaxCut5.optimalChoice);
wDuringTaxCut5=dpDuringTaxCut5.nodes.support(:,4);
consumptionDuringTaxCut5=aDuringTaxCut5+wDuringTaxCut5-aPrimeDuringTaxCut5/R;

mpcDuringTaxCut5=(consumptionDuringTaxCut5-consumption)/taxCut5;

wealthCategoryAverageMpcsAtStartOfTaxCut5=zeros(length(categories)+1,1);
for i=0:max(categories)
   wealthCategoryAverageMpcsAtStartOfTaxCut5(i+1)=...
       dp.inducedMarkovChain.ergodicDistribution(wealthCategory==i)'*...
       mpcDuringTaxCut5(wealthCategory==i)/wealthCategoryProbabilities(i+1);    
end
wealthCategoryAverageMpcsAtStartOfTaxCut5(end)=dp.inducedMarkovChain.ergodicDistribution'*mpcDuringTaxCut5;

%% Create a LaTeX table of the MPCs.


mpcs=100*[wealthCategoryAverageMpcsOneOff ...
    wealthCategoryAverageMpcsAtStartOfTaxCut1 ...
    wealthCategoryAverageMpcsAtStartOfTaxCut3 ...
    wealthCategoryAverageMpcsAtStartOfTaxCut5];

leftColumn=cell(length(categories)+1,1);
leftColumn{1}='0';
for i=2:length(categories)-1;
   leftColumn{i}=['(' num2str(categories(i-1)) ',' num2str(categories(i)) ']']; 
end
leftColumn{length(categories)}=[num2str(categories(end)) ' or more'];
leftColumn{end}='All Households';

MPCTable=makeLaTeXTable('data',[100*[wealthCategoryProbabilities; 1] mpcs],'leftColumn',leftColumn);

%Write the mpc table to a file.
%f1=fopen('precautionarySavingCalibrationAllExperiments.tex','w');
f1=fopen('baselineCalibrationAllExperiments.tex','w');
nRows=length(MPCTable);
for i=1:nRows
   fprintf(f1,'%s\n',MPCTable{i}); 
end
fclose(f1);
