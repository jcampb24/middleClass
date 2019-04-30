function wageProcess=specifyWageProcess(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'movingAverage','permanentInnovationWhenEmployed',...
    'permanentInnovationWhenUnemployed'};
%Set default parameter values.
wageProcess.movingAverage=specifyMovingAverage;
wageProcess.permanentInnovationWhenEmployed=specifyInnovation;
wageProcess.permanentInnovationWhenUnemployed=specifyInnovation;
%
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |wageProcess|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(wageProcess,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    wageProcess=candidate;
    j=2;
else
    j=1;
end
%\end{hiddencode}
%Next comes the argument processing. This
%follows the familiar loop through the elements of |varargin|.
%\begin{hiddencode}
while j<=nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames,'specifyWageProcess');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        
        
        case 'movingAverage'
            
            wageProcess.movingAverage=varargin{j+1};
            j=j+2;
                     
        case 'permanentInnovationWhenEmployed'
            
            wageProcess.permanentInnovationWhenEmployed=varargin{j+1};
            j=j+2;
            
        case 'permanentInnovationWhenUnemployed'
              
            wageProcess.permanentInnovationWhenUnemployed=varargin{j+1};
            j=j+2;
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');
                        
    end
    
end
%\end{hiddencode}
%
%Check the validity of the candidate |wageProcess|'s fields.
%\begin{itemize}
%\item |.movingAverage| is a structure that passes the tests in |specifyMovingAverage|.
validateattributes(wageProcess.movingAverage,{'struct'},{},'specifyWageProcess');
wageProcess.movingAverage=specifyMovingAverage(wageProcess.movingAverage);
%\item |.permanentInnovationWhenEmployed| and |.permanentInnovationWhenUnemployed| are structures that pass
%the tests in |specifyInnovation|.
validateattributes(wageProcess.permanentInnovationWhenEmployed,{'struct'},{},'specifyWageProcess');
validateattributes(wageProcess.permanentInnovationWhenUnemployed,{'struct'},{},'specifyWageProcess');
wageProcess.permanentInnovationWhenEmployed=specifyInnovation(wageProcess.permanentInnovationWhenEmployed);
wageProcess.permanentInnovationWhenUnemployed=specifyInnovation(wageProcess.permanentInnovationWhenUnemployed);
%\item The two innovations have equal |.supportLength|s.
if wageProcess.permanentInnovationWhenEmployed.supportLength ...
        ~= wageProcess.permanentInnovationWhenUnemployed.supportLength
    
    error('The two permanent innovations must have the same supportLength');
    
end
%\end{itemize}
