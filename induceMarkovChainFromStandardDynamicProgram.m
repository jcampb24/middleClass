function dpOut=induceMarkovChainFromStandardDynamicProgram(dpIn)

%Create the (sparse) transition matrix.
maximumNumberOfNonZeroElements=max(max(dpIn.conditionalDistribution.numberOfNonZeroElements));
allNonZeroElements=zeros(dpIn.nodes.supportLength*maximumNumberOfNonZeroElements,1);
allNonZeroRowIndices=zeros(dpIn.nodes.supportLength*maximumNumberOfNonZeroElements,1);
allNonZeroColumnIndices=zeros(dpIn.nodes.supportLength*maximumNumberOfNonZeroElements,1);

currentIndex=1;

for i=1:dpIn.nodes.supportLength;
    thisChoice=dpIn.optimalChoice(i);
    thisIndex=dpIn.conditionalDistribution.indexToMarkovChain(i);
    thisNumberOfNonZeroElements=dpIn.conditionalDistribution.numberOfNonZeroElements(thisIndex,thisChoice);
    allNonZeroElements(currentIndex:currentIndex+thisNumberOfNonZeroElements-1) = ...
        squeeze(dpIn.conditionalDistribution.nonZeroElements(thisIndex,thisChoice,1:thisNumberOfNonZeroElements));
    allNonZeroRowIndices(currentIndex:currentIndex+thisNumberOfNonZeroElements-1) = i;
    allNonZeroColumnIndices(currentIndex:currentIndex+thisNumberOfNonZeroElements-1) = ...
        squeeze(dpIn.conditionalDistribution.nonZeroPositions(thisIndex,thisChoice,1:thisNumberOfNonZeroElements));
    currentIndex=currentIndex+thisNumberOfNonZeroElements;
end
allNonZeroElements=allNonZeroElements(allNonZeroElements>0);
allNonZeroRowIndices=allNonZeroRowIndices(allNonZeroRowIndices>0);
allNonZeroColumnIndices=allNonZeroColumnIndices(allNonZeroColumnIndices>0);

transitionMatrix=sparse(allNonZeroRowIndices,allNonZeroColumnIndices,allNonZeroElements,dpIn.nodes.supportLength,dpIn.nodes.supportLength);

clear allNonZeroElements allNonZeroRowIndices allNonZeroColumnIndices;
%Find the single eigenvalue of |transitionMatrix| closest to 1. This should
%be 1 itself. The corresponding eigenvector is |p|.
[p,lambda]=eigs(transitionMatrix',1,'lr');
if abs(lambda-1)>1e-10
    error(['Calculated eigenvalue-1= ' num2str(lambda-1) ]);
end
p=p/sum(p);
if abs(sum(p(p<0)))<1e-10
    p(p<0)=0;
    p=p/sum(p);
else
    error(['Sum of negative elements in calculated ergodic distribution = ' num2str(sum(p(p<0)))]);
end

%Set truly small elements of |p| to zero if doing so has only a very, very
%small effect on the distribution.
if abs(sum(p(p<1e-15)))<1e-10
    p(p<1e-15)=0;
    p=p/sum(p);
else
    
end
dpOut=dpIn;

dpOut.inducedMarkovChain.transitionMatrix=transitionMatrix;
dpOut.inducedMarkovChain.ergodicDistribution=p;

end