function employmentProcess=specifyEmploymentProcess(varargin)
%Declare a cell array of valid and required field names for an |employmentProcess| structure.
fieldNames={'transitionRateIntoUnemployment','transitionRateOutOfUnemployment','supportLength',...
    'support','transitionMatrix'};
%Set default values. These correspond to the trivial employment process.
employmentProcess ...
    .transitionRateIntoUnemployment=0;
employmentProcess ...
    .transitionRateOutOfUnemployment=1;
employmentProcess ...
    .support=1;
employmentProcess ...
    .supportLength=1;
employmentProcess ...
    .transitionMatrix=1;
%If the first argument is a structure, then ensure it has the required fields and only the required fields. If
%so, use it to replace |employmentProcess|.
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |employmentProcess|?
    if ~all(isfield(employmentProcess,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |employmentProcess|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    employmentProcess=candidate;
    j=2;
else
    j=1;
end

%Cycle through any remaining inputs.
while j<=nargin
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:2),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        case 'transitionRateIntoUnemployment'
            employmentProcess.transitionRateIntoUnemployment=varargin{j+1};
            employmentProcess.supportLength=2;
            
        case 'transitionRateOutOfUnemployment'
            employmentProcess.transitionRateOutOfUnemployment=varargin{j+1};
            employmentProcess.supportLength=2;
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');      
    end
    j=j+2;
end
%Further processing depends on whether or not |.supportLength| equals 1.
switch employmentProcess.supportLength    
%If so, then the user has requested a
%trivial employment process. We ensure that any values for the two transition rates do not contradict this,
%and then construct the process appropriately.     
    case 1
        validateattributes(employmentProcess.transitionRateIntoUnemployment,{'numeric'},{'<=',0,'>=',0});
        validateattributes(employmentProcess.transitionRateOutOfUnemployment,{'numeric'},{'<=',1,'>=',1});
        employmentProcess.support=1;
        employmentProcess.transitionMatrix=1;
%If not, then the user has requested a non-trival employment process. We ensure that the given transition 
%rates are indeed probabilities and then construct the support and transition matrix.
    case 2
        validateattributes(employmentProcess.transitionRateIntoUnemployment,{'numeric'},{'<=',1,'>=',0});
        validateattributes(employmentProcess.transitionRateOutOfUnemployment,{'numeric'},{'<=',1,'>=',0});
        employmentProcess.support=[0;1];
        employmentProcess.transitionMatrix=...
            [1-employmentProcess.transitionRateIntoUnemployment ...
            employmentProcess.transitionRateIntoUnemployment; ...
            employmentProcess.transitionRateOutOfUnemployment ...
            1-employmentProcess.transitionRateOutOfUnemployment];
    otherwise
        error('Internal error');
        
end

end

