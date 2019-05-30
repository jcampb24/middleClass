%removeUncertainty.m
%This file calculates the optimal consumption policy and ergodic
%distribution for the model with no wage uncertainty and no durable goods.

load baselineCalibration
%load nu15Calibration
%Specify preferences.
preferences=dp.preferences;

%opportunities=dp.opportunities;
earningsProcess=specifyEarningsProcess('trivial');
R=dp.opportunities.R;
opportunities=specifyOpportunities('earningsProcess',earningsProcess,'R',R);

algorithm=dp.algorithm;
algorithm=specifyAlgorithm(algorithm);

%Specify the standard dynamic program.
dp=specifyDynamicProgram('preferences',preferences,...
    'opportunities',opportunities,'algorithm',algorithm);

%Solve the dynamic program.
dp=solveStandardDynamicProgram(dp);

%Gather the dynamic program to the master node and calculate its ergodic
%distribution.The static payoffs don't fit in the master computer's memory,
%so we abandon that field. (It still exists as a distributed array.)
dpHere=gatherStandardDynamicProgram(dp,'abandon','staticPayoffs');
dpHere=induceMarkovChainFromStandardDynamicProgram(dpHere);

%Calculate the savings policy for each value of $\kappa$ and plot them.
states=dpHere.nodes.support;
numberOfStates=dpHere.nodes.supportLength;
a=states(:,1);
kappa=states(:,2);
aPrime=dpHere.choices.support;
optimalAprimeVector=aPrime(dpHere.optimalChoice);
tau=dpHere.preferences.tau;

originalA=zeros(numberOfStates/tau,tau);
optimalAprime=zeros(numberOfStates/tau,tau);
for thisKappa=1:tau
    originalA(:,thisKappa)=a(kappa==thisKappa);
    optimalAprime(:,thisKappa)= optimalAprimeVector(kappa==thisKappa);
end

%Create the figure window and set its background color to white.
f1=figure;
set(gcf,'color',[1 1 1]);
%Make the figure as large as an 11x17 sheet of paper.
set(gcf,'Position',[0 10 1700 1100], ...
    'PaperUnits','in','PaperSize',[17 11], ...
    'PaperPositionMode','manual','PaperPosition',[0 0 17 11]);

%Put a 45 degree line on the plot.
plot(originalA(:,1),originalA(:,1),'LineWidth',3,'color',[0.6 0.6 0.6],'LineStyle','--');

%Turn the axis box off.
box(gca,'off');
%Increase the font size and label the axes.
set(gca,'FontSize',24)
xlabel('Initial Wealth');
ylabel('Chosen Wealth');

%Plot each of the savings policy functions. We give higher values of
%$\kappa$ darker shades.
hold;
plotColors=colormap('jet');
colorIncrement=floor(length(plotColors)/tau);
for thisKappa=1:tau
    
    thisColor=plotColors((thisKappa-1)*colorIncrement+1,:);
    plot(originalA(:,thisKappa),optimalAprime(:,thisKappa),'LineWidth',2,'color',thisColor,'LineStyle','-');
        
end

%Create a nonverbose legend for the plot.
axisPosition=get(gca,'Position');
ylim([0 2]);
xlim([0 2]);
yLimits=ylim;
xLimits=xlim;
plotCoordinates= @(x,y) [axisPosition(1)+axisPosition(3)*(x-xLimits(1))/(xLimits(2)-xLimits(1)) ...
    axisPosition(2)+axisPosition(4)*(y-yLimits(1))/(yLimits(2)-yLimits(1))];

%Find the y-level of the highest value function plotted.
aPrimeMaximum=max(max(optimalAprime(originalA<=2)));

%The leftmost annotation gives the color for the value function
%corresponding to $\kappa=1$. It gets a label.

xIncrement=(xLimits(2)-xLimits(1))/(tau+2);
thisX=xIncrement;
yLow=aPrimeMaximum+0.3*(yLimits(2)-aPrimeMaximum);
yHigh=aPrimeMaximum+0.8*(yLimits(2)-aPrimeMaximum);
startingPoint=plotCoordinates(thisX,yLow);
endingPoint=plotCoordinates(thisX,yHigh);

annotation('textarrow',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
    'Color',plotColors(1,:),'LineWidth',2,'HeadStyle','none',...
    'String','\kappa=1','FontSize',24,'HorizontalAlignment','center');

%Create labelless annotations for all but the final value of $\kappa$.
for thisKappa=2:tau-1
    thisX=thisX+xIncrement;
    thisColor=plotColors((thisKappa-1)*colorIncrement+1,:);
    startingPoint=plotCoordinates(thisX,yLow);
    endingPoint=plotCoordinates(thisX,yHigh);
    
    annotation('line',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
        'Color',thisColor,'LineWidth',2);
end

%The rightmost annotation gives the color for the value function
%corresponding to $\kappa=\tau$. It gets a label.

thisX=thisX+xIncrement;
thisColor=plotColors((tau-1)*colorIncrement+1,:);
startingPoint=plotCoordinates(thisX,yLow);
endingPoint=plotCoordinates(thisX,yHigh);
annotation('textArrow',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
    'Color',thisColor,'LineWidth',2,'HeadStyle','none', ...
    'String',['\kappa = ' num2str(tau)],'FontSize',24,'HorizontalAlignment','center');


%Plot the value function against initial wealth for the possible values of
%$\kappa$.

values=dpHere.value;
valueFunction=zeros(numberOfStates/tau,tau);
for thisKappa=1:tau
    valueFunction(:,thisKappa)=values(kappa==thisKappa);    
end

%Create the figure window and set its background color to white.
f2=figure;
set(gcf,'color',[1 1 1]);
%Make the figure as large as an 11x17 sheet of paper.
set(gcf,'Position',[0 10 1700 1100], ...
    'PaperUnits','in','PaperSize',[17 11], ...
    'PaperPositionMode','manual','PaperPosition',[0 0 17 11]);
plotColors=colormap('jet');
colorIncrement=floor(length(plotColors)/tau);
thisColor=plotColors(1,:);
plot(originalA(:,1),valueFunction(:,1),'LineWidth',2,'color',thisColor,'LineStyle','-');
%Turn the axis box off.
box(gca,'off');
%Increase the font size and label the axes.
set(gca,'FontSize',24)
xlabel('Initial Wealth');
ylabel('Value Function');

%Plot each of the savings policy functions. We give higher values of
%$\kappa$ darker shades.

hold;
for thisKappa=2:tau
    
    thisColor=plotColors((thisKappa-1)*colorIncrement+1,:);
    plot(originalA(:,thisKappa),valueFunction(:,thisKappa),'LineWidth',2,'color',thisColor,'LineStyle','-');
        
end

%Create a nonverbose legend for the plot.
axisPosition=get(gca,'Position');
yLimits=ylim;
xLimits=xlim;
plotCoordinates= @(x,y) [axisPosition(1)+axisPosition(3)*(x-xLimits(1))/(xLimits(2)-xLimits(1)) ...
    axisPosition(2)+axisPosition(4)*(y-yLimits(1))/(yLimits(2)-yLimits(1))];

%Find the y-level of the highest value function plotted.
valueFunctionMaximum=max(max(valueFunction));
yValueOfValueFunctionMaximum=plotCoordinates(0,valueFunctionMaximum);
yValueOfValueFunctionMaximum=yValueOfValueFunctionMaximum(2);

%The leftmost annotation gives the color for the value function
%corresponding to $\kappa=1$. It gets a label.

xIncrement=(xLimits(2)-xLimits(1))/(tau+2);
thisX=xIncrement;
yLow=valueFunctionMaximum+0.3*(yLimits(2)-valueFunctionMaximum);
yHigh=valueFunctionMaximum+0.8*(yLimits(2)-valueFunctionMaximum);
startingPoint=plotCoordinates(thisX,yLow);
endingPoint=plotCoordinates(thisX,yHigh);

annotation('textarrow',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
    'Color',plotColors(1,:),'LineWidth',2,'HeadStyle','none',...
    'String','\kappa=1','FontSize',24,'HorizontalAlignment','center');

%Create labelless annotations for all but the final value of $\kappa$.
for thisKappa=2:tau-1
    thisX=thisX+xIncrement;
    thisColor=plotColors((thisKappa-1)*colorIncrement+1,:);
    startingPoint=plotCoordinates(thisX,yLow);
    endingPoint=plotCoordinates(thisX,yHigh);
    
    annotation('line',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
        'Color',thisColor,'LineWidth',2);
end

%The rightmost annotation gives the color for the value function
%corresponding to $\kappa=\tau$. It gets a label.

thisX=thisX+xIncrement;
thisColor=plotColors((tau-1)*colorIncrement+1,:);
startingPoint=plotCoordinates(thisX,yLow);
endingPoint=plotCoordinates(thisX,yHigh);
annotation('textArrow',[startingPoint(1) endingPoint(1)],[startingPoint(2) endingPoint(2)], ...
    'Color',thisColor,'LineWidth',2,'HeadStyle','none', ...
    'String',['\kappa = ' num2str(tau)],'FontSize',24,'HorizontalAlignment','center');

%Calculate the ergodic cycle.
%For this, we find the non-zero elements of the ergodic distribution.
%Starting from the first one on the list, we follow the optimal policy
%until we return. To check our answer, we calculate the continuation from
%the final cycle state and ensure that it equals our initial state.
ergodicCycle.index=zeros(tau+1,1);
ergodicCycle.index(1)=find(dpHere.inducedMarkovChain.ergodicDistribution,1,'first');
for thisIndex=2:tau+1;
    thisOptimalChoice=dpHere.optimalChoice(ergodicCycle.index(thisIndex-1));
    thisMarkovState=dpHere.conditionalDistribution.indexToMarkovChain(ergodicCycle.index(thisIndex-1));
    ergodicCycle.index(thisIndex) = squeeze( ...
        dpHere.conditionalDistribution.nonZeroPositions(thisMarkovState,thisOptimalChoice,1));    
end

if ergodicCycle.index(1)~=ergodicCycle.index(end)
    error('Error calculating ergodic cycle.');
end

%If per chance the first and last positions in the cycle do not have
%$\kappa=1$, then shift the cycle before proceeding.
if kappa(ergodicCycle.index(1))~=1
    ergodicCycle.index=ergodicCycle.index(1:end-1);
    ergodicCycle.index=circshift(ergodicCycle.index,kappa(ergodicCycle.index(1))-1);
    ergodicCycle.index=[ergodicCycle.index; ergodicCycle.index(1)];
end

%Retrieve the value of kappa associated with each element of the cycle.
ergodicCycle.kappa=kappa(ergodicCycle.index);   

%Calculate wealth at each stage of the ergodic cycle.
ergodicCycle.startingWealth=a(ergodicCycle.index);
ergodicCycle.nextPeriodsWealth=optimalAprimeVector(ergodicCycle.index);

%Calcualte consumption, total income, and saving at each stage of the
%ergodic cycle.

ergodicCycle.consumption=ergodicCycle.startingWealth+1-ergodicCycle.nextPeriodsWealth/opportunities.R;
ergodicCycle.income=1+ergodicCycle.startingWealth*(opportunities.R-1)/opportunities.R;
ergodicCycle.saving=ergodicCycle.income-ergodicCycle.consumption;

%The final ergodic cycle calculation is the marginal propensity to consume.
%For this, we add |mpcIncrement|\times|stepSize| to the initial wealth and
%recalculate consumption.
mpcIncrement=100;
newIndex=zeros(length(ergodicCycle.index),1);
wealthIncrement=zeros(length(ergodicCycle.index),1);
for t=1:length(ergodicCycle.index)
    %Calculate the grid step length at the point in the cycle.
    thisStepSize=min(a(a>ergodicCycle.startingWealth(t))-ergodicCycle.startingWealth(t));
    targetNewStartingWealth=ergodicCycle.startingWealth(t)+ ...
        mpcIncrement*thisStepSize;      
    dist=(a-targetNewStartingWealth).^2+(kappa-ergodicCycle.kappa(t)).^2;
    [~,newIndex(t)]=min(dist);     
    wealthIncrement(t)=a(newIndex(t))-a(ergodicCycle.index(t));
end
newNextPeriodsWealth=optimalAprimeVector(newIndex);
newConsumption=1+ergodicCycle.startingWealth+wealthIncrement-newNextPeriodsWealth/opportunities.R;

ergodicCycle.marginalPropensityToConsume=(newConsumption-ergodicCycle.consumption)./wealthIncrement;

%Replace the MPC with 1 for those periods with a binding borrowing
%constraint. That is, we only use the finite-difference method for interior
%solution points.
%ergodicCycle.marginalPropensityToConsume(ergodicCycle.nextPeriodsWealth==0)=1;

%Create a plot to illustrate the non-stochastic cycle.
f3=figure;
set(gcf,'color',[1 1 1]);
%Make the figure as large as an 11x17 sheet of paper.
set(gcf,'Position',[0 10 1700 1100], ...
    'PaperUnits','in','PaperSize',[17 11], ...
    'PaperPositionMode','manual','PaperPosition',[0 0 17 11]);
  
%Regular consumption
regularConsumption=ergodicCycle.consumption;
regularConsumption(end-1)=regularConsumption(end-1)/(dp.preferences.vecU(end));
subplot(2,2,1);
plot(regularConsumption,'ob','MarkerFaceColor','b','MarkerSize',12);
box(gca,'off');
%Increase the font size and label the axes.
set(gca,'FontSize',26,'xlim',[1 10],'ylim',[0 1.1])
%xlabel('Years Since Special Expenditure');
ylabel('Share of Earnings');
title('Ordinary Consumption');

%Special consumption
specialConsumption=ergodicCycle.consumption-regularConsumption;
subplot(2,2,2);
plot(specialConsumption,'ob','MarkerFaceColor','b','MarkerSize',12);
box(gca,'off');
set(gca,'FontSize',26,'xlim',[1 10],'ylim',[0 1.1]);
title('Special Good');

%Assets
subplot(2,2,3);
plot(ergodicCycle.startingWealth,'ob','MarkerFaceColor','b','MarkerSize',12);
box(gca,'off');
%Increase the font size and label the axes.
set(gca,'FontSize',26,'xlim',[1 10],'ylim',[0 1.1])
xlabel('Years Since Periodic Expenditure');
ylabel('Share of Earnings');
title('Beginning-of-Year Wealth');

%Marginal propensity to consume
subplot(2,2,4);
plot(100*ergodicCycle.marginalPropensityToConsume,'ob','MarkerFaceColor','b','MarkerSize',12);
box(gca,'off');
set(gca,'FontSize',26,'xlim',[1 10],'ylim',[0 110]);
xlabel('Years Since Periodic Expenditure');
ylabel('Percentage Response');
title('Marginal Propensity to Consume');

%Save the figure to a .pdf file.
print 'nonstochasticCycle' -dpdf


