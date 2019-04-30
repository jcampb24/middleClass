function dpOut=solveStandardDynamicProgram(dpIn)

%This function requires an open matlab pool.
pool=gcp('nocreate');
if isempty(pool)
    error('Matlab pool not started.')
else
    numberOfWorkers=pool.NumWorkers;
end
if numberOfWorkers==0
    error('solveStandardDynamicProgram requires an open Matlab pool.');
end

%Start the stopwatch.
tic

%Unpack the discount factor
beta=dpIn.discountFactor;

%Unpack the conditional distributions. These are composites.
numberOfNonZeroElements=dpIn.conditionalDistribution.numberOfNonZeroElements;
nonZeroElements=dpIn.conditionalDistribution.nonZeroElements;
nonZeroPositions=dpIn.conditionalDistribution.nonZeroPositions;
indexToMarkovChain=dpIn.conditionalDistribution.indexToMarkovChain;
numberOfMarkovStates=dpIn.markovChain.supportLength;

%Create local versions of the conditional distributions to speed access.
spmd
    localNumberOfNonZeroElements=getLocalPart(numberOfNonZeroElements);
    localNonZeroElements=getLocalPart(nonZeroElements);
    localNonZeroPositions=getLocalPart(nonZeroPositions);   
end

%Unpack the static returns. These are also composites. We create local
%versions of them as well.
staticPayoffs=dpIn.staticPayoffs;
spmd
    localStaticPayoffs=getLocalPart(staticPayoffs);
end
%Initialize the value function.
vIn=dpIn.value;
spmd
    v=gather(vIn);
end

%Initialize |EV|, the composite that will contain the expected value
%function calculations for each lab.
spmd
    [iLowConditionalDistribution,iHighConditionalDistribution]=...
        globalIndices(numberOfNonZeroElements,1);
    numberOfConditionalDistributionRows=iHighConditionalDistribution - ...
        iLowConditionalDistribution+1;
    numberOfChoices=size(dpIn.choices.support,1);
    EV=zeros(numberOfConditionalDistributionRows,numberOfChoices);
    p=codistributor1d.defaultPartition(numberOfMarkovStates);
    masterEVCodist=codistributor1d(1,p,[numberOfMarkovStates numberOfChoices]);
    [iLowValueFunction,iHighValueFunction]=...
        globalIndices(vIn,1);
    numberOfNodes=dpIn.nodes.supportLength;
    p=codistributor1d.defaultPartition(numberOfNodes);
    vPrimeCodist=codistributor1d(1,p,[numberOfNodes 1]);
    %The |localIndexToMarkovChain| gets used for logical indexing, so we need to remove all codistribution
    %properties. That is the function of the |getLocalPart| function in the next line.
    localIndexToMarkovChain=getLocalPart(indexToMarkovChain(iLowValueFunction:iHighValueFunction));
    distanceVectorCodistributor=codistributor1d(2,ones(1,numlabs),[1 numlabs]);
    distanceVector=codistributed.zeros(1,numlabs,distanceVectorCodistributor);
    distanceVectorIndex=globalIndices(distanceVector,2);   
end

%Initialize the measure of distance between v and vPrime so that the solver
%uses the Bellman operator at least once.
vDistance=dpIn.algorithm.convergenceTolerance+1;
%Initialize the iteration count.
iterationCount=0;
Tinitialization=toc;

while iterationCount<dpIn.algorithm.iterationCountCeiling && vDistance>dpIn.algorithm.convergenceTolerance
    
    %The first task in the Bellman operator's evaluation is the calculation of
    %the expected value function for each possible conditional distribution
    %over the next period's state.
    spmd
        for i=1:numberOfConditionalDistributionRows
            for j=1:numberOfChoices
                thisNumberOfNonZeroElements=localNumberOfNonZeroElements(i,j);
                theseProbabilities=squeeze(localNonZeroElements(i,j,1:thisNumberOfNonZeroElements));
                theseNonZeroPositions=squeeze(localNonZeroPositions(i,j,1:thisNumberOfNonZeroElements));
                theseValues=v(theseNonZeroPositions);
                EV(i,j)=theseProbabilities'*theseValues;
            end
        end
        
        masterEVCodistributed=codistributed.build(EV,masterEVCodist);
        masterEV=gather(masterEVCodistributed);
    
    %With these values in hand, we can calculate the total value of any given choice.
    try
        allValues=localStaticPayoffs+beta*masterEV(localIndexToMarkovChain,1:end);
    catch
        keyboard;
    end
        [localVPrime,~]=max(allValues,[],2);
        distanceVector(distanceVectorIndex)=max(abs(localVPrime-v(iLowValueFunction:iHighValueFunction)));
        
        vPrimeCodistributed=codistributed.build(localVPrime,vPrimeCodist);
        v=gather(vPrimeCodistributed); %#ok<NASGU>
        
    end
    
    vDistance=max(distanceVector);
    iterationCount=iterationCount+1;
    if ~isempty(dpIn.algorithm.output) && iterationCount/10==floor(iterationCount/10)
        Tnow=toc;
        parentFigure=get(dpIn.algorithm.output,'parent');
        outputData=get(dpIn.algorithm.output,'Data');
        outputData{1,2}=num2str(iterationCount);
        outputData{2,2}=[num2str(Tnow-Tinitialization,'%3.2f') ' secs'];
        outputData{3,2}=[num2str((Tnow-Tinitialization)/iterationCount,'%3.2f') ' secs'];
        set(dpIn.algorithm.output,'Data',outputData);
        figure(parentFigure);
    end
end

dpOut=dpIn;
dpOut.value=vPrimeCodistributed; %#ok<*SPCN>

%Calculate the optimal choices.
targetSize=size(dpIn.optimalChoice);
spmd    
    optimalChoice=codistributed.zeros(targetSize,codistributor1d(1));
    [iLow,iHigh]=globalIndices(optimalChoice,1);
    [~,localOptimalChoice]=max(allValues,[],2);  
    optimalChoice(iLow:iHigh,1)=localOptimalChoice;
end

dpOut.optimalChoice=optimalChoice;
if iterationCount>=dpIn.algorithm.iterationCountCeiling
        disp(['     Iteration count ceiling (' num2str(dpIn.algorithm.iterationCountCeiling) ') reached.']);
end


end

