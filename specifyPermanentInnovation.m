function permanentInnovation=specifyPermanentInnovation(varargin)

%Set default parameter values.
permanentInnovation.mean=0;
permanentInnovation.variance=0;
permanentInnovation.supportLength=1;
permanentInnovation.support=permanentInnovation.mean;
permanentInnovation.distribution=1;

%Cycle through the inputs.
j=1;
while j<=nargin
    switch varargin{j}
        
        case 'mean'
            if isnumeric(varargin{j+1}) && isscalar(varargin{j+1})
                permanentInnovation.mean=varargin{j+1};
                j=j+2;
            else
                error('Follow ''mean'' with a numeric scalar.');
            end     
        case 'variance'
            if isnumeric(varargin{j+1}) && isscalar(varargin{j+1}) && varargin{j+1}>=0
                permanentInnovation.variance=varargin{j+1};
                j=j+2;
            else
                error('Follow ''variance'' with a nonnegative scalar.');
            end            
        case 'supportLength'
            if isnumeric(varargin{j+1}) ...                      The argument is numeric,
                    && isscalar(varargin{j+1})...                and scalar,
                    && floor(varargin{j+1})==varargin{j+1} ...   and an integer,
                    && varargin{j+1}>0 ...                       and positive,
                    && varargin{j+1}>2*floor(varargin{j+1}/2)... and odd.
                    
                permanentInnovation.supportLength=varargin{j+1};
                j=j+2;
            else
                error('Follow ''supportLength'' with a nonnegative odd integer.');
            end
            
        case 'support'
            if isnumeric(varargin{j+1}) && isvector(varargin{j+1})
                permanentInnovation.support=varargin{j+1};
                j=j+2;
            else
                error('Follow ''support'' with a numeric vector.');
            end            
        case 'distribution'
            if isnumeric(varargin{j+1}) && isvector(varargin{j+1}) && all(varargin{j+1}>=0)
                permanentInnovation.distribution=varargin{j+1};
                j=j+2;
            else
                error('Follow ''distribution'' with a vector of non-negative numbers.');
            end
            
        otherwise
            error(['Unknown parameter: ' varargin{j}])
    end
    
end
%If the user has specified an innovation variance, then use it to construct
%the innovation distribution using Gauss-Hermite quadrature.
if permanentInnovation.variance>0 % The user has specified an innovation variance.
        if permanentInnovation.supportLength==1 %The user has called for only one point in the support.
            error('Specify odd support length 3 or more with ''supportLength''');
        else
            [abscissa,weights]=gaussHermiteQuadrature(permanentInnovation.supportLength);
            permanentInnovation.support = permanentInnovation.mean + ...
                sqrt(permanentInnovation.variance)*abscissa;
            permanentInnovation.distribution=weights;
        end
end
%Test to ensure that the user has input identically-sized support and
%distribution vectors.
if length(permanentInnovation.distribution)~=length(permanentInnovation.support)
        error('Specify ''support'' and ''distribution'' as identically-sized vectors.');
end
%If either |support| or |distribution| is a row vector, transpose it.
if isrow(permanentInnovation.distribution)
    permanentInnovation.distribution=permanentInnovation.distribution';
end

if isrow(permanentInnovation.support)
    permanentInnovation.support=permanentInnovation.support';
end
%Place the actual support length into |supportLength|.
permanentInnovation.supportLength=length(permanentInnovation.support);
%Calculate the implied mean and variance from |support| and |distribution|
%and place these into |mean| and |variance|.
permanentInnovation.mean=permanentInnovation.distribution'*permanentInnovation.support;
permanentInnovation.variance=permanentInnovation.distribution'*...
    (permanentInnovation.support-permanentInnovation.mean).^2;



            
        