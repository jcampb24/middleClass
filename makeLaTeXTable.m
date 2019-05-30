function LT=makeLaTeXTable(varargin)

%Valid names/value pairs.
names={'header','footer','leftColumn','data','format'};

%Default values for all inputs.
header=[];
footer=[];
leftColumn=[];
data=eye(2);
format='%3.0f';

j=1;
while j<nargin
    
    if j<nargin && ischar(varargin{j})
        thisName=validatestring(varargin{j},names,'makeLaTeXTable');
    else
        error('Enter fields as name/value pairs.');
    end
    
    switch thisName

        case 'header'     
            header=varargin{j+1};

        case 'footer'
            footer=varargin{j+1};
            
        case 'leftColumn'
            leftColumn=varargin{j+1};
            
        case 'data'
            data=varargin{j+1};
            
        case 'format'
            format=varargin{j+1};
            
        otherwise %String validation above should guarantee that we never reach this case.
            error('Internal error');   
    end
    j=j+2;
end

%Convert the data to LaTeX tabular/array rows.
T=makeLaTeXTabularRows(data,format);
%If there is a left column, append it to the table.
if ~isempty(leftColumn)
   
    numberOfRows=size(leftColumn,1);
    for i=1:numberOfRows
       T{i}=[leftColumn{i} ' & ' T{i}];
    end
    
end

%If there is a header, append it to the table.
if ~isempty(header);
    LT=[header; T];
else
    LT=T;
end

%If there is a footer, append it to the table.
if ~isempty(footer);
    LT=[LT;footer];
end

end

%This subfunction takes a numeric matrix $x$ as inputs and returns a cell
%array $T$ with one element for each tabular row. By convention, |\&|
%separates the columns and |\\\\| ends each row.
function T=makeLaTeXTabularRows(x,format)
nRows=size(x,1);
nCols=size(x,2);

T=cell(nRows,1);
for ii=1:nRows
    for jj=1:nCols

        T{ii}=[T{ii} formatNumberForLaTeXTable(x(ii,jj),format)];
        if jj<nCols
            T{ii} = [T{ii} ' & '];
        else
            T{ii} = [T{ii} ' \\'];
        end
        
    end
    
end

end

%This subfuction takes a real number as input and returns a string that can
%be inserted into a LaTeX tabular environment or array. The number has all
%of its digits and any minus sign placed into a zero-width makebox so that
%any column made up of such numbers will be properly aligned.

function s=formatNumberForLaTeXTable(x,format)

    sRaw=num2str(x,format);
    s=sRaw;
    %Place all characters but the first into a zero-width box.
    if length(sRaw)>1
        s=['\makebox[0pt][r]{' s(1:end-1) '}' s(end)];
    else
        s=sRaw;
    end


end

