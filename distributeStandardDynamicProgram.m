function dpOut=distributeStandardDynamicProgram(dpIn)

%This function uses |distribute| to distribute fields of |dpIn| across the
%available matlab workers and place the results in |dpOut|. The resulting
%standard dynamic program can be fed to functions that require distributed
%input, such as |solveStandardDynamicProgram|.

dpOut=dpIn;

if ~isdistributed(dpIn.staticPayoffs);    
    targetSize=size(dpIn.staticPayoffs);
    spmd
       staticPayoffs=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(staticPayoffs,1);
    end
    localStaticPayoffs=Composite;
    for i=1:length(localStaticPayoffs)    
       localStaticPayoffs{i}=dpIn.staticPayoffs(iLow{i}:iHigh{i},:);
    end
    spmd
       staticPayoffs(iLow:iHigh,:)=localStaticPayoffs; 
    end
    dpOut.staticPayoffs=staticPayoffs;
    
end

if ~isdistributed(dpIn.conditionalDistribution.numberOfNonZeroElements);
       targetSize=size(dpIn.conditionalDistribution.numberOfNonZeroElements);
    spmd
       numberOfNonZeroElements=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(numberOfNonZeroElements,1);
    end
    localNumberOfNonZeroElements=Composite;
    for i=1:length(localNumberOfNonZeroElements)     
       localNumberOfNonZeroElements{i}=dpIn.conditionalDistribution.numberOfNonZeroElements(iLow{i}:iHigh{i},:);
    end
    spmd
       numberOfNonZeroElements(iLow:iHigh,:)=localNumberOfNonZeroElements; 
    end
    dpOut.conditionalDistribution.numberOfNonZeroElements=numberOfNonZeroElements; 
    
end

if ~isdistributed(dpIn.conditionalDistribution.nonZeroPositions)
       targetSize=size(dpIn.conditionalDistribution.nonZeroPositions);
    spmd
       nonZeroPositions=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(nonZeroPositions,1);
    end
    localNonZeroPositions=Composite;
    for i=1:length(localNonZeroPositions)       
       localNonZeroPositions{i}=dpIn.conditionalDistribution.nonZeroPositions(iLow{i}:iHigh{i},:,:);
    end
    spmd
       nonZeroPositions(iLow:iHigh,:,:)=localNonZeroPositions;
    end
    dpOut.conditionalDistribution.nonZeroPositions=nonZeroPositions;   
    
end

if ~isdistributed(dpIn.conditionalDistribution.nonZeroElements)
       targetSize=size(dpIn.conditionalDistribution.nonZeroElements);
    spmd
       nonZeroElements=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(nonZeroElements,1);
    end
    localNonZeroElements=Composite;
    for i=1:length(localNonZeroElements)  
       localNonZeroElements{i}=dpIn.conditionalDistribution.nonZeroElements(iLow{i}:iHigh{i},:,:);
    end
    spmd
       nonZeroElements(iLow:iHigh,:,:)=localNonZeroElements;
    end
    dpOut.conditionalDistribution.nonZeroElements=nonZeroElements;   
            
end

if ~isdistributed(dpIn.conditionalDistribution.indexToMarkovChain);
 targetSize=size(dpIn.conditionalDistribution.indexToMarkovChain);
    spmd
       indexToMarkovChain=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(indexToMarkovChain,1);
    end
    localIndexToMarkovChain=Composite;
    for i=1:length(localIndexToMarkovChain)      
       localIndexToMarkovChain{i}=dpIn.conditionalDistribution.indexToMarkovChain(iLow{i}:iHigh{i});
    end
    spmd
       indexToMarkovChain(iLow:iHigh,1)=localIndexToMarkovChain; 
    end
    dpOut.conditionalDistribution.indexToMarkovChain=indexToMarkovChain;    
end

if ~isdistributed(dpIn.value);
  targetSize=size(dpIn.value);
    spmd
       value=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(value,1);
    end
    localValue=Composite;
    for i=1:length(localValue)    
       localValue{i}=dpIn.value(iLow{i}:iHigh{i});
    end
    spmd
       value(iLow:iHigh,1)=localValue; 
    end
    dpOut.value=value;     
    
end

if ~isdistributed(dpIn.optimalChoice)
  targetSize=size(dpIn.optimalChoice);
    spmd
       optimalChoice=codistributed.zeros(targetSize,codistributor1d(1));
       [iLow,iHigh]=globalIndices(optimalChoice,1);
    end
    localOptimalChoice=Composite;
    for i=1:length(localOptimalChoice)      
       localOptimalChoice{i}=dpIn.optimalChoice(iLow{i}:iHigh{i});
    end
    spmd
       optimalChoice(iLow:iHigh,1)=localOptimalChoice; 
    end
    dpOut.optimalChoice=optimalChoice;       
    
end
    
end
