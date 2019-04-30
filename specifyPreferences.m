function preferences=specifyPreferences(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'beta','nu','vecLambda','vecU','tau'};
%The construction of |preferences| starts with setting default values for its fields.
preferences.beta=0.94;
preferences.nu=1;
preferences.vecLambda=0;
preferences.vecU=1;
preferences.tau=1;
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |preferences|. If not, we throw an error.
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(preferences,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    preferences=candidate;
    j=2;
else
    j=1;
end
%Next comes the argument processing. This
%follows the familiar loop through the elements of |varargin|.
%\begin{hiddencode}
while j<=nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:4),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        case 'beta'
            
            preferences.beta=varargin{j+1};
            j=j+2;
            
        case 'nu'
            
            preferences.nu=varargin{j+1};
            j=j+2;
            
        case 'vecLambda'
            
            preferences.vecLambda=varargin{j+1};
            j=j+2;
            
        case 'vecU'
            
            preferences.vecU=varargin{j+1};
            j=j+2;
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');
            
    end
    
end
%\end{hiddencode}
%
%With the fields of |preferences| set, we check the validity of their values.
%\begin{itemize}
%\item $\beta\in[0,1)$
validateattributes(preferences.beta,{'numeric'},{'numel',1,'>=',0,'<',1},'specifyPreferences');
%\item $\nu$ is numeric scalar.
validateattributes(preferences.nu,{'numeric'},{'numel',1},'specifyPreferences');
%\item $\vec{\lambda}$ is a vector of numbers in $[0,1)$ with the same length as $\vec{U}$.
validateattributes(preferences.vecLambda,{'numeric'},{'vector','>=',0,'<',1,...
    'numel',numel(preferences.vecU)},'specifyPreferences');
%\item $\vec{U}$ is a vector of numbers in $(0\infty)$.
validateattributes(preferences.vecU,{'numeric'},{'vector','>',0},'specifyPreferences');
%\end{itemize}

%With the structure's fields validated, we assign $\tau$.
preferences.tau=length(preferences.vecU);
