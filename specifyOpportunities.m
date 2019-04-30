function opportunities=specifyOpportunities(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'R','delta','pi','earningsProcess'};
%Create the default version of the return structure.
opportunities.R=1/0.96;
opportunities.delta=0.1;
opportunities.pi=1;
opportunities.earningsProcess=specifyEarningsProcess;
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |preferences|. If not, we throw an error.
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(opportunities,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    opportunities=candidate;
    j=2;
else
    j=1;
end
%Next comes the argument processing. This
%follows the familiar loop through the elements of |varargin|.
%\begin{hiddencode}
while j<=nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:4),'specifyOpportunities');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        case 'earningsProcess'
            
            opportunities.earningsProcess=varargin{j+1};
            j=j+2;
            
            
        case 'R'
            opportunities.R=varargin{j+1};
            j=j+2;
            
        case 'delta'
            
            opportunities.delta=varargin{j+1};
            j=j+2;
            
            
        case 'pi'
            
            opportunities.pi=varargin{j+1};
            j=j+2;
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');
            
    end
end
%
%Validate the user-set fields' values.
%\begin{itemize}
%\item |.earningsProcess| is a structure that passes the tests in |setEarningsProcess|.
validateattributes(opportunities.earningsProcess,{'struct'},{},'specifyOpportunities');
opportunities.earningsProcess=specifyEarningsProcess(opportunities.earningsProcess);
%\item |.R| is a numeric scalar that exceeds 1.
validateattributes(opportunities.R,{'numeric'},{'scalar','>',1},'specifyOpportunities');
%\item |.delta| is a numeric scalar in $(0,1]$.
validateattributes(opportunities.delta,{'numeric'},{'scalar','positive','<=',1},'specifyOpportunities');
%\item |.pi| is a numeric scalar in $[0,1]$.
validateattributes(opportunities.pi,{'numeric'},{'scalar','nonnegative','<=',1},'specifyOpportunities');
%\end{hiddencode}
end
