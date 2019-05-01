function dpOut=gatherStandardDynamicProgram(dpIn,varargin)

%Default values for abandonment dummies.
abandonStaticPayoffs=0;
abandonConditionalDistribution=0;
abandonValue=0;
abandonOptimalChoice=0;

%This function takes a list of fields each prefaced by 'abandon' as optional
%arguments. 

if nargin>1
    i=1;
    while i<nargin
       switch varargin{i}
           
           case 'abandon'
               switch varargin{i+1}
                   case 'staticPayoffs'
                       abandonStaticPayoffs=1;
                   case 'conditionalDistribution'
                       abandonConditionalDistribution=1;
                   case 'value'
                       abandonValue=1;
                   case 'optimalChoice'
                       abandonOptimalChoice=1;
                   otherwise
                       error('Unrecognized distributed field.');
               end
               i=i+2;
               
           otherwise
               error('Unrecognized option.');              
       end
   end
end
    
%This function uses |gather| to replace distributed fields of |dpIn| with
%their ordinary non-distributed analogues.
dpOut=dpIn;
if isdistributed(dpIn.staticPayoffs) && ~abandonStaticPayoffs
    dpOut.staticPayoffs=gather(dpIn.staticPayoffs);
end

if isdistributed(dpIn.staticPayoffs) && abandonStaticPayoffs
    dpOut.staticPayoffs=[];
end

if isdistributed(dpIn.conditionalDistribution.numberOfNonZeroElements) && ~abandonConditionalDistribution
   dpOut.conditionalDistribution.numberOfNonZeroElements=gather(dpIn.conditionalDistribution.numberOfNonZeroElements);
end

if isdistributed(dpIn.conditionalDistribution.numberOfNonZeroElements) && abandonConditionalDistribution
   dpOut.conditionalDistribution.numberOfNonZeroElements=[];
end

if isdistributed(dpIn.conditionalDistribution.nonZeroElements) && ~abandonConditionalDistribution
   dpOut.conditionalDistribution.nonZeroElements=gather(dpIn.conditionalDistribution.nonZeroElements); 
end

if isdistributed(dpIn.conditionalDistribution.nonZeroElements) && abandonConditionalDistribution
   dpOut.conditionalDistribution.nonZeroElements=[]; 
end

if isdistributed(dpIn.conditionalDistribution.nonZeroPositions) && ~abandonConditionalDistribution
    dpOut.conditionalDistribution.nonZeroPositions=gather(dpIn.conditionalDistribution.nonZeroPositions);
end

if isdistributed(dpIn.conditionalDistribution.nonZeroPositions) && abandonConditionalDistribution
    dpOut.conditionalDistribution.nonZeroPositions=[];
end

if isdistributed(dpIn.conditionalDistribution.indexToMarkovChain) && ~abandonConditionalDistribution
    dpOut.conditionalDistribution.indexToMarkovChain=gather(dpIn.conditionalDistribution.indexToMarkovChain);
end

if isdistributed(dpIn.conditionalDistribution.indexToMarkovChain) && abandonConditionalDistribution
    dpOut.conditionalDistribution.indexToMarkovChain=[];
end

if isdistributed(dpIn.value) && ~abandonValue
    dpOut.value=gather(dpIn.value);
end

if isdistributed(dpIn.value) && abandonValue
    dpOut.value=[];
end

if isdistributed(dpIn.optimalChoice) && ~abandonOptimalChoice
    dpOut.optimalChoice=gather(dpIn.optimalChoice);
end

if isdistributed(dpIn.optimalChoice) && abandonOptimalChoice
    dpOut.optimalChoice=[];
end

end