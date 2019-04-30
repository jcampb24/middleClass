function dpTarget=initializeStandardDynamicProgramValueFunction(dpSource,dpTarget)

%This function requires that |dpSource.nodes.support| and
%|dpTarget.nodes.support| have the same number of \emph{columns}. For each
%node in |dpTarget|, it finds the closest (in the simple Euclidian sense)
%node in |dpSource| and copies the corresponding value function value
%into |dpTarget.value|. 


numberOfSourceStates=size(dpSource.nodes.support,2);
numberOfTargetStates=size(dpTarget.nodes.support,2);
if numberOfSourceStates~=numberOfTargetStates
    error('Source and target dynamic programs must have the same state-space dimensionality.');
end


%Loop through the nodes in the target. For each one, find
%the closest node in the source. 
closestNodes=zeros(dpTarget.nodes.supportLength,1);
numberOfTargetNodes=dpTarget.nodes.supportLength;
sourceNodes=dpSource.nodes.support;
targetNodes=dpTarget.nodes.support;
parfor i=1:numberOfTargetNodes
    differences=bsxfun(@minus,sourceNodes,targetNodes(i,:));   
    euclidianDistance=sum(differences.^2,2);
    [~,k]=min(euclidianDistance);
    closestNodes(i)=k;
end
sourceValue=gather(dpSource.value);
targetValueHere=sourceValue(closestNodes);
dpTarget.value=distributed(targetValueHere);
end
