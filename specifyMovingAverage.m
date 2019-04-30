
function movingAverage=specifyMovingAverage(varargin)
%Create a cell array with the names of the output structure's fields.
fieldNames={'innovation','coefficients','historySupport','supportLength','support','transitionMatrix'};
%The construction of |movingAverage| starts with setting default values for its fields.
movingAverage.innovation=specifyInnovation;
movingAverage.coefficients=1;
movingAverage.historySupport=movingAverage.innovation.support;
movingAverage.supportLength=movingAverage.innovation.supportLength;
movingAverage.support=movingAverage.innovation.support;
movingAverage.transitionMatrix=movingAverage.innovation.distribution;
%If the first argument is a structure, then we examine it to see if it has the fields in |fieldNames| and only
%those fields. If so, we use it to replace |movingAverage|. If not, we throw an error.
%\begin{hiddencode}
if nargin>0 && isstruct(varargin{1})
    candidate=varargin{1};
    candidateFieldNames=fieldnames(candidate);
    %Does the candidate have fields not in |preferences|?
    if ~all(isfield(movingAverage,candidateFieldNames))
        error('Input structure contains invalid fields.');
    end
    %Does the candidate have all of the fields in |preferences|?
    if ~all(isfield(candidate,fieldNames))
        error('Input structure does not contain required fields.');
    end
    movingAverage=candidate;
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
        thisName=validatestring(varargin{j},fieldNames(1:2),'specifyPreferences');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName
        
        case 'innovation'
            movingAverage.innovation=varargin{j+1};
            j=j+2;
            
        case 'coefficients'
            
            movingAverage.coefficients=varargin{j+1};
            if iscolumn(movingAverage.coefficients)
                movingAverage.coefficients=movingAverage.coefficients';
            end
            j=j+2;
            
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');
            
    end
        
end
%\end{hiddencode}
%Check the validity of user-set fields in |movingAverage|.
%\begin{itemize}
%\item |.innovation| is a structure created by |specifyInnovation|.
validateattributes(movingAverage.innovation,{'struct'},{},'specifyMovingAverage');
movingAverage.innovation=specifyInnovation(movingAverage.innovation);
%\item |.coefficients| is a vector of real numbers.
validateattributes(movingAverage.coefficients,{'numeric'},{'vector'},'specifyMovingAverage');
%\end{itemize}
%{
With the (possibly) user-set fields validated, we can proceed to the construction of the moving average's
Markov chain. The first step is to build |.historySupport|, each row of which gives one possible realization
of $\vec{\varepsilon}_t$. The first column's element
equals that realization's value of $\varepsilon_{t}$, the second column's equals
$\varepsilon_{t-1}$, etcetera.

There are |innovation.supportLength^length(coefficients)| rows to |.historySupport|.
The problem of constructing this matrix can be viewed recursively. Define
$A(j)$ as the support for the case with |length(coefficients)|
equal to $j$. When $j=1$, this simply equals |innovation.support|. (By construction, this is a column vector.)
We can construct $A(j+1)$ by horizontally concatinating the Kroeneker product of |innovation.support|
and a vector of |innovation.supportLength| ones with |innovation.supportLength| copies of $A(j)$ stacked upon
each other. That is
\[ A(j+1) = \left[\begin{array}{cc} \varepsilon^1\times \vec{1} & A(j) \\
\varepsilon^2\times \vec{1} & A(j) \\\\
\vdots & \vdots \\\\
\varepsilon^M\times \vec{1} & A(j) \\
\end{array}\right]. \]
where $M=$|innovation.suportLength| and $\vec{1}$ is the vector of |innovation.supportLength| ones.
The private function |A(j,support,order)| implements this recursion.
\begin{hiddencode}

\end{hiddencode}
With this defined, constructing the support matrix requires only a single
function call.
%}
movingAverage.historySupport=A(length(movingAverage.coefficients),...
    movingAverage.innovation.support,movingAverage.innovation.supportLength);
%{
With |.historySupport| in place, calculate the moving average's value at each point of the state space is
easy.
    %}
    movingAverage.support=movingAverage.historySupport*movingAverage.coefficients';
    %{
Since the only the first element of $\vec{\varepsilon}_t$ is nonrandom,
each row of the |.transitionMatrix| contains |innovation.supportLength| nonzero elements
that each equal one element of |innovation.distribution|. Although there is probably a
more clever way of constructing this, we use brute force: Cycle through
all hypothetical transitions, determine whether or not a given one has
positive probablity, and assign the probability accordingly.
    %}
    movingAverage.supportLength=size(movingAverage.historySupport,1);
    movingAverage.transitionMatrix=zeros(movingAverage.supportLength,movingAverage.supportLength);
    for i=1:movingAverage.supportLength;
        for j=1:movingAverage.supportLength;
            %Check to see if lagging the the |i| indexed element can produce
            %the history in the |j| indexed element. If so, assign the
            %appropriate probability.
            if all(movingAverage.historySupport(i,1:end-1)==movingAverage.historySupport(j,2:end))
                
                movingAverage.transitionMatrix(i,j) = movingAverage.innovation.distribution(...
                    movingAverage.innovation.support==movingAverage.historySupport(j,1));
                
            end
        end
    end
    
end

function Aprime=A(j,support,order)
if j==1;
    Aprime=support;
else
    Ajm1=A(j-1,support,order);
    Aprime=[kron(support,ones(size(Ajm1,1),1)) repmat(Ajm1,order,1)];
end
end
