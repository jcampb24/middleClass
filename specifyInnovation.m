function innovation=specifyInnovation(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'mean','variance','supportLength','support','distribution'};
%The construction of |innovation| starts with setting default values for its fields. These correspond to the
%trivial innovation.
innovation.mean=0;
innovation.variance=0;
innovation.supportLength=1;
innovation.support=innovation.mean;
innovation.distribution=1;
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |preferences|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |innovation|?
    if ~all(isfield(innovation,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |innovation|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    innovation=candidate;
    j=2;
else
    j=1;
end
%\end{hiddencode}
%
%Next comes the argument processing. This
%follows the familiar loop through the elements of |varargin|.
%
%\begin{hiddencode}
while j<=nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},fieldNames(1:3),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        case 'mean'
            
            innovation.mean=varargin{j+1};
            j=j+2;
            
        case 'variance'
            
            innovation.variance=varargin{j+1};
            j=j+2;
            
        case 'supportLength'
            
            innovation.supportLength=varargin{j+1};
            j=j+2;
            
        otherwise %String validation above should guarantee that we never reach this case
            error('Internal error');
            
    end
end 
%\end{hiddencode}
%
%With the fields of |innovation| set, we check their values' validity.
%\begin{itemize}
%\item |.mean| should be numeric and scalar.
validateattributes(innovation.mean,{'numeric'},{'scalar'},'specifyInnovation');
%\item |.variance| should be numeric, scalar, and nonnegative.
validateattributes(innovation.variance,{'numeric'},{'scalar','nonnegative'},'specifyInnovation');
%\item |.supportLength| should be numeric, scalar and integer valued odd. If |.variance| exceeds zero, then it
%must weakly exceed $3$.
if innovation.variance==0
    validateattributes(innovation.supportLength,{'numeric'},{'scalar','odd','positive'},'specifyInnovation');
else
    validateattributes(innovation.supportLength,{'numeric'},{'scalar','odd','>=',3},'specifyInnovation');
end
%\end{itemize}
%{
With |.mean|, |.variance|, and |.supportLength| validated, we proceed 
to construct the discrete random variable's support and probability
distribution. The function |gaussHermiteQuadrature| (presented below)
accomplishes this for a random variable with zero mean and unit variance. The transformation of the support to
match the specified |.mean| and |.variance| is straightforward.
%}            
        [support,distribution]=gaussHermiteQuadrature(innovation.supportLength);
        innovation.support = innovation.mean + sqrt(innovation.variance)*support;
        innovation.distribution=distribution;

end
