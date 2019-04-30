function earningsProcess=specifyEarningsProcess(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'wageProcess','employmentProcess','unemploymentInsuranceReplacementRate',...
    'lumpSumTax','wageState','employmentState','earnings','transitionMatrix'};
earningsProcess.wageProcess=specifyWageProcess;
earningsProcess.employmentProcess=specifyEmploymentProcess;
earningsProcess.unemploymentInsuranceReplacementRate=1;
earningsProcess.lumpSumTax=0;
earningsProcess.wageState=1;
earningsProcess.employmentState=1;
earningsProcess.earnings=1;
earningsProcess.transitionMatrix=1;
%
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |preferences|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |earningsProcess|?
    if ~all(isfield(earningsProcess,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    earningsProcess=candidate;
    j=2;
else
    j=1;
end
%\end{hiddencode}
%Next comes the argument processing. This
%follows the familiar loop through the elements of |varargin|.
%\begin{hiddencode}
while j<nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:4),'specifyEarningsProcess');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        
        case 'wageProcess'
            
            earningsProcess.wageProcess=varargin{j+1};
            j=j+2;
            
            
        case 'employmentProcess'
            earningsProcess.employmentProcess=varargin{j+1};
            j=j+2;
            
        case 'unemploymentInsuranceReplacementRate'
            earningsProcess.unemploymentInsuranceReplacementRate=varargin{j+1};
            j=j+2;
            
        case 'lumpSumTax'
            earningsProcess.lumpSumTax=varargin{j+1};
            j=j+2;
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');
            
            
    end
end
%\end{hiddencode}
%
%Validate the user-set fields' values.
%\begin{itemize}
%\item |.wageProcess| is a structure that passes the tests of |specifyWageProcess|.
validateattributes(earningsProcess.wageProcess,{'struct'},{},'specifyEarningsProcess');
earningsProcess.wageProcess=specifyWageProcess(earningsProcess.wageProcess);
%\item |.employmentProcess| is a structure that passes the tests of |specifyEmploymentProcess|.
validateattributes(earningsProcess.employmentProcess,{'struct'},{},'specifyEarningsProcess');
earningsProcess.employmentProcess=specifyEmploymentProcess(earningsProcess.employmentProcess);
%\item |.unemploymentInsuranceReplacementRate| is a scalar in $(0,1]$.
validateattributes(earningsProcess.unemploymentInsuranceReplacementRate,{'numeric'},{'positive','<=',1},...
    'specifyEarningsProcess');
%\item |.lumpSumTax| is a scalar.
validateattributes(earningsProcess.lumpSumTax,{'numeric'},{'scalar'},'specifyEarningsProcess');
%\end{itemize}
%
%With the user-set fields validated, we proceed to create |.wageState| and |.employmentState|.
%Create the employment and wage states.
numberOfWageStates=earningsProcess.wageProcess.movingAverage.supportLength;
numberOfEmploymentStates=earningsProcess.employmentProcess.supportLength;
earningsProcess.employmentState=kron(earningsProcess.employmentProcess.support,ones(numberOfWageStates,1));
earningsProcess.wageState=repmat(earningsProcess.wageProcess.movingAverage.support,numberOfEmploymentStates,1);
%
%Create |.earnings|, the support of the earnings process. When the employment state
%equals 1, the household can be voluntarily unemployed if the wage is below
%the unemployment insurance replacement rate. The household also earns the
%unemployment insurance replacement rate if it is involuntarily unemployed.
%
earningsProcess.earnings=-earningsProcess.lumpSumTax+max(exp(earningsProcess.wageState),...
    earningsProcess.unemploymentInsuranceReplacementRate).*earningsProcess.employmentState...
    +(1-earningsProcess.employmentState)*earningsProcess.unemploymentInsuranceReplacementRate;
%
%Create the transition matrix.
earningsProcess.transitionMatrix=kron(...
    earningsProcess.employmentProcess.transitionMatrix,...
    earningsProcess.wageProcess.movingAverage.transitionMatrix);
