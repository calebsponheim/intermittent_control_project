function [base,propInds] = parseinput(base,inpt,ignoreCase)
% Parse property-value pairs. Take into account default values.
%
% INPUT:
%
%   base - Struct of cell array of default values. The following forms of
%       input are supported:
%
%           Struct:
%               base.(property1) = [defaultValue1]
%               base.(property2) = [defaultValue2]
%               ..
%
%           Matrix cell array:
%               base = {
%                   property1 defaultValue1
%                   property2 defaultValue2
%                       ..
%                   }
%
%           Vector cell array:
%               base = { property1 defaultValue1 property2 .. }
%
%   inpt - Either struct or cell array with propery-value pairs.
%
%   ignoreCase - ignore case of field names. default = false.
%           
%
% OUTPUT:
%
%   A struct that is a merger of [base] and [inpt], where incase of a
%   conflict, values from [inpt] are prefered.
%
%
% EXAMPLE:
%
%   base.name = 'John';
%   base.ID = 123 ;
%
%   in = { 'name' , 'Mike' , 'phone' , 789 };
%
%   result = parseinput(base,in)
%       result =
%            name: 'Mike'   % Default name was overriden
%              ID: 123      % Default ID values was used
%           phone: 789      % 'phone' field was added
%
%   * Using:
%       in = struct('name','Mike', 'phone',789);
%       Would give the same result.

% .........................................................................
% Hande input

if isempty(base)
    clear base;
elseif iscell(base)
    if ~isvector(base), base=base'; end
	base = base(:);
	base = cell2struct(base(2:2:end),base(1:2:end),1);
end

if ~exist('inpt','var') || isempty(inpt), propInds=[]; return; end
if ~exist('ignoreCase','var'), ignoreCase = false ; end

% .........................................................................
% If input is a cell array, convert it to struct

propInds = NaN;
if iscell(inpt) && length(inpt)==1 && isstruct(inpt{1})
    % struct within cell, happens when using varargin insted of varargin{:}
    inpt = inpt{1};
    
elseif iscell(inpt)
    
    % cell within cell, happens when using varargin insted of varargin{:}:
    if length(inpt)==1 && iscell(inpt{1})
        inpt = inpt{1};
        propInds = false;
    end
    
    % find indices <property,value> pairs in cell array:
    prpInds = false(size(inpt));
    prpInds(find(cellfun(@ischar,inpt),1,'first'):length(inpt)) = true;
    if sum(prpInds)==0, prpInds = false(size(inpt)); end
    inpt = inpt(prpInds);
    
    newInpt = cell(2*length(inpt),1);
    ind = 1;
    newInd = 0;
    while ind <= length(inpt)
        propname = inpt{ind} ;
        if propname(1)=='-'
            propname = propname(2:end);
            val = true;
            ind = ind+1;
        elseif propname(1)=='~'
            propname = propname(2:end);
            val = false;
            ind = ind+1;
        else
            val = inpt{ind+1};
            ind = ind+2;
        end
        newInd = newInd+2;
        newInpt(newInd-1:newInd) = {propname,val};
    end
    
    % convert to struct:
    inpt = newInpt(1:newInd);
    inpt = cell2struct(inpt(2:2:end),inpt(1:2:end-1),1) ;
    if isnan(propInds), propInds = prpInds; end
end

% .........................................................................
% Copy from input to base, override base's values

infields = fieldnames(inpt);
basefields = fieldnames(base);
for iField = 1 : length(infields)
    inFld = infields{iField} ;
    baseFld = infields{iField} ;
    if ignoreCase
        ind = strcmpi(basefields,infields{iField}) ;
        if any(ind), baseFld = basefields{ind}; end;
    end
    base.(baseFld) = inpt.(inFld) ;
end

