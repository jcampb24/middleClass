function algorithm=specifyAlgorithm(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'breakPoints','stepSizes','convergenceTolerance','iterationCountCeiling','output'};
%Set defaults.
algorithm.breakPoints=1.6;
algorithm.stepSizes=1e-2;
algorithm.convergenceTolerance=1e-5;
algorithm.iterationCountCeiling=500;
algorithm.output=[];
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |algorithm|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(algorithm,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    algorithm=candidate;
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
        thisName=validatestring(varargin{j},fieldNames(1:5),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName;
        
        case 'breakPoints'
            algorithm.breakPoints=varargin{j+1};
            
        case 'stepSizes'
            algorithm.stepSizes=varargin{j+1};
            
        case 'convergenceTolerance'
            algorithm.convergenceTolerance=varargin{j+1};
            
        case 'iterationCountCeiling'
            algorithm.iterationCountCeiling=varargin{j+1};
            
        case 'output'
            algorithm.output=varargin{j+1};
            
    end
    
    j=j+2;
    
end
%\end{hiddencode}
%Check the validity of user-set fields.
%\begin{itemize}
%\item |.breakPoints| should be vector-valued, positive, and increasing.
validateattributes(algorithm.breakPoints,{'numeric'},{'vector','positive','increasing'},'specifyAlgorithm');
%\item |.stepSizes| should be vector-valued, positive and positive with same size as |.breakPoints|.
validateattributes(algorithm.stepSizes,{'numeric'},...
    {'vector','positive','numel',numel(algorithm.breakPoints)},'specifyAlgorithm');
%\item |.convergenceTolerance| should be scalar and positive.
validateattributes(algorithm.convergenceTolerance,{'numeric'},{'scalar','positive'},'specifyAlgorithm');
%\item |.iterationCountCeiling| should be scalar, integer-valued, and positive.
validateattributes(algorithm.iterationCountCeiling,{'numeric'},...
    {'scalar','integer','positive'},'specifyAlgorithm');
%\item |.output| should either be empty or a handle to a |uitable|.
if ~isempty(algorithm.output)
   validateattributes(algorithm.output,{'numeric'},{'scalar'},'specifyAlgorithm');
   if ishandle(algorithm.output) && strcmp(get(algorithm.output,'Type'),'uitable')
       
   else
       error('algorithm.output must be a handle to a uitable object.');
   end
end
%\end{itemize}
