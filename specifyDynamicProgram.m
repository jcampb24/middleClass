function dynamicProgram=specifyDynamicProgram(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'preferences','opportunities','algorithm','discountFactor','markovChain',...
    'permanentInnovation','choices','nodes','staticPayoffs','value','optimalChoice',...
    'conditionalDistribution','note'};
%Set default values for user-set fields and empty values for calculated fields.
dynamicProgram.preferences=specifyPreferences;
dynamicProgram.opportunities=specifyOpportunities;
dynamicProgram.algorithm=specifyAlgorithm;
dynamicProgram.discountFactor=[];
dynamicProgram.markovChain=[];
dynamicProgram.permanentInnovation=[];
dynamicProgram.choices=[];
dynamicProgram.nodes=[];
dynamicProgram.staticPayoffs=[];
dynamicProgram.value=[];
dynamicProgram.optimalChoice=[];
dynamicProgram.conditionalDistribution=[];
dynamicProgram.note=[];
%
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |dynamicProgram|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(dynamicProgram,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    dynamicProgram=candidate;
    j=2;
else
    j=1;
end
%\end{hiddencode}

%\begin{hiddencode}
while j<=nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:3),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
  
    switch thisName;
 
        case 'preferences'
            dynamicProgram.preferences=varargin{j+1};
                j=j+2;
                       
        case 'opportunities'
            dynamicProgram.opportunities=varargin{j+1};          
                j=j+2;
            
        case 'algorithm'
            dynamicProgram.algorithm=varargin{j+1};
                j=j+2;
           
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');        
    end
      
end
%\end{hiddencode}
%Validate the three potentially user-set inputs. Each of them should be a structure that passes the tests in
%its eponymous |specify| function.
validateattributes(dynamicProgram.preferences,{'struct'},{},'specifyDynamicProgram');
dynamicProgram.preferences=specifyPreferences(dynamicProgram.preferences);
validateattributes(dynamicProgram.opportunities,{'struct'},{},'specifyDynamicProgram');
dynamicProgram.opportunities=specifyOpportunities(dynamicProgram.opportunities);
validateattributes(dynamicProgram.algorithm,{'struct'},{},'specifyDynamicProgram');
dynamicProgram.algorithm=specifyAlgorithm(dynamicProgram.algorithm);

%With the inputs validated, we can proceed with the specification's calculations. Before doing so, announce
%what we are doing, the time, and the number of workers at the task.

%Start Matlab's internal timers.
tic;

%Put the discount factor in its standard field.
dynamicProgram.discountFactor=dynamicProgram.preferences.beta;

%Create the Markov Chain's support and transition matrix.
dynamicProgram.markovChain=specifyMarkovChain(dynamicProgram.preferences,dynamicProgram.opportunities);

%Create a cell array that gives the permanent innovation structure for each element in the support of
%|.markovChain|.
dynamicProgram.permanentInnovation=specifyPermanentInnovation(dynamicProgram.markovChain,...
    dynamicProgram.opportunities);

%Create the nodes upon which we evaluate the value function.
dynamicProgram.nodes=specifyNodes(dynamicProgram.algorithm,dynamicProgram.markovChain);

%Create the vector of possible choices. 
dynamicProgram.choices=specifyChoices(dynamicProgram.permanentInnovation,dynamicProgram.nodes);

%Create the matrix of static payoffs. This is \emph{distributed} across the workers. If a particular
%node/choice combination is infeasible, the associated return is $-\infty$.
dynamicProgram.staticPayoffs=specifyStaticPayoffs(dynamicProgram.preferences,dynamicProgram.opportunities,...
    dynamicProgram.nodes,dynamicProgram.choices);

%For each state/choice combination, calculate the distribution of next period's state across the values represented in
%|nodes|.  The complication is that the
%asset choices divided by the permanent wage innovation need not lie on
%the grid of assets. To get around this, we divide the probability of each
%oossible realization of tomorrow's scaled wealth across the grid points immediately above and below it.
%(Since zero is always an abscissa, any choice of $a^\prime=0$ lands on zero deterministically.)
%
%In principle, these distributions could be stored in a sparse three-dimensional matrix. In practice, further
%calculations with those matrices are slow. Instead, we keep track of the indices of the state space with
%positivie probability explicitly and calculate any expected values required ``by hand.'' The returned
%structure contains matrices for these indices as well as their associated probabilities.

dynamicProgram.conditionalDistribution = specifyConditionalDistribution(dynamicProgram.markovChain,...
    dynamicProgram.opportunities,dynamicProgram.nodes,dynamicProgram.choices,dynamicProgram.staticPayoffs);

%Calculate the initial guess for the value function and the associated optimal choice by maximizing the static
%payoffs.
[dynamicProgram.value,dynamicProgram.optimalChoice]=initialValueFunctionGuess(dynamicProgram.staticPayoffs);

%Each combination of state and asset choice has associated with it a
%distribution over future scaled assets.
% Here,
%we create this distribution for each choice. 
% conditionalDistribution=sparse([],[],[], ...
%     dynamicProgram.nodes.supportLength, ...
%     dynamicProgram.nodes.supportLength* ...
%     dynamicProgram.choices.supportLength, ...
%     2*dynamicProgram.markovChain.supportLength*zetaEmployed.supportLength);

%Each element of the cell array contains the probabilities across the
%future states for each state-choice combination. We cycle through these
%combinations filling in the weights.


%Subfunction for specifying the Markov chain that governs the vector of exogenous shocks.
%This combines the processes for the preference state and earnings into one encompassing stochastic process.
    function markovChain=specifyMarkovChain(preferences,opportunities)
        
        %Retrieve required information from the input structures.
        numberOfEarningsStates=length(opportunities.earningsProcess.transitionMatrix);
        earnings=opportunities.earningsProcess.earnings;
        employmentState=opportunities.earningsProcess.employmentState;
        wageState=opportunities.earningsProcess.wageState;
        numberOfPreferenceStates=preferences.tau;
        
        %Create the Markov chain's support. Each row gives the values of relevant variables in one of its states.
        markovChain.support=...
            [(1:1:numberOfPreferenceStates*numberOfEarningsStates)' ... An index number for the state.
            kron((1:1:numberOfPreferenceStates)',ones(numberOfEarningsStates,1)) ... The stage of the preference cycle.
            repmat(earnings,numberOfPreferenceStates,1) ... Earnings in the state
            repmat(employmentState,numberOfPreferenceStates,1) ... Indicator of employment in the state.
            repmat(wageState,numberOfPreferenceStates,1) ]; %Wages if employed in the state.
        markovChain.supportLength=numberOfPreferenceStates*numberOfEarningsStates;
        
        %Create a cell array with the names of |.support|'s columns.
        markovChain.names=cell(1,5);
        markovChain.names{1}='index';
        markovChain.names{2}='\kappa_t';
        markovChain.names{3}='y_t';
        markovChain.names{4}='E_t';
        markovChain.names{5}='w_t';
        
        %Create the Markov chain's transition matrix. Since the preference cycle and earnings process are independent,
        %this is just the Kronecker product of the two original transition matrices.
        preferenceTransitionMatrix=circshift(eye(numberOfPreferenceStates),[0 1]);
        earningsTransitionMatrix=opportunities.earningsProcess.transitionMatrix;
        markovChain.transitionMatrix=kron(preferenceTransitionMatrix,earningsTransitionMatrix);
        
    end

%Creates a cell array with one element for each row of |markovChain.support|. This contains a structure
%created by |specifyInnovation| that gives the wage's permanent innovation in that state.
    function permanentInnovation=specifyPermanentInnovation(markovChain,opportunities)
        %
        %Create the empty cell array.
        permanentInnovation=cell(markovChain.supportLength,1);
        %
        %Retrieve the two innovations from |opportunities|, one for when the household's worker is employed or
        %voluntarily unemployed and the other for when he is involuntarily unemployed.
        zetaEmployed=opportunities.earningsProcess.wageProcess.permanentInnovationWhenEmployed;
        zetaUnemployed=opportunities.earningsProcess.wageProcess.permanentInnovationWhenUnemployed;
        %
        %Assign the to innovations to the states depending on the value of $E_t$.
        eIndicator=strcmp(markovChain.names,'E_t');
        for ii=1:markovChain.supportLength
            if markovChain.support(ii,eIndicator)==1
                permanentInnovation{ii}=zetaEmployed;
            else
                permanentInnovation{ii}=zetaUnemployed;
            end
        end
    end

%Creates a structure with information on the nodes used for the value function's approximation.
    function nodes=specifyNodes(algorithm,markovChain)
        
        %Create the grid of possible wealth values.
        wealthSubgrids=cell(length(algorithm.breakPoints),1);
        wealthSubgrids{1}=(0:algorithm.stepSizes(1):algorithm.breakPoints(1))';
        for ii=2:length(wealthSubgrids);
            wealthSubgrids{ii}=(algorithm.breakPoints(ii-1):algorithm.stepSizes(ii):algorithm.breakPoints(ii))';
        end
        
        %Concatinate the grids and remove duplicate elements.
        wealthGrid=cell2mat(wealthSubgrids);
        wealthGrid=sort(unique(wealthGrid));
        
        %Create the nodes themselves. There is one for each possible combination of wealth and Markov-chain
        %state.
        nodes.support=[kron(wealthGrid,ones(markovChain.supportLength,1)) ...
            repmat(markovChain.support,length(wealthGrid),1)];
        %Record the number of nodes for later reference.
        nodes.supportLength=markovChain.supportLength*length(wealthGrid);
        nodes.names={'a_t' markovChain.names{:}}; %#ok<CCAT>

    end

%Creates a structure with information on the choices available to the household.
    function choices=specifyChoices(permanentInnovation,nodes)
               
        %Extract the grid of possible wealth values from the nodes.
        wealthGrid=unique(nodes.support(:,1));
        
        %Find the smallest possible permanent shock.
        smallestPossiblePermanentShock=inf;
        for ii=1:length(permanentInnovation)
            smallestPossiblePermanentShock=min(smallestPossiblePermanentShock,...
                min(permanentInnovation{ii}.support));
        end
        
        %Set an upper bound for the choice of wealth so that scaled wealth cannot exceed the largest wealth in
        %the grid.
        maximumWealth=wealthGrid(end);
        highestChoice=maximumWealth*exp(smallestPossiblePermanentShock);
        
        %Finally, remove wealth values greater than |highestChoice|.
        choices.support=wealthGrid(wealthGrid<=highestChoice);
        
        %Populate the support fields of |choices|.
        choices.supportLength=length(choices.support);
        choices.numberOfVariables=1;
        choices.names=cell(1,1);
        choices.names{1,1}='a^\prime';
  
    end

%Function to calculate a distributed static return matrix.
    function staticPayoffs=specifyStaticPayoffs(preferences,opportunities,nodes,choices)
        
        %Unpack required values from the input structures.
        
        R=opportunities.R; %Gross interest rate, $R$
        pi=opportunities.pi; %Minimum equity share in durable goods, $\pi$.
        delta=opportunities.delta; %Durable goods depreciation rate, $\delta$.
        vecLambda=preferences.vecLambda; %Vector of values for durable goods' expenditure share, $\lambda(i)$.
        vecU=preferences.vecU; %Vector of values for the marginal utility shifter, $U(i)$.
        nu=preferences.nu; %Intertemporal elasticity of substitution, $\nu$.
       
        lambda=vecLambda(nodes.support(:,strcmp(nodes.names,'\kappa_t'))); %Durable goods preference parameters.
        U=vecU(nodes.support(:,strcmp(nodes.names,'\kappa_t'))); %Marginal utility shifters.
        yPlusA=nodes.support(:,strcmp(nodes.names,'y_t'))...
            +nodes.support(:,strcmp(nodes.names,'a_t')); %Vector of available resources.
        numberOfStates=nodes.supportLength;
        
        aPrime=choices.support; %Vector of chosen wealth levels.
        numberOfChoices=choices.supportLength;
        
        %Distribute copies of all variables needed to calculate payoffs to the workers. These are all recieve
        %the ``Star'' suffix.
        lambdaStar=Composite;
        UStar=Composite;
        yPlusAStar=Composite;
        aPrimeStar=Composite;
        for ii=1:length(lambdaStar)
            lambdaStar{ii}=lambda;
            UStar{ii}=U;
            yPlusAStar{ii}=yPlusA;
            aPrimeStar{ii}=aPrime;
        end
        
        %Each worker calculates one slice of |staticPayoffs|. We set this up as a codistributed matrix and
        %allow the standard one-dimensional codistributor allocate the slices across the workers.
        spmd
            codist=codistributor('1d',1);
            staticPayoffs=-codistributed.inf(numberOfStates,numberOfChoices,'double',codist,'noCommunication');
            %Each write to a codistributed matrix incurrs an overhead cost. To economize on these, we write
            %the results to a local copy of the matrix and then copy that to the codistributed matrix once.
            localStaticPayoffs=getLocalPart(staticPayoffs);
            %The present worker is responsible for rows |iLow| through |iHigh|.
            [iLow,iHigh]=globalIndices(staticPayoffs,1);
            
            for ii=iLow:iHigh
                
                %Each row of |staticPayoffs| has a single initial sate. For this state, calculate durable
                %goods' optimal portfolio share and store the other relevant state-specific values in
                %stand-alone variables to avoid the overhead cost of repeated indexing. (JRC: How big is this
                %really?)???
                
                alphaStar=pi*(1-delta)*lambdaStar(ii)/(R-1+delta+pi*(1-delta)*lambdaStar(ii));
                yPlusAi=yPlusAStar(ii);
                lambdai=lambdaStar(ii);
                Ui=UStar(ii);
                
                %Each column corresponds to a specific choice. For each one, we first determine if it is
                %feasible. If so, we determine whether the minimum equity share in durable goods makes the
                %optimal portfolio share of durable goods infeasible. In either case, we calculate consumption
                %of both goods and (with these) utility. If the choice is infeasible, we leave utility at its
                %initialized value, $-\inf$.
                for jj=1:numberOfChoices;
                    isFeasible=R*yPlusAi>=aPrime(jj);
                    if isFeasible
                        isCreditConstrained=aPrime(jj)<alphaStar*yPlusAi*R;
                        if isCreditConstrained
                            S=aPrime(jj)/pi;
                            C=yPlusAi-aPrime(jj)*((R-(1-delta)*(1-pi))/(R*pi));
                            
                        else
                            S=lambdai*(R*yPlusAi-aPrime(jj))/(R-1+delta);
                            C=(1-lambdai)*(R*yPlusAi-aPrime(jj))/R;
                        end
                        
                        if nu~=1
                            localStaticPayoffs(ii-iLow+1,jj)=Ui*(S^lambdai*C^(1-lambdai))^(1-nu)/(1-nu);
                        else
                            localStaticPayoffs(ii-iLow+1,jj)=Ui*log(S^lambdai*C^(1-lambdai));
                        end
                        
                    end
                end
                
            end
            staticPayoffs(iLow:iHigh,1:end)=localStaticPayoffs;
        end
        
    end

%Function to calculate the conditional distribution of next period's state for each state/choice combination.
    function conditionalDistribution=specifyConditionalDistribution(markovChain,opportunities,...
            nodes,choices,staticPayoffs)
        
        transitionMatrix=markovChain.transitionMatrix;
        numberOfMarkovStates=markovChain.supportLength;
        zetaEmployed=opportunities.earningsProcess.wageProcess.permanentInnovationWhenEmployed;
        zetaUnemployed=opportunities.earningsProcess.wageProcess.permanentInnovationWhenUnemployed;
        numberOfPermanentShocks=zetaEmployed.supportLength;
        
%Calculate the maximum number of non-zero elements in any conditional
%distribution so that we can properly preinitialize matrices to store the conditional distribution's 
%non-zero probabilities and their associated indices.
        maximumNumberOfNonZeroElements=2*numberOfPermanentShocks*max(sum(transitionMatrix>0,2));
        
        %Give each worker copies of |nodes.support|, |choices.support|, and |markovChain.support|
        choicesSupport=Composite;
        nodesSupport=Composite;
        markovChainSupport=Composite;
        for i=1:length(choicesSupport)
            choicesSupport{i}=choices.support;
            nodesSupport{i}=nodes.support;
            markovChainSupport{i}=markovChain.support;
        end
        
%Since each worker is responsible for implementing the Belman operator on a subset of the state space, it
%makes sense to distribute the conditional distributions across the workers.
        spmd
            numberOfChoices=length(choicesSupport);
            numberOfNodes=length(nodesSupport);
            scaledChoices=unique(nodesSupport(:,strcmp(nodes.names,'a_t')));
            
            codist=codistributor('1d',1);
            numberOfNonZeroElements=codistributed.zeros(numberOfMarkovStates,numberOfChoices,codist);
            nonZeroElements=codistributed.zeros(numberOfMarkovStates,numberOfChoices,...
                maximumNumberOfNonZeroElements,codist);
            nonZeroPositions=codistributed.zeros(numberOfMarkovStates,numberOfChoices,...
                maximumNumberOfNonZeroElements,codist);
            %The present worker is responsible for rows |iLow| through |iHigh|.
            [iLow,iHigh]=globalIndices(numberOfNonZeroElements,1);
            
            localNumberOfNonZeroElements=getLocalPart(numberOfNonZeroElements);
            localNonZeroElements=getLocalPart(nonZeroElements);
            localNonZeroPositions=getLocalPart(nonZeroPositions);
            
            employmentIndicatorIndex=find(strcmp(markovChain.names,'E_t'),1,'first');
            
            for ii=iLow:iHigh;
                %Store the current state's associated row of the Markov chain's transition matrix in a vector to avoid
                %repeated indexing.
                thisTransitionMatrixRow=transitionMatrix(ii,:);
                %Store the current state's associated distribution of the permanent innovation in a new structure to avoid
                %repeated indexing.
                if markovChainSupport(ii,employmentIndicatorIndex)==1
                    thisZeta=zetaEmployed;
                else
                    thisZeta=zetaUnemployed;
                end
                
                %Cycle through the choices for $a^\prime$.
                for jj=1:numberOfChoices
                    thisChoice=choicesSupport(jj);
                    
%The construction of the probabilities depends on whether or not the
%asset choice equals zero. If it does, then tomorrow's wealth equals zero
%automatically. In this case, the first |markovChain.supportLength|
%elements of the probability vector equal |thisTransitionMatrixRow|.
                    if thisChoice==0
                        [~,jTemp,wTemp]=find(thisTransitionMatrixRow);
                        localNumberOfNonZeroElements(ii-iLow+1,jj)=length(jTemp);
                        localNonZeroPositions(ii-iLow+1,jj,1:length(jTemp))=jTemp;
                        localNonZeroElements(ii-iLow+1,jj,1:length(jTemp))=wTemp;
                    else
%We cycle through the exact values of future scaled wealth (which might or might not be on
%the grid of nodes) and distribute the probabilities over the two
%adjoining abscissa. We then combine these with the probabilities from
%|thisRowOfXi| and add them to the appropriate probabilities.
                        thisConditionalDistribution=zeros(numberOfNodes,1)...
                            ; %Initially place the distribution in a vector.
                        for kk=1:numberOfPermanentShocks
                            thisProbability=thisZeta.distribution(kk);
                            thisScaledChoice=thisChoice/exp(thisZeta.support(kk));
                            lowIndex=find(scaledChoices<thisScaledChoice,1,'last');
                            highIndex=lowIndex+1;
                            omega=(thisScaledChoice-scaledChoices(lowIndex))/...
                                (scaledChoices(highIndex)-scaledChoices(lowIndex));
                            
%By construction, the state indices proceed in
%|markovChain.supportLength| blocks, with each block corresponding to
%one asset level on the grid $\vec{a}$.
                            
                            thisConditionalDistribution((lowIndex-1)*numberOfMarkovStates+1:...
                                lowIndex*numberOfMarkovStates)= ...
                                thisConditionalDistribution((lowIndex-1)*numberOfMarkovStates+1:...
                                lowIndex*numberOfMarkovStates) + ...
                                (1-omega)*thisProbability*thisTransitionMatrixRow';
                            thisConditionalDistribution((highIndex-1)*numberOfMarkovStates+1:...
                                highIndex*numberOfMarkovStates)=...
                                thisConditionalDistribution((highIndex-1)*numberOfMarkovStates+1:...
                                highIndex*numberOfMarkovStates) + ...
                                omega*thisProbability*thisTransitionMatrixRow';
                            
                        end
%With the conditional distribution complete, record its non-zero elements, their locations, and
%their count.
                        [iTemp,~,wTemp]=find(thisConditionalDistribution);
                        localNumberOfNonZeroElements(ii-iLow+1,jj)=length(iTemp);
                        localNonZeroPositions(ii-iLow+1,jj,1:length(iTemp))=iTemp;
                        localNonZeroElements(ii-iLow+1,jj,1:length(iTemp))=wTemp;
                        
                    end
                end
            end
            %With the calculations complete, copy the local copies to the distributed matrices.
            numberOfNonZeroElements(iLow:iHigh,1:end)=localNumberOfNonZeroElements;
            nonZeroPositions(iLow:iHigh,1:end,1:end)=localNonZeroPositions;
            nonZeroElements(iLow:iHigh,1:end,1:end)=localNonZeroElements;
            
        end
        
        %What is this calculating?
        tempIndex=nodes.support(:,2);
        spmd
            indexToMarkovChain=codistributed.zeros(numberOfNodes,1);
            [iLow,iHigh]=globalIndices(staticPayoffs,1);
            indexToMarkovChain(iLow:iHigh,1)=tempIndex(iLow:iHigh,1);
        end
        
        %Assign the codistributed matrices to the output structure's fields.
        conditionalDistribution.numberOfNonZeroElements=numberOfNonZeroElements; %#ok<SPCN>
        conditionalDistribution.nonZeroPositions=nonZeroPositions; %#ok<SPCN>
        conditionalDistribution.nonZeroElements=nonZeroElements; %#ok<SPCN>
        conditionalDistribution.indexToMarkovChain=indexToMarkovChain; %#ok<SPCN>
        
        
    end

%Function to initialize the dynamic program's value function and initial policy.
    function [value,optimalChoice]=initialValueFunctionGuess(staticPayoffs)      
        spmd
            [value,optimalChoice]=max(staticPayoffs,[],2);
        end
    end


end

